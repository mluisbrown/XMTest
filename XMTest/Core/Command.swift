import Foundation

final class Command {
    var action: () -> Void = {}
}

final class CommandWith<T> {
    var action: (T) -> Void = { _ in }
}
