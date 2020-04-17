import Foundation
import SnapshotTesting
import XCTest

@testable import XMTest
import ReactiveFeedback


class WelcomeViewControllerTests: XCTestCase {

    func testInitial() {
        let vc = WelcomeViewController(
            store: Store(
                initial: WelcomeViewModel.State.init(status: .initial),
                reducer: WelcomeViewModel.reduce,
                feedbacks: []
            )
        )

        assertSnapshot(matching: vc, as: .image)
    }
}
