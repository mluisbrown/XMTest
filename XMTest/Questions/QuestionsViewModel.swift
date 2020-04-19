import Foundation
import ReactiveSwift
import ReactiveFeedback

enum QuestionsViewModel {
    struct State {
        var status: Status = .initial
        var questions: [Question] = []
    }

    enum Status: Equatable {
        case initial
    }
}
