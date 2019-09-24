import Foundation

internal extension NSEdgeInsets {
    var vertical: CGFloat { top + bottom }
    var horizontal: CGFloat { left + right }
}
