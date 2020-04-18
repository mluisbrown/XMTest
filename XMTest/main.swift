import UIKit

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
