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
        let vc = makeViewControllerFor(status: .initial)
        assertSnapshot(matching: vc, as: .image)
    }

    func testLoading() {
        let vc = makeViewControllerFor(status: .loading)
        assertSnapshot(matching: vc, as: .image)
    }

    private func makeViewControllerFor(
        status: WelcomeViewModel.Status
    ) -> WelcomeViewController {
        return WelcomeViewController(
            store: Store(
                initial: WelcomeViewModel.State.init(status: status),
                reducer: WelcomeViewModel.reduce,
                feedbacks: []
            )
        )
    }
}
