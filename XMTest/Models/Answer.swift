import Foundation
import Tagged

struct Answer: Codable {
    let id: Question.Id
    let answer: String
}
