import AppKit

internal extension CollectionViewGridLayout {
    
    /// Calculate the content size needed to fit all items.
    func _prepareContentSize() {
        guard let collectionView = collectionView else { return }
        
        var sizeTracker = NSCollectionViewLayout._Tracker(originInRect: .zero, scrollDirection: scrollDirection, layoutDirection: .leftToRight)
        
        for section in 0..<collectionView.numberOfSections {
            // header height
            sizeTracker.advance(inScrollDirectionBy: _headerReferenceHeight(in: section, scrollDirection: scrollDirection))
            // footer height
            sizeTracker.advance(inScrollDirectionBy: _footerReferenceHeight(in: section, scrollDirection: scrollDirection))
            // items height
            sizeTracker.advance(inScrollDirectionBy: _itemsContentHeight(in: section) + _computedsectionInset(in: section, scrollDirection: scrollDirection))
        }
        
        let visibleContentSize = collectionView.visibleRect.size
        let contentWidth = scrollDirection == .vertical ? visibleContentSize.width : visibleContentSize.height
        sizeTracker.advance(inCounterScrollDirectionBy: contentWidth)
        
        _contentSize.width = sizeTracker.location.x
        _contentSize.height = sizeTracker.location.y
        
        print(_contentSize, _numberOfColumns(in: 0), _numberOfRows(in: 0), _itemSize(in: 0))
    }
    
    func _prepareTracker() -> NSCollectionViewLayout._Tracker {
        return .init(originInRect: NSRect(origin: .zero, size: _contentSize), scrollDirection: scrollDirection, layoutDirection: _layoutDirection)
    }
    
    func _prepareItems(in section: Int, tracker: NSCollectionViewLayout._Tracker) -> NSCollectionViewLayout._Tracker {
        guard let collectionView = collectionView else { return tracker }
        
        let itemSize = _itemSize(in: section)
        let columns = _numberOfColumns(in: section)
        let rows = _numberOfRows(in: section)
        let interItemSpacing = _interItemSpacing(in: section)
        let lineSpacing = _lineSpacing(in: section)
        let leadingOffset = _leadingOffset(in: section)
        let topInset = _sectionInset(in: section).top
        
        let rtlOffset = _layoutDirection == .rightToLeft ? (scrollDirection == .vertical ? itemSize.width : -itemSize.width) : 0
        
        guard columns > 0, rows > 0 else { return tracker }
        
        Array(0..<collectionView.numberOfItems(inSection: section)).forEach { item in
            let indexPath = IndexPath(item: item, section: section)
            let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
            
            var c = item % columns
            var r = Int(ceil(CGFloat(item + 1) / CGFloat(columns)))

            if scrollDirection == .horizontal {
                (c, r) = (r, c)
                c = max(0, c - 1)
                r = r + 1
            }

            let dx = CGFloat(max(0, c)) * (itemSize.width + interItemSpacing)
            let dy = CGFloat(max(0, r - 1)) * (itemSize.height + lineSpacing)
            
            let x: CGFloat
            let y: CGFloat
            
            if _layoutDirection == .rightToLeft && scrollDirection == .horizontal {
                x = tracker.advancing(inScrollDirectionBy: dx + leadingOffset + rtlOffset)
                y = tracker.advancing(inCounterScrollDirectionBy: dy + topInset)
            } else {
                x = tracker.advancing(inCounterScrollDirectionBy: dx + leadingOffset + rtlOffset)
                y = tracker.advancing(inScrollDirectionBy: dy + topInset)
            }
            
            attributes.frame = NSMakeRect(x, y, itemSize.width, itemSize.height)
            
            _caches[indexPath] = attributes
        }
        
        var tracker = tracker
        tracker.advance(inScrollDirectionBy: _itemsContentHeight(in: section))
        return tracker
    }
    
    func _prepareSectionHeader(for section: Int, tracker: NSPoint) -> NSPoint {
        return tracker
    }
    
    func _prepareSectionFooter(for section: Int, tracker: NSPoint) -> NSPoint {
        return tracker
    }
    
    func _updateLayoutAttributesForRightToLeftLayoutIfNeeded() {
        guard _layoutDirection == .rightToLeft else { return }
        // && scrollDirection == .horizontal
        
    }
    
}
