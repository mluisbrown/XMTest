import Foundation
import ReactiveSwift
import ReactiveFeedback

enum QuestionsViewModel {
    struct State {
        var status: Status = .initial
        var questions: [Question] = []
        var questionIndex: Int = 0
        var submittedCount: Int = 0
        var answerText: String = ""

        var answer: Answer? {
            switch status {
            case let .submitting(answer),
                 let .submitFailure(answer):
                return answer
            default:
                return nil
            }
        }

        var submittingAnswer: Answer? {
            switch status {
            case let .submitting(answer):
                return answer
            default:
                return nil
            }
        }

        var showingBanner: Bool {
            switch status {
            case .submitFailure,
                 .submitSuccess:
                return true
            default:
                return false
            }
        }

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
        case submitSuccess
        case submitFailure(Answer)
        case submitting(Answer)
    }

    enum Event {
        case loaded([Question])
        case submitAnswer(Answer)
        case submitted(Answer)
        case submitFailed(Answer)
        case answerChanged(String)
        case nextQuestion
        case previousQuestion
        case hideBanner
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

            state.answerText = ""
            state.submittedCount += 1
            state.status = .submitSuccess
        case let .submitFailed(answer):
            state.status = .submitFailure(answer)
        case .nextQuestion:
            state.questionIndex += 1
            state.answerText = ""
        case .previousQuestion:
            state.questionIndex -= 1
            state.answerText = ""
        case let .answerChanged(text):
            state.answerText = text
        case .hideBanner:
            state.status = .loaded
        }
    }

    static var feedback: FeedbackLoop<State, Event>.Feedback {
        return .combine(
            submitFeedback(),
            bannerFeedback()
        )
    }

    private static func submitFeedback() -> FeedbackLoop<State, Event>.Feedback {
        return .init(lensing: { $0.submittingAnswer }) { answer in
            Current.api.submitAnswer(answer)
                .map { Event.submitted(answer) }
                .flatMapError { _ in
                    SignalProducer.init(value: .submitFailed(answer))
                }
                .observe(on: UIScheduler())
        }
    }

    private static func bannerFeedback() -> FeedbackLoop<State, Event>.Feedback {
        return .init(predicate: { $0.showingBanner }) { state in
            SignalProducer.init(value: Event.hideBanner)
                .delay(3, on: QueueScheduler.main)
        }
    }
}
