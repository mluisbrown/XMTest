import UIKit
import ReactiveSwift
import ReactiveFeedback

class WelcomeCoordinator: Coordinator {

    private let presenter: UINavigationController
    private var welcomeViewController: WelcomeViewController?
    private let store: Store<State, Event>

    private var questionsCoordinator: QuestionsCoordinator?

    init(
        presenter: UINavigationController,
        store: Store<State, Event>
    ) {
        self.presenter = presenter
        self.store = store
    }

    func start() {
        let welcomeStore = store.view(value: \.welcome, event: Event.welcome)
        let welcomeViewController = WelcomeViewController(
            store: welcomeStore
        )
        welcomeViewController.title = "Welcome"
        welcomeViewController
            .navigationItem.backBarButtonItem = UIBarButtonItem(
                title: nil,
                style: .plain,
                target: nil,
                action: nil
        )

        welcomeStore.state.signal
            .map(\.status)
            .observeValues { status in
                switch status {
                case let .loaded(questions):
                    self.store.send(event: .welcome(.reset))
                    self.store.send(event: .questions(.loaded(questions)))
                default:
                    break;
                }
        }

        welcomeStore.state.signal
            .compactMap(\.route)
            .observeValues { route in
                switch route {
                case .showQuestions:
                    self.showQuestions()
                }
            }

        presenter.pushViewController(welcomeViewController, animated: true)
        self.welcomeViewController = welcomeViewController
    }

    func showQuestions() {
        questionsCoordinator = QuestionsCoordinator(
            presenter: presenter,
            store: store
        )

        questionsCoordinator?.start()
    }
}
