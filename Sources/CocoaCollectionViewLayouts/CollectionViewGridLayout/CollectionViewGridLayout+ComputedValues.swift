import AppKit

// computed all value needed to calculate layout attributes

internal extension CollectionViewGridLayout {
    
    func _minimumItemSize(in section: Int) -> NSSize {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        let size = delegate?.collectionView?(collectionView!, layout: self, minimumItemSizeForItemsInSection: section) ?? minimumItemSize
        
        if size.width <= 0 || size.height <= 0 {
            return NSSize(width: 50, height: 50)
        }
        
        return size
    }
    
    func _itemGrowDirection(in section: Int) -> CollectionViewGridLayout.GrowDirection {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, growDirectionForItemsInSection: section) ?? itemGrowDirection
    }
    
    func _interItemSpacing(in section: Int) -> CGFloat {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        let spacing = delegate?.collectionView?(collectionView!, layout: self, interItemSpacingForSection: section) ?? interItemSpacing
        return max(0, spacing)
    }
    
    func _lineSpacing(in section: Int) -> CGFloat {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        let spacing = delegate?.collectionView?(collectionView!, layout: self, lineSpacingForSection: section) ?? lineSpacing
        return max(0, spacing)
    }
    
    func _sectionInset(in section: Int) -> NSEdgeInsets {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        var inset = delegate?.collectionView?(collectionView!, layout: self, insetForSection: section) ?? sectionInset
        
        inset.top = max(0, inset.top)
        inset.left = max(0, inset.left)
        inset.right = max(0, inset.right)
        inset.bottom = max(0, inset.bottom)
        
        return inset
    }
    
    func _maxNumberOfColumns(in section: Int) -> Int {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, maximumNumberOfColumnsInSection: section) ?? maximumNumberOfColumns
    }
    
    func _maximumSectionWidth(in section: Int) -> CGFloat {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        let maxWidth = delegate?.collectionView?(collectionView!, layout: self, maximumWidthInSection: section) ?? maximumSectionWidth
        return maxWidth > 0 ? maxWidth : .greatestFiniteMagnitude
    }
    
    func _headerReferenceSize(in section: Int) -> NSSize {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, referenceSizeForHeaderInSection: section) ?? headerReferenceSize
    }
    
    func _footerReferenceSize(in section: Int) -> NSSize {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, referenceSizeForFooterInSection: section) ?? footerReferenceSize
    }
    
    // MARK: -
    
    var _visibleWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return scrollDirection == .vertical ? collectionView.visibleRect.width : collectionView.visibleRect.height
    }
    
    func _contentWidth(in section: Int) -> CGFloat {
        return scrollDirection == .vertical ? _visibleWidth - _sectionInset(in: section).horizontal : _visibleWidth - _sectionInset(in: section).vertical
    }
    
    func _availableWidth(in section: Int) -> CGFloat {
//        guard let collectionView = collectionView else { return 0 }

        let contentWidth = _contentWidth(in: section)
        let maxWidth = _maximumSectionWidth(in: section)
        
        return min(contentWidth, maxWidth)
    }
    
    var _layoutDirection: NSUserInterfaceLayoutDirection {
        return collectionView?.userInterfaceLayoutDirection ?? .leftToRight
    }
    
    func _itemSize(in section: Int) -> NSSize {
        let columns = _numberOfColumns(in: section)
        let itemGap = _interItemSpacing(in: section)
        let gaps = max(0, CGFloat(columns)) * itemGap
        let availableWidth = _availableWidth(in: section) - gaps
        let minItemSize = _minimumItemSize(in: section)
        
        let w = columns == 0 ? minItemSize.width : availableWidth / CGFloat(columns)
        let h: CGFloat
        
        if _itemGrowDirection(in: section) == .bothDirection {
            let ratio = minItemSize.height / minItemSize.width
            h = w * ratio
        } else {
            h = minItemSize.height
        }
        
        return NSSize(width: w, height: h)
    }
    
    func _numberOfColumns(in section: Int) -> Int {
        var availableWidth = _availableWidth(in: section)
        let minItemWidth = scrollDirection == .vertical ? _minimumItemSize(in: section).width : _minimumItemSize(in: section).height
        let itemGap = _interItemSpacing(in: section)
        let maxColumns = _maxNumberOfColumns(in: section)
        
        guard availableWidth >= minItemWidth else {
            NSLog("The collection view's width (in vertically scrolling layout) or height (in horizontally scrolling layout) must greater than the minumum item width (or height) plus both left (or top) and right (or bottom) section inset!")
            return 0
        }
        
        availableWidth -= minItemWidth
        
        let columns = Int(availableWidth / (minItemWidth + itemGap)) + 1
        
        return maxColumns > 0 ? min(maxColumns, columns) : columns
    }
    
    func _numberOfRows(in section: Int) -> Int {
        guard let itemsCount = collectionView?.numberOfItems(inSection: section) else {
            return 0
        }
        
        let columns = _numberOfColumns(in: section)
        return columns == 0 ? 0 : Int(ceil(CGFloat(itemsCount) / CGFloat(columns)))
    }

    func _sectionContentInset(in section: Int) -> NSEdgeInsets {
        let availableWidth = _availableWidth(in: section)
        let contentWidth = _contentWidth(in: section)
        
        let inset = (availableWidth - contentWidth) / 2
        
        switch scrollDirection {
            case .horizontal:
                return NSEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
            default:
                return NSEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        }
    }
    
}
