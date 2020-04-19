import UIKit
import ReactiveSwift
import ReactiveFeedback

class QuestionsCoordinator: Coordinator {

    private let presenter: UINavigationController
    private var quesionsViewController: QuestionsViewController?
    private let store: Store<State, Event>

    init(
        presenter: UINavigationController,
        store: Store<State, Event>
    ) {
        self.presenter = presenter
        self.store = store
    }

    func start() {
        let questionsStore = store.view(value: \.questions, event: Event.questions)
        let questionsViewController = QuestionsViewController(
            store: questionsStore
        )
        questionsViewController.title = "Questions"

        presenter.pushViewController(questionsViewController, animated: true)
        self.quesionsViewController = questionsViewController
    }
}
