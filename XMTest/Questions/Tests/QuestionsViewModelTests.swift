import Foundation
import ReactiveFeedback
import Nimble
import XCTest

@testable import XMTest

class QuestionsViewModelTests: XCTestCase {

    func test_loaded() {
        perform(
            stub: {
                makeStore(with: QuestionsViewModel.State())
            },
            when: { store in
                store.send(event: .loaded([]))
            },
            assert: { states, _ in
                expect(states.count).to(equal(2))
                expect(states).to(equal(
                    [
                        .initial,
                        .loaded
                    ]
                ))
            }
        )
    }

    private func makeStore(
        with state: QuestionsViewModel.State
    ) -> QuestionsStore {
        Store(
            initial: state,
            reducer: QuestionsViewModel.reducer,
            feedbacks: []
        )
    }
}

extension QuestionsViewModelTests {
    func perform(
        stub: () -> QuestionsStore,
        when: (QuestionsStore) -> Void,
        assert: ([QuestionsViewModel.Status], [Question]) -> Void
    ) {
        let store = stub()
        var states = [QuestionsViewModel.Status]()

        store.state.producer
            .map(\.status)
            .startWithValues {
                states.append($0)
            }

        when(store)
        assert(states, store.state.value.questions)
    }
}
