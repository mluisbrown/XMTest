import UIKit

/// the `MockAppDelegate` is used when running tests to avoid actually running the
/// application during tests. This makes tests run faster as they don't have to wait
/// for the app to load.
final class MockAppDelegate: UIResponder, UIApplicationDelegate {}

private func isRunningTests() -> Bool {
    NSClassFromString("XCTestCase") != nil
}

private func appDelegateClassName() -> String {
    return NSStringFromClass(isRunningTests() ? MockAppDelegate.self : AppDelegate.self)
}

_ = UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    NSStringFromClass(UIApplication.self),
    appDelegateClassName()
)
