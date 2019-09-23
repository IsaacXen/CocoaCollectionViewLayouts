import AppKit

internal extension NSCollectionViewLayout {
    
    /// Oingle-Dimension-Scrolling Tracker.
    struct _ODSTracker {
        
        /// The origin point of tracker.
        public let origin: NSPoint
        
        ///
        private(set) var location: NSPoint
        
        ///
        public let scrollDirection: NSCollectionView.ScrollDirection
        
        ///
        public let layoutDirection: NSUserInterfaceLayoutDirection
        
        init(origin: NSPoint, scrollDirection: NSCollectionView.ScrollDirection, layoutDirection: NSUserInterfaceLayoutDirection) {
            self.origin = origin
            self.location = origin
            self.scrollDirection = scrollDirection
            self.layoutDirection = layoutDirection
        }
        
        init(originInRect rect: NSRect, scrollDirection: NSCollectionView.ScrollDirection, layoutDirection: NSUserInterfaceLayoutDirection) {
            let origin: NSPoint
            
            switch (scrollDirection, layoutDirection) {
                case (.vertical,   .leftToRight): origin = NSMakePoint(rect.minX, rect.minY)
                case (.vertical,   .rightToLeft): origin = NSMakePoint(rect.maxX, rect.minY)
                case (.horizontal, .leftToRight): origin = NSMakePoint(rect.minX, rect.minY)
                case (.horizontal, .rightToLeft): origin = NSMakePoint(rect.maxX, rect.minY)
                @unknown default: origin = .zero
            }
            
            self.init(origin: origin, scrollDirection: scrollDirection, layoutDirection: layoutDirection)
        }
        
        public var absoluteX: CGFloat {
            get { location.x }
            set { location.x = newValue }
        }
        
        public var absoluteY: CGFloat {
            get { location.y }
            set { location.y = newValue }
        }
        
        public var relativeX: CGFloat {
            get {
                switch (scrollDirection, layoutDirection) {
                    case (.vertical,   .leftToRight): return location.x - origin.x
                    case (.vertical,   .rightToLeft): return origin.x - location.x
                    case (.horizontal, .leftToRight): return location.y - origin.y
                    case (.horizontal, .rightToLeft): return location.y - origin.y
                    @unknown default: return .nan
                }
            }
            
            set {
                switch (scrollDirection, layoutDirection) {
                    case (.vertical,   .leftToRight): location.x += newValue
                    case (.vertical,   .rightToLeft): location.x -= newValue
                    case (.horizontal, .leftToRight): location.y += newValue
                    case (.horizontal, .rightToLeft): location.y += newValue
                    @unknown default: ()
                }
            }
        }
        
        public var relativeY: CGFloat {
            get {
                switch (scrollDirection, layoutDirection) {
                    case (.vertical,   .leftToRight): return location.y - origin.y
                    case (.vertical,   .rightToLeft): return location.y - origin.y
                    case (.horizontal, .leftToRight): return location.x - origin.x
                    case (.horizontal, .rightToLeft): return origin.x - location.x
                    @unknown default: return .nan
                }
            }
            
            set {
                switch (scrollDirection, layoutDirection) {
                    case (.vertical,   .leftToRight): location.y += newValue
                    case (.vertical,   .rightToLeft): location.y += newValue
                    case (.horizontal, .leftToRight): location.x += newValue
                    case (.horizontal, .rightToLeft): location.x -= newValue
                    @unknown default: ()
                }
            }
        }
        
        public func relativeXCompensation(with itemSize: NSSize) -> CGFloat {
            switch (scrollDirection, layoutDirection) {
                case (.vertical,   .leftToRight): return 0
                case (.vertical,   .rightToLeft): return -itemSize.width
                case (.horizontal, .leftToRight): return 0
                case (.horizontal, .rightToLeft): return 0
                @unknown default: return .nan
            }
        }
        
        public func relativeYCompensation(with itemSize: NSSize) -> CGFloat {
            switch (scrollDirection, layoutDirection) {
                case (.vertical,   .leftToRight): return 0
                case (.vertical,   .rightToLeft): return 0
                case (.horizontal, .leftToRight): return 0
                case (.horizontal, .rightToLeft): return -itemSize.width
                @unknown default: return .nan
            }
        }
        
        public func absoluteXCompensation(with itemSize: NSSize) -> CGFloat {
            switch (scrollDirection, layoutDirection) {
                case (.vertical,   .leftToRight): return 0
                case (.vertical,   .rightToLeft): return -itemSize.width
                case (.horizontal, .leftToRight): return 0
                case (.horizontal, .rightToLeft): return -itemSize.width
                @unknown default: return .nan
            }
        }
        
        public func absoluteYCompensation(with itemSize: NSSize) -> CGFloat {
            switch (scrollDirection, layoutDirection) {
                case (.vertical,   .leftToRight): return 0
                case (.vertical,   .rightToLeft): return 0
                case (.horizontal, .leftToRight): return 0
                case (.horizontal, .rightToLeft): return 0
                @unknown default: return .nan
            }
        }
        
        public mutating func resetRelativeX(with inset: NSEdgeInsets = NSEdgeInsetsZero) {
            switch (scrollDirection, layoutDirection) {
                case (.vertical,   .leftToRight): location.x = origin.x + inset.left
                case (.vertical,   .rightToLeft): location.x = origin.x - inset.right
                case (.horizontal, .leftToRight): location.y = origin.y + inset.top
                case (.horizontal, .rightToLeft): location.y = origin.y + inset.top
                @unknown default: ()
            }
        }
        
        public mutating func resetRelativeY(with inset: NSEdgeInsets = NSEdgeInsetsZero) {
            switch (scrollDirection, layoutDirection) {
                case (.vertical,   .leftToRight): location.y = origin.y + inset.top
                case (.vertical,   .rightToLeft): location.y = origin.y + inset.top
                case (.horizontal, .leftToRight): location.x = origin.x + inset.left
                case (.horizontal, .rightToLeft): location.x = origin.x - inset.right
                @unknown default: ()
            }
        }
        
        public func relativeWidth(of size: NSSize) -> CGFloat {
            switch scrollDirection {
                case .vertical:   return size.width
                case .horizontal: return size.height
                @unknown default: return 0
            }
        }
        
        public func relativeHeight(of size: NSSize) -> CGFloat {
            switch scrollDirection {
                case .vertical:   return size.height
                case .horizontal: return size.width
                @unknown default: return 0
            }
        }
        
        public mutating func shiftRelativeX(with inset: NSEdgeInsets) {
            switch (scrollDirection, layoutDirection) {
                case (.vertical,   .leftToRight): relativeX += inset.left
                case (.vertical,   .rightToLeft): relativeX += inset.right
                case (.horizontal, .leftToRight): relativeX += inset.top
                case (.horizontal, .rightToLeft): relativeX += inset.top
                @unknown default: ()
            }
        }
        
        public mutating func shiftRelativeY(with inset: NSEdgeInsets) {
            switch (scrollDirection, layoutDirection) {
                case (.vertical,   .leftToRight): relativeY += inset.top
                case (.vertical,   .rightToLeft): relativeY += inset.top
                case (.horizontal, .leftToRight): relativeY += inset.left
                case (.horizontal, .rightToLeft): relativeY += inset.right
                @unknown default: ()
            }
        }
    }

}


