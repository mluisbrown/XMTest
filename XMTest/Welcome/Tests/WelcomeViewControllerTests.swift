import Foundation
import SnapshotTesting
import XCTest
import ReactiveFeedback

@testable import XMTest

class WelcomeViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
    }

    func testInitial() {
        let vc = makeViewController(for: .initial)
        assertSnapshot(matching: vc, as: .image)
    }

    func testLoading() {
        let vc = makeViewController(for: .loading)
        assertSnapshot(matching: vc, as: .image)
    }

    private func makeViewController(
        for status: WelcomeViewModel.Status
    ) -> WelcomeViewController {
        WelcomeViewController(
            store: Store(
                initial: WelcomeViewModel.State.init(status: status),
                reducer: WelcomeViewModel.reducer,
                feedbacks: []
            )
        )
    }
}
