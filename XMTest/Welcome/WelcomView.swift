import UIKit
import SnapKit
import ReactiveFeedback

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

        startSurveyButton.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(startSurveyButton)
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(context: Context<WelcomeViewModel.State, WelcomeViewModel.Event>) {
        switch context.status {
        case .initial, .loaded:
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
