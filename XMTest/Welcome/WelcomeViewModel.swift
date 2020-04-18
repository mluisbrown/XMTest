import Foundation
import ReactiveSwift
import ReactiveFeedback

enum WelcomeViewModel {
    struct State {
        var status: Status = .initial
    }

    enum Status: Equatable {
        case initial
        case loading
        case loaded([Question])
    }

    enum Event {
        case startSurvey
        case loaded([Question])
    }

    static func reducer(state: inout State, event: Event) {
        switch event {
        case .startSurvey:
            state.status = .loading
        case let .loaded(questions):
            state.status = .loaded(questions)
        }
    }
}

typealias WelcomeStore = Store<WelcomeViewModel.State, WelcomeViewModel.Event>
