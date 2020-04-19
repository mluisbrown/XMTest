import UIKit
import ReactiveSwift
import ReactiveFeedback

class WelcomeCoordinator: Coordinator {

    private let presenter: UINavigationController
    private var welcomeViewController: WelcomeViewController?
    private let store: Store<State, Event>

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

        presenter.pushViewController(welcomeViewController, animated: true)
        self.welcomeViewController = welcomeViewController
    }
}
