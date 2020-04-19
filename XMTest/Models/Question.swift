import Foundation
import Tagged

struct Question: Codable, Equatable {
    let id: Id
    let question: String
    var answer: String? = nil

    typealias Id = Tagged<Question, Int>
}
