import Foundation
import ReactiveSwift
import Tagged

typealias HTTPStatusCode = Tagged<NetworkError, Int>

enum NetworkError: Error, Equatable {
    enum ClientError: Equatable {
        case timedOut
        case unreachable(URLError)
        case offline(URLError)
        case other(Error)

        public static func == (lhs: NetworkError.ClientError, rhs: NetworkError.ClientError) -> Bool {
            switch (lhs, rhs) {
            case (.timedOut, .timedOut),
                 (.unreachable, .unreachable),
                 (.offline, .offline),
                 (.other, .other):
                return true
            default:
                return false
            }
        }
    }

    case client(ClientError)
    case server(HTTPStatusCode, Data?)
}

typealias Response = SignalProducer<(Data, URLResponse), NetworkError>

final class Network {
    let session: URLSession
    let baseURL: URL

    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default), baseURL: URL) {
        self.session = session
        self.baseURL = baseURL
    }

    func makeRequest(_ resource: Resource) -> Response {
        return SignalProducer { observer, lifetime in
            let request = resource.toRequest(self.baseURL)

            let task = self.session.dataTask(with: request) { data, response, error in
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300:
                        observer.send(value: (data ?? Data(), response))
                        observer.sendCompleted()
                    default:
                        observer.send(error: .server(HTTPStatusCode(rawValue: response.statusCode), data))
                    }
                } else {
                    // If the response is empty, there must be an error.
                    let error = error!

                    switch error {
                    case let error as URLError:
                        switch error.code {
                        case .timedOut:
                            observer.send(error: .client(.timedOut))
                        case .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed, .secureConnectionFailed:
                            observer.send(error: .client(.unreachable(error)))
                        case .notConnectedToInternet, .dataNotAllowed, .internationalRoamingOff, .callIsActive, .networkConnectionLost:
                            observer.send(error: .client(.offline(error)))
                        case .cancelled:
                            observer.sendInterrupted()

                        default:
                            observer.send(error: .client(.other(error)))
                        }
                    default:
                        observer.send(error: .client(.other(error)))
                    }
                }

            }

            lifetime += AnyDisposable(task.cancel)
            task.resume()
        }
    }

    deinit {
        self.session.invalidateAndCancel()
    }
}

#if DEBUG
final class MockNetwork {
    private let submitShouldFail: Bool

    init(submitFails: Bool = false) {
        self.submitShouldFail = submitFails
    }

    func makeRequest(_ resource: Resource) -> Response {
        let questions = [
            Question(id: 1, question: "What's your name?"),
            Question(id: 2, question: "How old are you?")
        ]

        let urlResponse = HTTPURLResponse(
            url: URL(string: "http://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let response: Response
        switch resource.path {
        case API.Endpoints.questions.rawValue:
            let data = try! JSONEncoder().encode(questions)
            response = SignalProducer.init(value: (data, urlResponse))
        case API.Endpoints.submit.rawValue:
            response = submitShouldFail ?
                SignalProducer.init(error: .server(400, nil)) :
                SignalProducer.init(value: (Data(), urlResponse))
        default:
            response = SignalProducer.init(error: .server(404, nil))
        }

        return response.observe(on: QueueScheduler.main)
    }
}
#endif

