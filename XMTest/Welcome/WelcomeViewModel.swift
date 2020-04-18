import Foundation
import ReactiveSwift
import ReactiveFeedback

enum WelcomeViewModel {
    struct State {
        var status: Status = .initial
    }

    enum Status {
        case initial
        case loading
        case loaded([Question])
    }

    enum Event {
        case startSurvey
        case loaded([Question])
    }

    static func reduce(state: inout State, event: Event) {
        print("event: \(event)")

        switch event {
        case .startSurvey:
            state.status = .loading
        case let .loaded(questions):
            state.status = .loaded(questions)
        }
    }
}
