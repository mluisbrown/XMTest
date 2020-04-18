import Foundation

typealias Query = [String: String]

enum Method: String {
    case OPTIONS
    case GET
    case HEAD
    case POST
    case PUT
    case PATCH
    case DELETE
    case TRACE
    case CONNECT
}

struct Resource: CustomStringConvertible {
    let path: String
    let method: Method
    let body: Data?
    let query: Query

    init(path: String, method: Method, body: Data? = nil, query: Query = [:]) {
        self.path = path
        self.method = method
        self.body = body
        self.query = query
    }

    var description: String {
        return "Path:\(path)\nMethod:\(method.rawValue)\nQuery:\(query)"
    }
}

extension Resource {

    /// Used to transform a Resource into a URLRequest
    func toRequest(_ baseURL: URL) -> URLRequest {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)

        components?.queryItems = createQueryItems(query)
        components?.path = path

        let finalURL = components?.url ?? baseURL
        let request = NSMutableURLRequest(url: finalURL)

        request.httpBody = body
        request.httpMethod = method.rawValue

        return request as URLRequest
    }

    private func createQueryItems(_ query: Query) -> [URLQueryItem]? {
        guard query.isEmpty == false else { return nil }

        return query.map { (key, value) in
            return URLQueryItem(name: key, value: value)
        }
    }
}
