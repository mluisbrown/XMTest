import Foundation
import ReactiveSwift
import ReactiveFeedback

enum QuestionsViewModel {
    struct State {
        var status: Status = .initial
        var questions: [Question] = []
        var questionIndex: Int = 0
        var submittedCount: Int = 0

        init(_ questions: [Question] = []) {
            self.questions = questions
            status = .loaded
            questionIndex = 0
            submittedCount = 0
        }
    }

    enum Status: Equatable {
        case initial
        case loaded
        case submitting(Answer)
    }

    enum Event {
        case loaded([Question])
        case submitAnswer(Answer)
        case submitted(Answer)
        case nextQuestion
        case previousQuestion
    }

    static func reducer(state: inout State, event: Event) {
        switch event {
        case let .loaded(questions):
            state = State(questions)
        case let .submitAnswer(answer):
            state.status = .submitting(answer)
        case let .submitted(answer):
            state.questions = state.questions.map {
                var copy = $0
                if copy.id == answer.id {
                    copy.answer = answer.answer
                }
                return copy
            }

            state.submittedCount += 1
            state.status = .loaded
        case .nextQuestion:
            state.questionIndex += 1
        case .previousQuestion:
            state.questionIndex -= 1
        }
    }
}
