import UIKit

class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let rootViewController: UINavigationController

    init(window: UIWindow) {
        self.window = window

        self.rootViewController = UINavigationController()

        let vc = ViewController()
        
    }


    func start() {
        <#code#>
    }
}
