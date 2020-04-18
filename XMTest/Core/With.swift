import Foundation

protocol With {}

extension With {
    internal func with(_ action: (inout Self) -> Void) -> Self {
        var copy = self
        action(&copy)
        return copy
    }
}

extension NSObject: With {}
