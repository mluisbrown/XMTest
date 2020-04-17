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
        case loaded
    }

    enum Event {
        case startSurvey
    }

    static func reduce(state: inout State, event: Event) {
        
    }
}
