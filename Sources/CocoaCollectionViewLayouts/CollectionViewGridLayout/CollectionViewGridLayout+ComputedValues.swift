import AppKit

// computed all value needed to calculate layout attributes

internal extension CollectionViewGridLayout {
    
    func _minimumItemSize(in section: Int) -> NSSize {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, minimumItemSizeInSection: section) ?? minimumItemSize
    }
    
    func _minimumItemWidth(in section: Int) -> CGFloat {
        if scrollDirection == .horizontal {
            return _minimumItemSize(in: section).height
        } else {
            return _minimumItemSize(in: section).width
        }
    }
    
    func _minimumItemHeight(in section: Int) -> CGFloat {
        if scrollDirection == .horizontal {
            return _minimumItemSize(in: section).width
        } else {
            return _minimumItemSize(in: section).height
        }
    }
    
    func _itemGrowDirection(in section: Int) -> CollectionViewGridLayout.GrowDirection {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, itemGrowDirectionInSection: section) ?? itemGrowDirection
    }
    
    func _interItemSpacing(in section: Int) -> CGFloat {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, interItemSpacingInSection: section) ?? interItemSpacing
    }
    
    func _lineSpacing(in section: Int) -> CGFloat {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, lineSpacingInSection: section) ?? lineSpacing
    }
    
    func _sectionInset(in section: Int) -> NSEdgeInsets {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, insetForSection: section) ?? sectionInset
    }
    
    func _maxNumberOfColumns(in section: Int) -> Int {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, maximumNumberOfColumnsInSection: section) ?? maximumNumberOfColumns
    }
    
    func _maximumSectionWidth(in section: Int) -> CGFloat {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, maximumWidthForSection: section) ?? maximumSectionWidth
    }
    
    func _headerReferenceSize(in section: Int) -> NSSize {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, headerReferenceSizeInSection: section) ?? headerReferenceSize
    }
    
    func _headerReferenceHeight(in section: Int, scrollDirection: NSCollectionView.ScrollDirection) -> CGFloat {
        let size = _headerReferenceSize(in: section)
        return scrollDirection == .vertical ? size.height : size.width
    }
    
    func _footerReferenceSize(in section: Int) -> NSSize {
        let delegate = collectionView?.delegate as? CollectionViewDelegateGridLayout
        return delegate?.collectionView?(collectionView!, layout: self, footerReferenceSizeInSection: section) ?? footerReferenceSize
    }
    
    func _footerReferenceHeight(in section: Int, scrollDirection: NSCollectionView.ScrollDirection) -> CGFloat {
        let size = _footerReferenceSize(in: section)
        return scrollDirection == .vertical ? size.height : size.width
    }
    
    func _availableWidth(in section: Int) -> CGFloat {
        guard let collectionView = collectionView else { return 0 }
        
        let maxWidth = _maximumSectionWidth(in: section)
        
        if scrollDirection == .vertical {
            return maxWidth > 0 ? min(collectionView.visibleRect.width, maxWidth) : collectionView.visibleRect.width
        } else {
            return maxWidth > 0 ? min(collectionView.visibleRect.height, maxWidth) : collectionView.visibleRect.height
        }
    }
    
    var _layoutDirection: NSUserInterfaceLayoutDirection {
        return collectionView?.userInterfaceLayoutDirection ?? .leftToRight
    }
    
    func _itemSize(in section: Int) -> NSSize {
        var availableWidth = _availableWidth(in: section) - _computedsectionInset(in: section, scrollDirection: scrollDirection, counter: true)
        let columns = _numberOfColumns(in: section)
        let maxWidth = _maximumSectionWidth(in: section)
        
        if maxWidth > 0 {
            availableWidth = min(maxWidth, availableWidth)
        }
        
        availableWidth -= CGFloat(max(0, columns - 1)) * interItemSpacing
        
        let w = columns == 0 ? minimumItemSize.width : availableWidth / CGFloat(columns)
        
        let h = _itemGrowDirection(in: section) == .bothDirection ? w * _minimumItemHeight(in: section) / _minimumItemWidth(in: section) : _minimumItemHeight(in: section)
        return NSSize(width: w, height: h)
    }
    
    func _numberOfColumns(in section: Int) -> Int {
        var availableWidth = _availableWidth(in: section) - _computedsectionInset(in: section, scrollDirection: scrollDirection, counter: true)
        let itemSize = _minimumItemSize(in: section)
        let maxColumnsCount = _maxNumberOfColumns(in: section)
        
        let minItemWidth: CGFloat
        if scrollDirection == .vertical {
            guard availableWidth >= itemSize.width else {
                NSLog("The collection view width must greater than the minumum item width plus both left and right section inset in section \(section)!")
                return 0
            }
            minItemWidth = itemSize.width
        } else {
            guard availableWidth >= itemSize.height else {
                NSLog("The collection view height must greater than the minumum item height plus both top and bottom section inset in section \(section)!")
                return 0
            }
            minItemWidth = itemSize.height
        }
        
        availableWidth -= minItemWidth
        
        let columns = Int(availableWidth / (minItemWidth + _interItemSpacing(in: section))) + 1
        
        return maxColumnsCount > 0 ? min(maxColumnsCount, columns) : columns
    }
    
    func _numberOfRows(in section: Int) -> Int {
        guard let itemsCount = collectionView?.numberOfItems(inSection: section) else {
            return 0
        }
        
        let columns = _numberOfColumns(in: section)
        return columns == 0 ? 0 : Int(ceil(CGFloat(itemsCount) / CGFloat(columns)))
    }
    
    func _itemsContentHeight(in section: Int) -> CGFloat {
        let itemSize = _itemSize(in: section)
        let lineSpacing = _lineSpacing(in: section)
        let itemHeight = scrollDirection == .vertical ? itemSize.height : itemSize.width
        let rows = CGFloat(_numberOfRows(in: section))
        
        return itemHeight * rows + max(0, rows - 1) * lineSpacing
    }
    
    func _computedsectionInset(in section: Int, scrollDirection: NSCollectionView.ScrollDirection, counter: Bool = false) -> CGFloat {
        let inset = _sectionInset(in: section)
        
        switch (counter, scrollDirection) {
        case (false, .vertical), (true, .horizontal):
            return inset.top + inset.bottom
        default:
            return inset.left + inset.right
        }
        
    }
    
    func _leadingOffset(in section: Int) -> CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let visibleWidth = scrollDirection == .vertical ? collectionView.visibleRect.width : collectionView.visibleRect.height
        let inset = _layoutDirection == .leftToRight ? _sectionInset(in: section).left : _sectionInset(in: section).right
        let dw = visibleWidth - _availableWidth(in: section)
        
        return dw / 2 + inset
    }
    
}
