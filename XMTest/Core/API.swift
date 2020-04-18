import Foundation
import ReactiveSwift

struct API {
    enum Endpoints: String {
        case questions = "/questions"
        case submit = "/question/submit"
    }

    let makeAPIRequest: (Resource) -> Response

    init(
        makeAPIRequest: @escaping (Resource) -> Response
    ) {
        self.makeAPIRequest = makeAPIRequest
    }

    func getQuestions() -> SignalProducer<[Question], APIError> {
        let resource = Resource(path: Endpoints.questions.rawValue, method: .GET)

        return makeAPIRequest(resource)
            .mapError(APIError.network)
            .attemptMap { dataAndResponse  in
                let (data, _) = dataAndResponse
                do {
                    return try .success(JSONDecoder().decode([Question].self, from: data))
                } catch {
                    return .failure(APIError.data(dataErrorDescription(error)))
                }
            }
    }

    func submitAnswer(_ answer: Answer) -> SignalProducer<Void, APIError> {
        let data: Data
        do {
            data = try JSONEncoder().encode(answer)
        } catch {
            return .init(error: APIError.data(dataErrorDescription(error)))
        }

        let resource = Resource(path: Endpoints.submit.rawValue, method: .POST, body: data)

        return makeAPIRequest(resource)
            .map(value: ())
            .mapError(APIError.network)
    }
}


