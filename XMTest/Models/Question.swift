import Foundation
import Tagged

struct Question: Codable {
    let id: Id
    let question: String

    typealias Id = Tagged<Question, Int>
}
