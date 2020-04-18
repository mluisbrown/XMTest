import Foundation

enum APIError: Error, Equatable {
    case network(NetworkError)
    case data(String)
}

func dataErrorDescription(_ error: Error) -> String {
    switch error {
    case DecodingError.dataCorrupted(let context),
         DecodingError.keyNotFound(_, let context),
         DecodingError.typeMismatch(_, let context):
        return context.debugDescription
    default:
        return error.localizedDescription
    }
}
