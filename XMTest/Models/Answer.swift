import Foundation
import Tagged

struct Answer: Codable, Equatable {
    let id: Question.Id
    let answer: String
}
