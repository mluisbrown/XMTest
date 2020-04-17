import UIKit
import SnapKit
import ReactiveFeedback

final class WelcomeViewController: UIViewController {
    private let store: Store<WelcomeViewModel.State, WelcomeViewModel.Event>

    private lazy var contentView = WelcomeView()

    init(store: Store<WelcomeViewModel.State, WelcomeViewModel.Event>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        store.state.producer.startWithValues(contentView.render)
    }
}


final class WelcomeView: UIStackView {

    func render(context: Context<WelcomeViewModel.State, WelcomeViewModel.Event>) {

    }

}
