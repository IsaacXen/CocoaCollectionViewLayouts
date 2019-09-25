import AppKit

internal extension CollectionViewGridLayout {
    
    /// Calculate the content size needed to fit all items, headers and footers.
    func _prepareContentSize() -> NSSize {
        guard let collectionView = collectionView else { return .zero }
        
        var size: NSSize = .zero
        
        switch scrollDirection {
            case .vertical:
                size.width = collectionView.enclosingScrollView?.bounds.width ?? collectionView.visibleRect.width

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
                    
                size.height = collectionView.enclosingScrollView?.bounds.height ?? collectionView.visibleRect.width
            
            @unknown default: ()
        }
        
        return size
    }
    
    func _prepareItems(in section: Int, tracker: NSCollectionViewLayout._ODSTracker) -> NSCollectionViewLayout._ODSTracker {
        guard let collectionView = collectionView else { return tracker }
                    
        let itemSpacing = _interItemSpacing(in: section)
        let lineSpacing = _lineSpacing(in: section)
        
        let colCount = _numberOfColumns(in: section)
        let rowCount = _numberOfRows(in: section)
        let itemSize = _itemSize(in: section)
        let itemWidth = scrollDirection == .vertical ? itemSize.width : itemSize.height
        let itemHeight = scrollDirection == .vertical ? itemSize.height : itemSize.width
        let inset = _sectionInset(in: section) + _sectionContentInset(in: section)
        
        guard colCount > 0 else { return tracker }
        
        var tracker = tracker
        
        tracker.shiftRelativeY(with: inset)
        tracker.resetRelativeX(with: inset)
        
        tracker.save()
        
        [Int](0..<collectionView.numberOfItems(inSection: section)).map { item -> NSCollectionViewLayoutAttributes in
            let indexPath = IndexPath(item: item, section: section)
            
            let mCol = CGFloat(item % colCount)
            let mRow = CGFloat(item / colCount)
            
            let dx = mCol * (itemWidth + itemSpacing)
            let dy = mRow * (itemHeight + lineSpacing)

            tracker.addToRelativeX(by: dx)
            tracker.addToRelativeY(by: dy)
            
            let x = tracker.absoluteX + tracker.absoluteXCompensation(with: itemSize)
            let y = tracker.absoluteY + tracker.absoluteYCompensation(with: itemSize)
            
            tracker.load()
            
            let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
            attributes.frame = NSMakeRect(x, y, itemSize.width, itemSize.height)
            
            return attributes
        }.forEach {
            if let indexPath = $0.indexPath {
                _itemCaches[indexPath] = $0
            }
        }
        
        let contentHeight = CGFloat(rowCount) * itemHeight + CGFloat(max(0, rowCount - 1)) * lineSpacing
        
        tracker.addToRelativeY(by: contentHeight)
        
        let trailingInset = scrollDirection == .vertical ? inset.bottom : _layoutDirection == .leftToRight ? inset.right : inset.left
        tracker.addToRelativeY(by: trailingInset)
        
        return tracker
    }
    
    func _prepareSectionHeader(for section: Int, tracker: NSCollectionViewLayout._ODSTracker) -> NSCollectionViewLayout._ODSTracker {
        let size = _headerReferenceSize(in: section)
        let headerHeight = scrollDirection == .vertical ? size.height : size.width
        guard headerHeight >= 0 else { return tracker }
        
        let visibleWidth = _visibleWidth
        
        var tracker = tracker
        
        tracker.resetRelativeX()
        
        var w = visibleWidth
        var h = headerHeight
        
        if scrollDirection == .horizontal {
            (w, h) = (h, w)
        }
        
        let x = tracker.absoluteX + tracker.absoluteXCompensation(with: NSMakeSize(w, h))
        let y = tracker.absoluteY + tracker.absoluteYCompensation(with: NSMakeSize(w, h))
        
        let indexPath = IndexPath(item: 0, section: section)
        let attributes = NSCollectionViewLayoutAttributes(forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader, with: indexPath)
        attributes.frame = NSRect(x: x, y: y, width: w, height: h)
        
        _headerCaches[section] = attributes
        
        tracker.addToRelativeY(by: headerHeight)
        
        return tracker
    }
    
    func _prepareSectionFooter(for section: Int, tracker: NSCollectionViewLayout._ODSTracker) -> NSCollectionViewLayout._ODSTracker {
        let size = _footerReferenceSize(in: section)
        let footerHeight = scrollDirection == .vertical ? size.height : size.width
        guard footerHeight >= 0 else { return tracker }
        
        let visibleWidth = _visibleWidth
        
        var tracker = tracker
        
        tracker.resetRelativeX()
        
        var w = visibleWidth
        var h = footerHeight
        
        if scrollDirection == .horizontal {
            (w, h) = (h, w)
        }
        
        let x = tracker.absoluteX + tracker.absoluteXCompensation(with: NSMakeSize(w, h))
        let y = tracker.absoluteY + tracker.absoluteYCompensation(with: NSMakeSize(w, h))
        
        let indexPath = IndexPath(item: 0, section: section)
        let attributes = NSCollectionViewLayoutAttributes(forSupplementaryViewOfKind: NSCollectionView.elementKindSectionFooter, with: indexPath)
        attributes.frame = NSRect(x: x, y: y, width: w, height: h)
        
        _footerCaches[section] = attributes
        
        tracker.addToRelativeY(by: footerHeight)
        
        return tracker
    }
    
}
