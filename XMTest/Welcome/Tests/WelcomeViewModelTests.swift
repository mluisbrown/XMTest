import Foundation
import ReactiveSwift
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
        Current = .mock
        let scheduler = TestScheduler()

        perform(
            stub: {
                makeStore(for: .initial, scheduler: scheduler)
            },
            when: { store in
                store.send(event: .startSurvey)

                scheduler.advance()
            },
            assert: { states in
                expect(states.count).to(equal(3))
                expect(states).to(equal(
                    [
                        .initial,
                        .loading,
                        .loaded(MockNetwork.mockQuestions)
                    ]
                ))
            }
        )
    }

    private func makeStore(
        for status: WelcomeViewModel.Status,
        scheduler: DateScheduler = QueueScheduler.main
    ) -> WelcomeStore {
        Store(
            initial: WelcomeViewModel.State.init(status: status),
            reducer: WelcomeViewModel.reducer,
            feedbacks: [WelcomeViewModel.feedbacks(scheduler)]
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
