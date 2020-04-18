import Foundation
import ReactiveSwift
import Nimble

import XCTest
@testable import XMTest

class APITests: XCTestCase {
    let questions = [
        Question(id: 1, question: "What's your name?"),
        Question(id: 2, question: "How old are you?")
    ]

    let http200response = HTTPURLResponse(
        url: URL(string: "http://test.com")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!

    func testGetQuestions() {
        let data = try! JSONEncoder().encode(questions)
        let api = API(makeAPIRequest: { _ in
            .init(value: (data, self.http200response))
        })

        var result: Result<[Question], APIError> = .success([])
        api.getQuestions()
            .startWithResult {
                result = $0
            }

        expect(try! result.get()).to(equal(questions))
    }

    func testSubmitAnswer_Success() {
        let answer = Answer(id: 1, answer: "42")
        let api = API { _ in
            .init(value: (Data(), self.http200response))
        }

        var result: Result<Void, APIError> = .success(())
        api.submitAnswer(answer)
            .startWithResult {
                result = $0
            }

        expect(try? result.get()).toNot(beNil())
    }

    func testSubmitAnswer_Failure() {
        let answer = Answer(id: 1, answer: "42")
        let api = API { _ in
            .init(error: .server(400, nil))
        }

        var result: Result<Void, APIError> = .success(())
        api.submitAnswer(answer)
            .startWithResult {
                result = $0
            }

        expect(try? result.get()).to(beNil())
        if case let .failure(error) = result {
            expect(error).to(equal(.network(.server(400, nil))))
        } else {
            XCTFail("Expected a failure, but didn't get one.")
        }
    }
}
