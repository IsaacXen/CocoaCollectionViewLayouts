import Foundation

internal func +(lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> NSEdgeInsets {
    return NSEdgeInsetsMake(lhs.top + rhs.top, lhs.left + rhs.left, lhs.bottom + rhs.bottom, lhs.right + rhs.right)
}
