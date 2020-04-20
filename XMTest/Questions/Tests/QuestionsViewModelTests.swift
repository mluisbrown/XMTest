import Foundation
import ReactiveSwift
import ReactiveFeedback
import Nimble
import XCTest

@testable import XMTest

class QuestionsViewModelTests: XCTestCase {
    let questions = MockNetwork.mockQuestions

    func test_loaded() {
        perform(
            stub: {
                makeStore(with: QuestionsViewModel.State())
            },
            when: { store in
                store.send(event: .loaded(questions))
            },
            assert: { states, questions, _, _, _ in
                expect(states).to(equal(
                    [
                        .initial,
                        .loaded
                    ]
                ))
                expect(questions).to(equal(self.questions))
            }
        )
    }

    func test_nextQuestion() {
        perform(
            stub: {
                makeStore(with: QuestionsViewModel.State())
            },
            when: { store in
                store.send(event: .loaded(questions))
                store.send(event: .nextQuestion)
            },
            assert: { states, questions, questionIndex, _, _ in
                expect(states).to(equal(
                    [
                        .initial,
                        .loaded,
                        .loaded
                    ]
                ))
                expect(questions).to(equal(self.questions))
                expect(questionIndex).to(equal(1))
            }
        )
    }

    func test_previousQuestion() {
        perform(
            stub: {
                makeStore(with: QuestionsViewModel.State())
            },
            when: { store in
                store.send(event: .loaded(questions))
                store.send(event: .nextQuestion)
                store.send(event: .previousQuestion)
            },
            assert: { states, questions, questionIndex, _, _ in
                expect(states).to(equal(
                    [
                        .initial,
                        .loaded,
                        .loaded,
                        .loaded
                    ]
                ))
                expect(questions).to(equal(self.questions))
                expect(questionIndex).to(equal(0))
            }
        )
    }

    func test_answerChanged() {
        perform(
            stub: {
                makeStore(with: QuestionsViewModel.State())
            },
            when: { store in
                store.send(event: .loaded(questions))
                store.send(event: .answerChanged("42"))
            },
            assert: { states, questions, questionIndex, _, answerText in
                expect(states).to(equal(
                    [
                        .initial,
                        .loaded,
                        .loaded,
                    ]
                ))
                expect(questions).to(equal(self.questions))
                expect(answerText).to(equal("42"))
            }
        )
    }

    func test_submit_withSuccess() {
        Current = .mock
        let answer = Answer(id: 1, answer: "42")
        let scheduler = TestScheduler()

        var postSubmitQuestions = self.questions
        postSubmitQuestions[0].answer = "42"

        perform(
            stub: {
                makeStore(
                    with: QuestionsViewModel.State(),
                    scheduler: scheduler
                )
            },
            when: { store in
                store.send(event: .loaded(questions))
                store.send(event: .answerChanged("42"))
                store.send(event: .submitAnswer(answer))

                scheduler.advance(by: .seconds(4))
            },
            assert: { states, questions, questionIndex, submittedCount, answerText in
                expect(states).to(equal(
                    [
                        .initial,
                        .loaded,
                        .loaded,
                        .submitting(answer),
                        .submitSuccess,
                        .loaded
                    ]
                ))
                expect(questions).to(equal(postSubmitQuestions))
                expect(answerText).to(equal(""))
                expect(submittedCount).to(equal(1))
            }
        )
    }

    func test_submit_withFailure() {
        Current = .failingMock
        let answer = Answer(id: 1, answer: "42")
        let scheduler = TestScheduler()

        perform(
            stub: {
                makeStore(
                    with: QuestionsViewModel.State(),
                    scheduler: scheduler
                )
            },
            when: { store in
                store.send(event: .loaded(questions))
                store.send(event: .answerChanged("42"))
                store.send(event: .submitAnswer(answer))

                scheduler.advance(by: .seconds(4))
            },
            assert: { states, questions, questionIndex, submittedCount, answerText in
                expect(states).to(equal(
                    [
                        .initial,
                        .loaded,
                        .loaded,
                        .submitting(answer),
                        .submitFailure(answer),
                        .loaded
                    ]
                ))
                expect(questions).to(equal(self.questions))
                expect(answerText).to(equal("42"))
                expect(submittedCount).to(equal(0))
            }
        )
    }

    private func makeStore(
        with state: QuestionsViewModel.State,
        scheduler: DateScheduler = QueueScheduler.main
    ) -> QuestionsStore {
        Store(
            initial: state,
            reducer: QuestionsViewModel.reducer,
            feedbacks: [QuestionsViewModel.feedbacks(scheduler)]
        )
    }
}

extension QuestionsViewModelTests {
    func perform(
        stub: () -> QuestionsStore,
        when: (QuestionsStore) -> Void,
        assert: (
            [QuestionsViewModel.Status],
            [Question],
            Int,
            Int,
            String
        ) -> Void
    ) {
        let store = stub()
        var states = [QuestionsViewModel.Status]()

        store.state.producer
            .map(\.status)
            .startWithValues {
                states.append($0)
            }

        when(store)

        let state = store.state.value

        assert(
            states,
            state.questions,
            state.questionIndex,
            state.submittedCount,
            state.answerText
        )
    }
}
