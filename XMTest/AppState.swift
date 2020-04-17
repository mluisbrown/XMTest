import Foundation

struct State {
    var welcome = WelcomeViewModel.State()
}

enum Event {
    case welcome(WelcomeViewModel.Event)

    // This can be done with CasePaths
    // https://github.com/pointfreeco/swift-case-paths
    var welcome: WelcomeViewModel.Event? {
        get {
            guard case let .welcome(value) = self else { return nil }
            return value
        }
        set {
            guard case .welcome = self, let newValue = newValue else { return }
            self = .welcome(newValue)
        }
    }
}
