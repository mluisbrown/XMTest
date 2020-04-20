import UIKit
import SnapKit
import ReactiveFeedback
import ReactiveCocoa

final class QuestionsViewController: UIViewController {
    private let store: Store<QuestionsViewModel.State, QuestionsViewModel.Event>

    private lazy var contentView = QuestionsView()

    init(store: Store<QuestionsViewModel.State, QuestionsViewModel.Event>) {
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

        contentView.navigationItem = navigationItem

        store.state.producer.startWithValues(contentView.render)
    }
}
