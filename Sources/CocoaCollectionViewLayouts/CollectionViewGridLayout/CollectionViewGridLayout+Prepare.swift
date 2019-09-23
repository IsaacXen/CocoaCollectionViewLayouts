import AppKit

internal extension CollectionViewGridLayout {
    
    /// Calculate the content size needed to fit all items, headers and footers.
    func _prepareContentSize() -> NSSize {
        guard let collectionView = collectionView else { return .zero }
        
        var size: NSSize = .zero
        
        switch scrollDirection {
            case .vertical:
                size.width = collectionView.visibleRect.width

                size.height = Array(0..<collectionView.numberOfSections).reduce(0, {
                    let rows = CGFloat(_numberOfRows(in: $1))
                    return $0 + _headerReferenceSize(in: $1).height
                        + _footerReferenceSize(in: $1).height
                        + _sectionInset(in: $1).vertical
                        + rows * _itemSize(in: $1).height
                        + max(0, rows - 1) * _lineSpacing(in: $1)
                })
            
            case .horizontal:
                size.width = Array(0..<collectionView.numberOfSections).reduce(0, {
                    let rows = CGFloat(_numberOfRows(in: $1))
                    return $0 + _headerReferenceSize(in: $1).width
                        + _footerReferenceSize(in: $1).width
                        + _sectionInset(in: $1).horizontal
                        + rows * _itemSize(in: $1).width
                        + max(0, rows - 1) * _lineSpacing(in: $1)
                })
                    
                size.height = collectionView.visibleRect.height
            
            @unknown default: ()
        }
        
        return size
    }
    
    func _prepareItems(in section: Int, tracker: NSCollectionViewLayout._ODSTracker) -> NSCollectionViewLayout._ODSTracker {
        guard let collectionView = collectionView else { return tracker }
                    
        let itemSpacing = _interItemSpacing(in: section)
        let lineSpacing = _lineSpacing(in: section)
        
        let colCount = _numberOfColumns(in: section)
//        let rowCount = _numberOfRows(in: section)
        let itemSize = _itemSize(in: section)
        let inset = _sectionInset(in: section) + _sectionContentInset(in: section)
        
        var tracker = tracker
        
        tracker.shiftRelativeY(with: inset)
        tracker.resetRelativeX(with: inset)
        
        var lastRow = 0
        
        for item in 0..<collectionView.numberOfItems(inSection: section) {
            let indexPath = IndexPath(item: item, section: section)
            
            let mCol = CGFloat(item % colCount)
//            let col = CGFloat((item + 1) % colCount)
            
            let mRow = item / colCount
//            let row = CGFloat((item + 1) / colCount)
            
            /*     col 3   row
             0 ->  0 1     0 0
             1 ->  1 2     0 0
             2 ->  2 0     0 1
             3 ->  0 1     1 1
             4 ->  1 2     1 1
             */
            
            if mRow != lastRow {
                tracker.relativeY += tracker.relativeHeight(of: itemSize)
                tracker.relativeY += lineSpacing
                
                tracker.resetRelativeX(with: inset)
                lastRow = mRow
            }
            
            let dx = itemSize.width + itemSpacing + tracker.absoluteXCompensation(with: itemSize)
            tracker.relativeX += dx
            
            let x = tracker.absoluteX
            let y = tracker.absoluteY
            
            let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
            attributes.frame = NSRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
            
            _itemCaches[indexPath] = attributes
        }
        
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
