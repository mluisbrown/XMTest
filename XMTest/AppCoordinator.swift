import UIKit
import ReactiveSwift
import ReactiveFeedback

class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let rootViewController: UINavigationController
    private let welcomeCoordinator: WelcomeCoordinator
    private let store: Store<State, Event>

    init(window: UIWindow) {
        self.window = window
        self.rootViewController = UINavigationController()

        let appReducer: Reducer<State, Event> = combine(
            pullback(
                WelcomeViewModel.reducer,
                value: \.welcome,
                event: \.welcome
            ),
            pullback(
                QuestionsViewModel.reducer,
                value: \.questions,
                event: \.questions
            )
        )

        let appFeedbacks: FeedbackLoop<State, Event>.Feedback = FeedbackLoop<State, Event>.Feedback.combine(
            FeedbackLoop<State, Event>.Feedback.pullback(
                feedback: WelcomeViewModel.feedbacks(),
                value: \.welcome,
                event: Event.welcome
            ),
            FeedbackLoop<State, Event>.Feedback.pullback(
                feedback: QuestionsViewModel.feedbacks(),
                value: \.questions,
                event: Event.questions
            )
        )

        store = Store(
            initial: State(),
            reducer: appReducer,
            feedbacks: [appFeedbacks]
        )

        welcomeCoordinator = WelcomeCoordinator(
            presenter: rootViewController,
            store: store
        )
    }

    func start() {
        window.rootViewController = rootViewController
        welcomeCoordinator.start()
        window.makeKeyAndVisible()
    }
}
