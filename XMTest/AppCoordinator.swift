import UIKit

class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let rootViewController: UINavigationController

    init(window: UIWindow) {
        self.window = window

        self.rootViewController = UINavigationController()

        let vc = ViewController()
        vc.view.backgroundColor = .cyan
        rootViewController.pushViewController(vc, animated: false)
    }

    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}
