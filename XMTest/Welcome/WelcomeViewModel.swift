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
    }

    enum Event {
        case startSurvey
    }

    static func reduce(state: inout State, event: Event) {
        print("event: \(event)")

        switch event {
        case .startSurvey:
            state.status = .loading
        }
    }
}
