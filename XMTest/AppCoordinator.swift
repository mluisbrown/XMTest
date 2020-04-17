import UIKit
import ReactiveSwift
import ReactiveFeedback

class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let rootViewController: UINavigationController
    private let store: Store<State, Event>

    init(window: UIWindow) {
        self.window = window
        self.rootViewController = UINavigationController()

        let appReducer: Reducer<State, Event> = combine(
            pullback(
                WelcomeViewModel.reduce,
                value: \.welcome,
                event: \.welcome
            )
        )

//        let appFeedbacks: FeedbackLoop<State, Event>.Feedback = FeedbackLoop<State, Event>.Feedback.combine(
//            FeedbackLoop<State, Event>.Feedback.pullback(
//                feedback: Movies.feedback,
//                value: \.movies,
//                event: Event.movies
//            )
//        )
        store = Store(
            initial: State(),
            reducer: appReducer,
            feedbacks: []
        )

        let vc = ViewController()
        vc.view.backgroundColor = .cyan
        rootViewController.pushViewController(vc, animated: false)
    }

    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}
