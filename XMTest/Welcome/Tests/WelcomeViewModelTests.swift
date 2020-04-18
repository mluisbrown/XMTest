import Foundation
import ReactiveFeedback
import Nimble
import XCTest

@testable import XMTest

class WelcomeViewModelTests: XCTestCase {

    func test_startSurvey() {
        perform(
            stub: {
                makeStore(for: .initial)
            },
            when: { store in
                store.send(event: .startSurvey)
            },
            assert: { states in
                expect(states.count).to(equal(2))
                expect(states).to(equal(
                    [
                        .initial,
                        .loading
                    ]
                ))
            }
        )
    }

    func test_startSurvey_loaded() {
        let questions = [
            Question(id: 1, question: "What's your name?"),
            Question(id: 2, question: "How old are you?")
        ]

        perform(
            stub: {
                makeStore(for: .initial)
            },
            when: { store in
                store.send(event: .startSurvey)
                store.send(event: .loaded(questions))
            },
            assert: { states in
                expect(states.count).to(equal(3))
                expect(states).to(equal(
                    [
                        .initial,
                        .loading,
                        .loaded(questions)
                    ]
                ))
            }
        )
    }

    private func makeStore(
        for status: WelcomeViewModel.Status
    ) -> WelcomeStore {
        Store(
            initial: WelcomeViewModel.State.init(status: status),
            reducer: WelcomeViewModel.reducer,
            feedbacks: []
        )
    }
}

extension WelcomeViewModelTests {
    func perform(
        stub: () -> WelcomeStore,
        when: (WelcomeStore) -> Void,
        assert: ([WelcomeViewModel.Status]) -> Void
    ) {
        let store = stub()
        var states = [WelcomeViewModel.Status]()

        store.state.producer
            .map(\.status)
            .startWithValues {
                states.append($0)
            }

        when(store)
        assert(states)
    }
}
