//
//  File.swift
//  
//
//  Created by Isaac Chen on 2019/9/15.
//

import AppKit

internal extension NSCollectionViewLayout {
    
    struct _Tracker {
        
        var location: NSPoint = .zero
        
        let origin: NSPoint
        
        let scrollDirection: NSCollectionView.ScrollDirection
        
        let layoutDirection: NSUserInterfaceLayoutDirection
        
        init(originInRect rect: NSRect, scrollDirection: NSCollectionView.ScrollDirection, layoutDirection: NSUserInterfaceLayoutDirection) {
            
            switch layoutDirection {
                case .leftToRight: origin = NSPoint(x: rect.minX, y: rect.minY)
                case .rightToLeft: origin = NSPoint(x: rect.maxX, y: rect.minY)
                default: origin = .zero
            }
            
            self.scrollDirection = scrollDirection
            self.layoutDirection = layoutDirection
            
            location = origin
        }
        
        mutating func advance(inScrollDirectionBy value: CGFloat) {
            switch (scrollDirection, layoutDirection) {
                case (.vertical  , _           ): location.y += value
                case (.horizontal, .leftToRight): location.x += value
                case (.horizontal, .rightToLeft): location.x -= value
                default: ()
            }
        }
        
        func advancing(inScrollDirectionBy value: CGFloat) -> CGFloat {
            switch (scrollDirection, layoutDirection) {
                case (.vertical  , _           ): return location.y + value
                case (.horizontal, .leftToRight): return location.x + value
                case (.horizontal, .rightToLeft): return location.x - value
                default: return 0
            }
        }
        
        mutating func advance(inCounterScrollDirectionBy value: CGFloat) {
            switch (scrollDirection, layoutDirection) {
                case (.vertical  , .leftToRight): location.x += value
                case (.vertical  , .rightToLeft): location.x -= value
                case (.horizontal, _           ): location.y += value
                default: ()
            }
        }
        
        func advancing(inCounterScrollDirectionBy value: CGFloat) -> CGFloat {
            switch (scrollDirection, layoutDirection) {
                case (.vertical  , .leftToRight): return location.x + value
                case (.vertical  , .rightToLeft): return location.x - value
                case (.horizontal, _           ): return location.y + value
                default: return 0
            }
        }
    
        mutating func rewind(inScrollDirectionBy value: CGFloat) {
            advance(inScrollDirectionBy: -value)
        }
        
        mutating func rewind(inCounterScrollDirectionBy value: CGFloat) {
            advance(inCounterScrollDirectionBy: -value)
        }

        mutating func resetInScrollDirection(with offset: CGFloat = 0) {
            switch (scrollDirection, layoutDirection) {
                case (.vertical  , _           ): location.y = origin.y + offset
                case (.horizontal, .leftToRight): location.x = origin.x + offset
                case (.horizontal, .rightToLeft): location.x = origin.x - offset
                default: ()
            }
        }
        
        mutating func resetInCounterScrollDirection(with offset: CGFloat = 0) {
            switch (scrollDirection, layoutDirection) {
                case (.vertical  , .leftToRight): location.x = origin.x + offset
                case (.vertical  , .rightToLeft): location.x = origin.x - offset
                case (.horizontal, _           ): location.y = origin.y + offset
                default: ()
            }
        }
        
    }
    
}


