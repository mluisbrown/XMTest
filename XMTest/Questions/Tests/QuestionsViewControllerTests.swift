import Foundation
import SnapshotTesting
import XCTest
import ReactiveFeedback

@testable import XMTest

class QuestionsViewContollerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
    }

    func testLoaded() {
        let vc = makeViewController(
            status: .loaded,
            questions: MockNetwork.mockQuestions
        )

        let navigation = UINavigationController(rootViewController: vc)

        assertSnapshot(matching: navigation, as: .image)
    }

    func testLoaded_LastQuestion() {
        let vc = makeViewController(
            status: .loaded,
            questions: MockNetwork.mockQuestions,
            questionIndex: 1
        )

        let navigation = UINavigationController(rootViewController: vc)

        assertSnapshot(matching: navigation, as: .image)
    }

    func testSubmitting() {
        let vc = makeViewController(
            status: .submitting(Answer(id: 1, answer: "Arnold")),
            questions: MockNetwork.mockQuestions,
            answerText: "Arnold"
        )

        let navigation = UINavigationController(rootViewController: vc)

        assertSnapshot(matching: navigation, as: .image)
    }

    func testAnswer() {
        let vc = makeViewController(
            status: .loaded,
            questions: MockNetwork.mockQuestions,
            answerText: "Arnold"
        )

        let navigation = UINavigationController(rootViewController: vc)

        assertSnapshot(matching: navigation, as: .image)
    }

    func testAnswered() {
        var questions = MockNetwork.mockQuestions
        questions[0].answer = "Arnold"

        let vc = makeViewController(
            status: .loaded,
            questions: questions,
            submittedCount: 1
        )

        let navigation = UINavigationController(rootViewController: vc)

        assertSnapshot(matching: navigation, as: .image)
    }

    func testSubmitSuccess() {
        var questions = MockNetwork.mockQuestions
        questions[0].answer = "Arnold"

        let vc = makeViewController(
            status: .submitSuccess,
            questions: questions,
            submittedCount: 1
        )

        let navigation = UINavigationController(rootViewController: vc)

        assertSnapshot(matching: navigation, as: .image)
    }

    func testSubmitFailure() {
        let questions = MockNetwork.mockQuestions

        let vc = makeViewController(
            status: .submitFailure(Answer(id: 1, answer: "Arnold")),
            questions: questions,
            submittedCount: 1,
            answerText: "Arnold"
        )

        let navigation = UINavigationController(rootViewController: vc)

        assertSnapshot(matching: navigation, as: .image)
    }

    private func makeViewController(
        status: QuestionsViewModel.Status,
        questions: [Question] = [],
        questionIndex: Int = 0,
        submittedCount: Int = 0,
        answerText: String = ""
    ) -> QuestionsViewController {
        QuestionsViewController(
            store: Store(
                initial: QuestionsViewModel.State.init(
                    status: status,
                    questions: questions,
                    questionIndex: questionIndex,
                    submittedCount: submittedCount,
                    answerText: answerText
                ),
                reducer: QuestionsViewModel.reducer,
                feedbacks: []
            )
        )
    }

}
