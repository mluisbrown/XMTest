import UIKit
import SnapKit
import ReactiveFeedback

final class QuestionsViewController: UIViewController {
    private let store: Store<QuestionsViewModel.State, QuestionsViewModel.Event>

    private lazy var contentView = QuestionsView()

    init(store: Store<QuestionsViewModel.State, QuestionsViewModel.Event>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        contentView.navigationItem = navigationItem

        store.state.producer.startWithValues(contentView.render)
    }
}

final class QuestionsView: UIView {
    private let statusLabel = UILabel().with {
        $0.text = "Questions submitted: 0"
    }

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
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .vertical)
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray

        nextButton.target = self
        previousButton.target = self

        setupStatusView()
        setupQuestionLabel()
        setupAnswerTextfield()
        setupSubmitButton()
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
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(context: Context<QuestionsViewModel.State, QuestionsViewModel.Event>) {
        if let navigationItem = navigationItem {
            navigationItem.title = context.questions.isEmpty
                ? "Questions"
                : "Question \(context.questionIndex + 1)/\(context.questions.count)"
            navigationItem.rightBarButtonItems = [nextButton, previousButton]
            previousButton.isEnabled = context.questionIndex > 0
            nextButton.isEnabled = context.questionIndex < context.questions.count - 1
        }

        switch context.status {
        case .submitting:
            isSubmitting = true
        default:
            isSubmitting = false
        }

        nextQuestion.action = {
            context.send(event: .nextQuestion)
        }

        previousQuestion.action = {
            context.send(event: .previousQuestion)
        }

        submitAnswer.action = {
            context.send(event: .submitAnswer(Answer(id: 1, answer: "Dummy answer")))
        }

        guard context.questions.isEmpty == false else { return }

        let question = context.questions[context.questionIndex]
        questionLabel.text = question.question

        if let answer = question.answer {
            answerTextfield.text = answer
            answerTextfield.isEnabled = false

            submitButton.setTitle("Already submitted", for: .normal)
            submitButton.isEnabled = false

        } else {
            answerTextfield.placeholder = "Type your answer here..."
            answerTextfield.isEnabled = true

            submitButton.setTitle("Submit", for: .normal)
            submitButton.isEnabled = true
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
