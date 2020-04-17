import UIKit
import ReactiveSwift
import ReactiveFeedback

class WelcomeCoordinator: Coordinator {

    private let presenter: UINavigationController
    private let store: Store<WelcomeViewModel.State, WelcomeViewModel.Event>

    init(
        presenter: UINavigationController,
        store: Store<WelcomeViewModel.State, WelcomeViewModel.Event>
    ) {
        self.presenter = presenter
        self.store = store
    }

    func start() {
        <#code#>
    }

}

