import XCTest
@testable import CocoaCollectionViewLayouts

final class TrackerTests: XCTestCase {
    
    func testOrigin() {
        
        let rect = NSMakeRect(10, 10, 40, 40)
        
        testTracker(withRect: rect, scrollDirection: .vertical, layoutDirection: .leftToRight) { tracker in
            XCTAssertEqual(tracker.origin, NSMakePoint(rect.minX, rect.minX))
        }
        
        testTracker(withRect: rect, scrollDirection: .vertical, layoutDirection: .rightToLeft) { tracker in
            XCTAssertEqual(tracker.origin, NSMakePoint(rect.maxX, rect.minY))
        }
        
        testTracker(withRect: rect, scrollDirection: .horizontal, layoutDirection: .leftToRight) { tracker in
            XCTAssertEqual(tracker.origin, NSMakePoint(rect.minX, rect.minY))
        }
        
        testTracker(withRect: rect, scrollDirection: .horizontal, layoutDirection: .rightToLeft) { tracker in
            XCTAssertEqual(tracker.origin, NSMakePoint(rect.maxX, rect.minY))
        }
        
    }
    
    func testAdvance() {
        
        let rect = NSMakeRect(10, 10, 40, 40)
        
        testTracker(withRect: rect, scrollDirection: .vertical, layoutDirection: .leftToRight) { tracker in
            tracker.advance(inScrollDirectionBy: 10)
            XCTAssertEqual(tracker.location, NSMakePoint(tracker.origin.x, tracker.origin.y + 10))
            
            tracker.advance(inCounterScrollDirectionBy: 10)
            XCTAssertEqual(tracker.location, NSMakePoint(tracker.origin.x + 10, tracker.origin.y + 10))
        }
        
        testTracker(withRect: rect, scrollDirection: .vertical, layoutDirection: .rightToLeft) { tracker in
            tracker.advance(inScrollDirectionBy: 10)
            XCTAssertEqual(tracker.location, NSMakePoint(tracker.origin.x, tracker.origin.y + 10))
            
            tracker.advance(inCounterScrollDirectionBy: 10)
            XCTAssertEqual(tracker.location, NSMakePoint(tracker.origin.x - 10, tracker.origin.y + 10))
        }
        
        testTracker(withRect: rect, scrollDirection: .horizontal, layoutDirection: .leftToRight) { tracker in
            tracker.advance(inScrollDirectionBy: 10)
            XCTAssertEqual(tracker.location, NSMakePoint(tracker.origin.x + 10, tracker.origin.y))
            
            tracker.advance(inCounterScrollDirectionBy: 10)
            XCTAssertEqual(tracker.location, NSMakePoint(tracker.origin.x + 10, tracker.origin.y + 10))
        }
        
        testTracker(withRect: rect, scrollDirection: .horizontal, layoutDirection: .rightToLeft) { tracker in
            tracker.advance(inScrollDirectionBy: 10)
            XCTAssertEqual(tracker.location, NSMakePoint(tracker.origin.x - 10, tracker.origin.y))
            
            tracker.advance(inCounterScrollDirectionBy: 10)
            XCTAssertEqual(tracker.location, NSMakePoint(tracker.origin.x - 10, tracker.origin.y + 10))
        }
        
    }
    
    func testTracker(withRect rect: NSRect, scrollDirection: NSCollectionView.ScrollDirection, layoutDirection: NSUserInterfaceLayoutDirection, test: (inout NSCollectionViewLayout._Tracker) -> ()) {
        
        var tracker = NSCollectionViewLayout._Tracker(originInRect: rect, scrollDirection: scrollDirection, layoutDirection: layoutDirection)
        test(&tracker)
    }

    static var allTests = [
        ("testOrigin", testOrigin),
        ("testAdvance", testAdvance)
    ]
}
