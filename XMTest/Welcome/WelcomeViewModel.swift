import Foundation
import ReactiveSwift
import ReactiveFeedback

enum WelcomeViewModel {
    struct State {
        var status: Status = .initial

        var isLoading: Bool {
            switch status {
            case .loading:
                return true
            default:
                return false
            }
        }

        var route: Route? {
            switch status {
            case .loaded:
                return .showQuestions
            default:
                return nil
            }
        }
    }

    enum Status: Equatable {
        case initial
        case loading
        case loaded([Question])
    }

    enum Event {
        case startSurvey
        case loaded([Question])
        case reset
    }

    enum Route {
        case showQuestions
    }

    static func reducer(state: inout State, event: Event) {
        switch event {
        case .startSurvey:
            state.status = .loading
        case let .loaded(questions):
            state.status = .loaded(questions)
        case .reset:
            state.status = .initial
        }
    }

    static func feedbacks(
        _ scheduler: DateScheduler = QueueScheduler.main
    ) -> FeedbackLoop<State, Event>.Feedback {
        return .combine(
            questionsFeedback(scheduler)
        )
    }

    private static func questionsFeedback(_ scheduler: DateScheduler) -> FeedbackLoop<State, Event>.Feedback {
        return .init(predicate: { $0.isLoading }) { state in
            return Current.api.getQuestions()
                .map(Event.loaded)
                .flatMapError { _ in
                    SignalProducer.init(value: .loaded([]))
                }
                .observe(on: scheduler)
        }
    }
}

typealias WelcomeStore = Store<WelcomeViewModel.State, WelcomeViewModel.Event>
