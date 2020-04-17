import UIKit
import SnapKit
import ReactiveFeedback

final class WelcomeViewController: UIViewController {
    private let store: Store<WelcomeViewModel.State, WelcomeViewModel.Event>

    private lazy var contentView = WelcomeView()

    init(store: Store<WelcomeViewModel.State, WelcomeViewModel.Event>) {
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

        store.state.producer.startWithValues(contentView.render)
    }
}

final class WelcomeView: UIView {
    private let startSurveyButton = UIButton(type: .system).with {
        $0.setTitle("Start survey", for: .normal)
        $0.backgroundColor = .white
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
        $0.layer.cornerRadius = 4
    }

    private let activityIndicator = UIActivityIndicatorView().with {
        $0.isHidden = true
        $0.hidesWhenStopped = true
    }

    private var isLoading: Bool = false {
        didSet {
            isLoading
                ? activityIndicator.startAnimating()
                : activityIndicator.stopAnimating()

            startSurveyButton.isEnabled = isLoading == false
        }
    }

    private let startSurvey = Command()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .lightGray

        startSurveyButton.addTarget(self, action: #selector(startSurveyPressed), for: .primaryActionTriggered)

        addSubview(startSurveyButton)
        startSurveyButton.snp.makeConstraints { make in
            make.center.equalTo(self)
        }

        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(startSurveyButton)
        }
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(context: Context<WelcomeViewModel.State, WelcomeViewModel.Event>) {
        switch context.status {
        case .initial,
             .loaded:
            isLoading = false
        case .loading:
            isLoading = true
        }

        startSurvey.action = {
            context.send(event: .startSurvey)
        }
    }

    @objc
    private func startSurveyPressed() {
        startSurvey.action()
    }
}
