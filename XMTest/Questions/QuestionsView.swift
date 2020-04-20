import UIKit
import SnapKit
import ReactiveFeedback

final class QuestionsView: UIView {
    enum BannerState {
        case success
        case failure
    }

    private let bannerView = BannerView().with {
        $0.alpha = 0
    }
    private let statusLabel = UILabel()
    private let questionLabel = UILabel().with {
        $0.numberOfLines = 0
    }

    private let answerTextfield = UITextField().with {
        $0.borderStyle = .none
        $0.backgroundColor = .lightGray
    }

    private let submitButton = UIButton(type: .system).with {
        $0.setTitle("Submit", for: .normal)
        $0.backgroundColor = .white
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
        $0.layer.cornerRadius = 4
    }

    private let activityIndicator = UIActivityIndicatorView().with {
        $0.isHidden = true
        $0.hidesWhenStopped = true
    }

    let previousButton = UIBarButtonItem(
        title: "Previous",
        style: .plain, target: nil, action: #selector(previousPressed)
    )

    let nextButton = UIBarButtonItem(
        title: "Next",
        style: .plain, target: nil, action: #selector(nextPressed)
    )

    var navigationItem: UINavigationItem?

    private var isSubmitting: Bool = false {
        didSet {
            isSubmitting
                ? activityIndicator.startAnimating()
                : activityIndicator.stopAnimating()

            submitButton.isEnabled = isSubmitting == false
        }
    }

    private let submitAnswer = Command()
    private let previousQuestion = Command()
    private let nextQuestion = Command()
    private let answerChanged = CommandWith<String>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray

        nextButton.target = self
        previousButton.target = self

        setupStatusView()
        setupQuestionLabel()
        setupAnswerTextfield()
        setupSubmitButton()

        addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupStatusView() {
        let background = UIView().with {
            $0.backgroundColor = .white
        }
        background.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.center.equalTo(background)
        }

        addSubview(background)
        background.snp.makeConstraints { make in
            make.width.equalTo(self)
            make.height.equalTo(44)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
        }
    }

    private func setupSubmitButton() {
        submitButton.addTarget(self, action: #selector(submitPressed), for: .primaryActionTriggered)

        submitButton.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(submitButton)
        }

        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(answerTextfield).offset(64)
            make.centerX.equalTo(self)
        }
    }

    private func setupQuestionLabel() {
        addSubview(questionLabel)
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel).offset(64)
            make.leading.equalTo(self).offset(16)
        }
    }

    private func setupAnswerTextfield() {
        addSubview(answerTextfield)
        answerTextfield.snp.makeConstraints { make in
            make.top.equalTo(questionLabel).offset(64)
            make.leading.equalTo(self).offset(16)
        }

        answerTextfield.reactive.continuousTextValues
            .observeValues { [weak self] text in
                self?.answerChanged.action(text)
            }
    }

    func render(context: Context<QuestionsViewModel.State, QuestionsViewModel.Event>) {
        bindActions(context)
        renderNavigationBar(context)
        renderBanner(context)

        switch context.status {
        case .submitting:
            isSubmitting = true
        default:
            isSubmitting = false
        }

        guard context.questions.isEmpty == false else {
            renderNoQuestions()
            return
        }

        renderQuestion(context)
    }

    private func renderBanner(_ context: Context<QuestionsViewModel.State, QuestionsViewModel.Event>) {
        let hide: Bool

        switch context.status {
        case .submitSuccess:
            bannerView.configureBanner(for: .success, retryTarget: self, retrySelector: #selector(submitPressed))
            hide = false
        case .submitFailure:
            bannerView.configureBanner(for: .failure, retryTarget: self, retrySelector: #selector(submitPressed))
            hide = false
        default:
            hide = true
        }

        UIView.animate(withDuration: 0.25) { [bannerView] in
            bannerView.alpha = hide ? 0 : 1
        }
    }

    private func renderNavigationBar(_ context: Context<QuestionsViewModel.State, QuestionsViewModel.Event>) {
        if let navigationItem = navigationItem {
            navigationItem.title = context.questions.isEmpty
                ? "Questions"
                : "Question \(context.questionIndex + 1)/\(context.questions.count)"
            navigationItem.rightBarButtonItems = [nextButton, previousButton]
            previousButton.isEnabled = context.questionIndex > 0
            nextButton.isEnabled = context.questionIndex < context.questions.count - 1
        }
    }

    private func renderNoQuestions() {
        statusLabel.text = "No questions loaded"
        questionLabel.text = nil
        answerTextfield.text = nil
        answerTextfield.placeholder = nil
    }

    private func renderQuestion(_ context: Context<QuestionsViewModel.State, QuestionsViewModel.Event>) {
        statusLabel.text = "Questions submitted: \(context.submittedCount)"

        let question = context.questions[context.questionIndex]
        questionLabel.text = question.question

        if let answer = question.answer {
            answerTextfield.text = nil
            answerTextfield.placeholder = answer
            answerTextfield.isEnabled = false

            submitButton.setTitle("Already submitted", for: .normal)
            submitButton.isEnabled = false
        } else {
            answerTextfield.text = context.answerText
            answerTextfield.placeholder = "Type your answer here..."
            answerTextfield.isEnabled = true

            submitButton.setTitle("Submit", for: .normal)
            submitButton.isEnabled = context.answerText.isEmpty == false
        }
    }

    private func bindActions(_ context: Context<QuestionsViewModel.State, QuestionsViewModel.Event>) {
        nextQuestion.action = {
            context.send(event: .nextQuestion)
        }

        previousQuestion.action = {
            context.send(event: .previousQuestion)
        }

        submitAnswer.action = {
            let answer: Answer = context.answer.map { $0 } ??
                Answer(
                    id: context.questions[context.questionIndex].id,
                    answer: context.answerText
                )

            context.send(event: .submitAnswer(answer))
        }

        answerChanged.action = { text in
            DispatchQueue.main.async {
                context.send(event: .answerChanged(text))
            }
        }
    }

    @objc
    private func submitPressed() {
        submitAnswer.action()
    }

    @objc
    private func previousPressed() {
        previousQuestion.action()
    }

    @objc
    private func nextPressed() {
        nextQuestion.action()
    }
}
