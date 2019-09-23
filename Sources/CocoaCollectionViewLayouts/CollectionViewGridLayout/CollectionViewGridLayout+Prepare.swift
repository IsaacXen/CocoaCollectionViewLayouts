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
        var dSize = NSSize.zero
        
        tracker.shiftRelativeY(with: inset)
        tracker.resetRelativeX(with: inset)
        
        [Int](0..<collectionView.numberOfItems(inSection: section)).map { item -> NSCollectionViewLayoutAttributes in
            let indexPath = IndexPath(item: item, section: section)
            
            let mCol = CGFloat(item % colCount)
            let mRow = CGFloat(item / colCount)
            
            let dx = mCol * (itemSize.width + itemSpacing) + tracker.absoluteXCompensation(with: itemSize)
            let dy = mRow * (itemSize.height + lineSpacing) + tracker.absoluteYCompensation(with: itemSize)
            
            let x = tracker.relativeX + dx
            let y = tracker.relativeY + dy
            
            dSize = NSMakeSize(x, y)
            
            let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
            attributes.frame = NSMakeRect(x, y, itemSize.width, itemSize.height)
            
            return attributes
        }.forEach {
            if let indexPath = $0.indexPath {
                _itemCaches[indexPath] = $0
            }
        }
        
        tracker.addToRelativeX(by: dSize.width)
        tracker.addToRelativeY(by: dSize.height)
        
        return tracker
    }
    
    func _prepareSectionHeader(for section: Int, tracker: NSCollectionViewLayout._ODSTracker) -> NSCollectionViewLayout._ODSTracker {
        let size = _headerReferenceSize(in: section)
        let headerHeight = scrollDirection == .vertical ? size.height : size.width
        guard headerHeight >= 0 else { return tracker }
        
        let visibleWidth = _visibleWidth
        
        var tracker = tracker
        
        tracker.resetRelativeX()
        
        let x = tracker.absoluteX
        let y = tracker.absoluteY
        var w = visibleWidth
        var h = headerHeight
        
        if scrollDirection == .horizontal {
            (w, h) = (h, w)
        }
        
        let indexPath = IndexPath(item: 0, section: section)
        let attributes = NSCollectionViewLayoutAttributes(forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader, with: indexPath)
        attributes.frame = NSRect(x: x, y: y, width: w, height: h)
        
        _headerCaches[section] = attributes
        
        tracker.addToRelativeY(by: h)
        
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
