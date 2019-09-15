import Cocoa

fileprivate typealias IndexedAttributes<Key: Hashable> = [Key: NSCollectionViewLayoutAttributes]

public enum ItemAlignment {
    case top, left, center, bottom, right
}

public enum LineAlignment {
    case left, bottom, center, right, top, justify
}

/// A custom flow layout for collection view.
public class CollectionViewFlowLayout: NSCollectionViewLayout {

    /// Internal caches for items' layout attributes.
    private var _caches: IndexedAttributes<IndexPath> = [:]
    
    /// Internal caches for headers' layout attributes.
    private var _headerCaches: IndexedAttributes<Int> = [:]
    
    private var _footerCaches: IndexedAttributes<Int> = [:]
    
    // MARK: - Configuring the Scroll Direction
    
    /// The scroll direction of the layout.
    ///
    /// The flow layout scrolls along one axis only, either horizontally or vertically. When the scroll direction is `.vertical`, the width of the content
    /// never exceeds the width of the collection view itself but the height grows as needed to accommodate the current items. When the scroll direction is
    /// `.horizontal`, the height never exceeds the height of the collection view but the width grows as needed.
    ///
    /// The default value of this property is `.vertical`.
    public var scrollDirection: NSCollectionView.ScrollDirection = .vertical {
        didSet { invalidateLayout() }
    }
    
    /// The computed boolean value indacating if it's scroll vertically.
    private var _verticalScrolling: Bool {
        return scrollDirection == .vertical
    }
    

    // MARK: - Configuring the Item Spacing
    
    /// The estimated size of items in the collection view.
    ///
    /// Providing an estimated item size lets the collection view defer some of the calculations needed to determine the size of its content, which can improve
    /// performance. Instead of explicitly computing the size of each item, the flow layout assumes that offscreen items have the estimated size. The estimated
    /// size is used only until an actual value is calculated.
    ///
    /// If the value of this property is not `.zero`, the flow layout uses the estimated size you specified. If all of your items actually have the same size,
    /// use the `itemSize` property to set their size and set this property to `.zero`.
    ///
    /// The default value of this property is `.zero`.
    public var estimatedItemSize: NSSize = .zero
    
    /// The default size to use for items.
    ///
    /// This property contains the default size of items. If you do not provide an estimated size or implement the `collectionView(_:layout:sizeForItemAt:)`
    /// method in your delegate, the flow layout uses this value for the size of each item. All items are set to the same size. This value applies only to
    /// items and not to supplementary views.
    ///
    /// The default value of this property is `(50.0, 50.0)`.
    public var itemSize: NSSize = NSMakeSize(50, 50)
    
    /// The computed size to use for item.
    ///
    /// The flow layout follows a specific set of steps to determine the size of each item. Whenever possible, the flow layout uses previously calculated
    /// information. When that information is not available, it falls back on other techniques to retrieve the size of the item. Specifically, the flow layout
    /// takes the following steps, stopping when it acquires a valid item size:
    ///
    /// 1. Get the size of the item from the already computed layout attributes.
    /// 2. Call the `collectionView(_:layout:sizeForItemAt:)` method of the delegate to get the item size.
    /// 3. Use the `estimatedItemSize` property, if it is not set to `.zero`.
    /// 4. Use the `itemSize` property to get the size.
    ///
    /// - Parameter indexPath: The index path of the item.
    ///
    /// - Returns: The computed size of the item.
    fileprivate func _computedItemSize(at indexPath: IndexPath) -> NSSize {
        if _caches.contains(where: { $0.key == indexPath }), let attributes = _caches[indexPath] {
            return attributes.size
        }
        
        if
            let delegate = collectionView?.delegate as? CollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath)
        {
            return size
        }
        
        if estimatedItemSize != .zero {
            return estimatedItemSize
        }
        
        return itemSize
    }
    
    /// The minimum spacing (in points) to use between rows or columns.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:minimumLineSpacingForSectionAt:)` method, the flow layout object uses the value of
    /// this property to set the spacing between rows or columns.
    ///
    /// For a vertically scrolling layout, the value represents the minimum spacing between successive rows. For a horizontally scrolling layout, the value
    /// represents the minimum spacing between successive columns. This spacing is not applied to the space between the header view and the first line or
    /// between the last line and the footer view.
    ///
    /// When the line spacing is applied to rows of unevenly sized items, the actual spacing between individual items may be greater than the minimum value.
    ///
    /// The default value of this property is `10.0`.
    public var minimumLineSpacing: CGFloat = 10.0
    
    /// The computed minimum spacing (in points) to use between rows or columns.
    ///
    /// The flow layout follows a specific set of steps to determine the spacing between rows or columns. The flow layout takes the following steps, stopping
    /// when it acquires a valid minimum line spacing:
    ///
    /// 1. Call the `collectionView(_:layout:minimumLineSpacingForSectionAt:)` method of the delegate to get the spacing.
    /// 2. Use the `minimumLineSpacing` property to get the spacing.
    ///
    /// - Parameter section: The index of the section whose line spacing is needed.
    ///
    /// - Returns: The computed minimum spacing (in points).
    private func _computedMinimumLineSpacingForSection(at section: Int) -> CGFloat {
        guard
            let delegate = collectionView?.delegate as? CollectionViewDelegateFlowLayout,
            let spacing = delegate.collectionView?(collectionView!, layout: self, minimumLineSpacingForSectionAt: section)
        else {
            return minimumLineSpacing
        }
        
        return spacing
    }
    
    /// The minimum spacing (in points) to use between items in the same row or column.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:minimumInteritemSpacingForSectionAt:)` method, the flow layout object uses the value
    ///  of this property to set the spacing between items in the same line.
    ///
    /// For a vertically scrolling layout, the value represents the minimum spacing between items in the same row. For a horizontally scrolling layout, the
    /// value represents the minimum spacing between items in the same column. The layout object uses this spacing only to compute how many items can fit in
    /// a single row or column. The actual spacing may be increased after the number of items has been determined.
    ///
    /// The default value of this property is `10.0`.
    public var minimumInteritemSpacing: CGFloat = 10.0
    
    /// The computed minimum spacing (in points) to use between items in the same rows or columns.
    ///
    /// The flow layout follows a specific set of steps to determine the spacing between items in the same rows or columns. The flow layout takes the following
    /// steps, stopping when it acquires a valid minimum inter-item spacing:
    ///
    /// 1. Call the `collectionView(_:layout:minimumLineSpacingForSectionAt:)` method of the delegate to get the spacing.
    /// 2. Use the `minimumInteritemSpacing` property to get the spacing.
    ///
    /// - Parameter section: The index of the section whose item spacing is needed.
    ///
    /// - Returns: The computed minimum inter-item spacing (in points).
    private func _computedMinimumInteritemSpacingForSection(at section: Int) -> CGFloat {
        guard
            let delegate = collectionView?.delegate as? CollectionViewDelegateFlowLayout,
            let spacing = delegate.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section)
        else {
            return minimumInteritemSpacing
        }
        
        return spacing
    }
    
    /// The margins used to lay out content in a section.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:insetForSectionAt:)` method, the flow layout object uses the value of this property to
    /// set the margins for each section.
    ///
    /// Section insets reflect the spacing at the outer edges of the section. The margins affect the positioning of the header view, the minimum space on
    /// either side of each line of items, and the distance from the last line to the footer view. The margin insets do not affect the size of the header and
    /// footer views in the nonscrolling direction.
    ///
    /// The default insets are all set to 0.
    public var sectionInset: NSEdgeInsets = NSEdgeInsetsZero
    
    /// The computed margins used to lay out content in a section.
    ///
    /// The flow layout follows a specific set of steps to determine the margins. The flow layout takes the following steps, stopping when it acquires a valid
    /// margins:
    ///
    /// 1. Call the `collectionView(_:layout:insetForSectionAt:)` method of the delegate to get the inset.
    /// 2. Use the `sectionInset` property to get the inset.
    ///
    /// - Parameter section: The index of the section whose item spacing is needed.
    ///
    /// - Returns: The computed section inset.
    private func _computedSectionInsetForSection(at section: Int) -> NSEdgeInsets {
        guard
            let delegate = collectionView?.delegate as? CollectionViewDelegateFlowLayout,
            let inset = delegate.collectionView?(collectionView!, layout: self, insetForSectionAt: section)
        else {
            return sectionInset
        }
        
        return inset
    }
    
    
    // MARK: - Configuring the Item Spacing

    /// The vertical alignment of items in the same row or column.
    ///
    /// For a vertically scrolling layout, the value represents the vertical alignment of items in the same row. For a horizontally scrolling layout, the value
    /// represents the horizontal alignment of items in the same column.
    ///
    /// The flow layout use this value accordingly based on the scroll direction. For example, if you set this value to `.top` or `.left`, flow layout will
    /// align items in the same row on top for vertically scrolling layout and align items in the same column on left for horizontally scrolling layout. Same
    /// goes to `.bottom` and `.right`.
    ///
    /// The default value of this property is `.center`.
    var interitemAlignment: ItemAlignment = .center
    
    /// The horizontal alignment of items in the same row or column in section.
    ///
    /// For a vertically scrolling layout, the value represents the horizontal alignment of items in rows. For a horizontally scrolling layout, the
    /// value represents the vertical alignment of items in columns.
    ///
    /// By default, flow layout adjust the inter-item spacing to justify items on both side. Change this value to `.left` or `.bottom` for left or bottom
    /// aligned items with minimum inter-item spacing and leave the empty space after the last item on row or column, `.right` or `.top` for right or top
    /// aligned items with minimum inter-item spacing and leave the empty space before the first item on row or column. Use `.center` to align items on center
    /// with minimum inter-iten space and leave the empty space on both before the first item on row or column and after the last item on row or column.
    ///
    /// For items alignment of last line in every section, see `lastLineAlignment`.
    ///
    /// The default value if this property is `.justify`.
    var lineAlignment: LineAlignment = .justify
    
    /// The horizontal alignment of items in the same last row or column in secitons.
    ///
    /// For a vertically scrolling layout, the value represents the horizontal alignment of items in the last row. For a horizontally scrolling layout, the
    /// value represents the vertical alignment of items in the last column.
    ///
    /// Flow layout lay out items row by row from left to right for vertically scrolling layout and column by column from top to bottom for horizontally
    /// scrolling layout. Without knowing whether it can fit another item, justifying items in the last row or column can sometimes breaks the visual
    /// consistency.
    ///
    /// By default, flow layout align these items on the left or bottom with minimum inter-item spacing. Specially, if all items in a section has the same
    /// width for vertically scrolling layout or same height for horizontally scrolling layout, it's possible and to align all items in grid. See
    /// `autoAlignLastLineItems` for more details.
    ///
    /// For items alignment of other line in section, see `lineAlignment`.
    ///
    /// The default value if this property is `.left`.
    var lastLineAlignment: LineAlignment = .left
    
    /// Automatically align items in last row or column to previous lines when possible.
    ///
    /// When all items in a section has the same width for vertically scrolling layout or same height for horizontally scrolling layout, flow layout
    /// automatically align these item in grid, specially for items in the last row or column. You can disable this beheavior by setting `false`.
    ///
    /// The default value of this property is `true`.
    var autoAlignLastLineItems: Bool = true
    
    
    // MARK: - Configuring the Supplementary Views
    
    /// The default size to use for section headers.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:referenceSizeForHeaderInSection:)` method, the flow layout object uses the value of
    /// this property as the header size.
    ///
    /// The layout object uses only the value that is appropriate for the current scrolling direction. In other words, the layout object uses only the height
    /// value when the content scrolls vertically, setting the width of the header to the width of the collection view. Similarly, the layout object uses only
    /// the width value when the content scrolls horizontally, setting the header’s height to the height of the collection view. If the size value for the
    /// appropriate dimension is 0, the layout object omits the header entirely.
    ///
    /// The default value of this property is `.zero`.
    public var headerReferenceSize: NSSize = .zero
    
    /// The computed size to use for section headers.
    ///
    /// The flow layout follows a specific set of steps to determine the header size. The flow layout takes the following steps, stopping when it acquires a
    /// valid size:
    ///
    /// 1. Call the `collectionView(_:layout:referenceSizeForHeaderInSection:)` method of the delegate to get the size.
    /// 2. Use the `headerReferenceSize` property to get the default size.
    ///
    /// - Parameter section: The index of the section whose header size is needed.
    ///
    /// - Returns: The computed size to use for section headers.
    private func _computedHeaderReferenceSize(in section: Int) -> NSSize {
        guard
            let delegate = collectionView?.delegate as? CollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView!, layout: self, referenceSizeForHeaderInSection: section)
        else {
            return headerReferenceSize
        }
        
        return size
    }
    
    /// The default size to use for section footers.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:referenceSizeForFooterInSection:)` method, the flow layout object uses the value of
    /// this property as the footer size.
    ///
    /// The layout object uses only the value that is appropriate for the current scrolling direction. In other words, the layout object uses only the height
    /// value when the content scrolls vertically, setting the width of the footer to the width of the collection view. Similarly, the layout object uses only
    /// the width value when the content scrolls horizontally, setting the footer’s height to the height of the collection view. If the size value for the
    /// appropriate dimension is 0, the layout object omits the footer entirely.
    ///
    /// The default value of this property is `.zero`.
    public var footerReferenceSize: NSSize = .zero
    
    /// The computed size to use for section footers.
    ///
    /// The flow layout follows a specific set of steps to determine the footer size. The flow layout takes the following steps, stopping when it acquires a
    /// valid size:
    ///
    /// 1. Call the `collectionView(_:layout:referenceSizeForFooterInSection:)` method of the delegate to get the size.
    /// 2. Use the `footerReferenceSize` property to get the default size.
    ///
    /// - Parameter section: The index of the section whose header size is needed.
    ///
    /// - Returns: The computed size to use for section footers.
    private func _computedFooterReferenceSize(in section: Int) -> NSSize {
        guard
            let delegate = collectionView?.delegate as? CollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView!, layout: self, referenceSizeForFooterInSection: section)
        else {
            return footerReferenceSize
        }
        
        return size
    }
    
    /// A Boolean value indicating whether headers pin to the top of the collection view bounds during scrolling.
    ///
    /// When this property is `true`, section header views scroll with content until they reach the top of the screen, at which point they are pinned to the
    /// upper bounds of the collection view. Each new header view that scrolls to the top of the screen pushes the previously pinned header view offscreen.
    ///
    /// The default value of this property is `false`.
    public var sectionHeadersPinToVisibleBounds: Bool = false
    
    /// A Boolean value indicating whether footers pin to the bottom of the collection view bounds during scrolling.
    ///
    /// When this property is `true`, section footer views scroll with content until they reach the bottom of the screen, at which point they are pinned to the
    /// lower bounds of the collection view. Each new footer view that scrolls to the bottom of the screen pushes the previously pinned `footer` view offscreen.
    ///
    /// The default value of this property is `false`.
    public var sectionFootersPinToVisibleBounds: Bool = false
    
    
    // MARK: - Providing Layout Information
    
    /// Return the total size of its contents, including all supplementary and decoration views.
    override public var collectionViewContentSize: NSSize {
        return _collectionViewContentSize
    }
    
    /// Internel computed collection view content size, writable.
    private var _collectionViewContentSize: NSSize = .zero
    
    override public func prepare() {
        guard let collectionView = collectionView else { return }
        
        var tracker: NSPoint = .zero
        
        // for every section in this collection view...
        for section in 0..<collectionView.numberOfSections {
            tracker = _prepareSectionHeader(in: section, tracker: tracker)
            tracker = _prepareItems(in: section, tracker: tracker)
            tracker = _prepareSectionFooter(in: section, tracker: tracker)
        }
        
        // update collection view content size
        switch scrollDirection {
            case .vertical:
                _collectionViewContentSize.width = collectionView.visibleRect.width
                _collectionViewContentSize.height = tracker.y
                
            case .horizontal:
                _collectionViewContentSize.width = tracker.x
                _collectionViewContentSize.height = collectionView.visibleRect.height
                print(collectionViewContentSize)
        }
        
//        print(collectionViewContentSize)
    }

    private func _prepareSectionHeader(in section: Int, tracker: NSPoint) -> NSPoint {
        var tracker = tracker
        
        // check if we should display the header
        let headerSize = _computedHeaderReferenceSize(in: section)
        let thickness = _verticalScrolling ? headerSize.height : headerSize.width
        
        guard let collectionView = collectionView, thickness != 0 else {
            return tracker
        }
        
        // create an layout attributes for header
        let attributes = NSCollectionViewLayoutAttributes(forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
        
        switch scrollDirection {
            case .vertical:
                tracker.x = 0
                // TODO: modify origin for sticky header
                attributes.frame = NSMakeRect(tracker.x, tracker.y, collectionView.bounds.width, thickness)
                
                // update tracker
                tracker.y += thickness

            case .horizontal:
                tracker.y = 0
                // TODO: modify origin for sticky header
                attributes.frame = NSMakeRect(tracker.x, tracker.y, thickness, collectionView.bounds.height)
                
                // update tracker
                tracker.x += thickness
        }
        
        // store to caches
        _headerCaches[section] = attributes
        
        // return new tracker
        return tracker
    }

    private func _prepareItems(in section: Int, tracker: NSPoint) -> NSPoint {
        guard let collectionView = collectionView else { return tracker }
        var tracker = tracker
        
        let inset = _computedSectionInsetForSection(at: section)
        
        tracker.x += inset.left
        tracker.y += inset.top
        
        var rowAttributes: IndexedAttributes<IndexPath> = [:]
        var rowThicknessTracker: CGFloat = 0
        
        var lastItemWidth: CGFloat?
        var isItemWidthFixed: Bool = true
        
        for item in 0..<collectionView.numberOfItems(inSection: section) {
            let indexPath = IndexPath(item: item, section: section)
            let size = _computedItemSize(at: indexPath)
            let itemSpacing = _computedMinimumInteritemSpacingForSection(at: section)
            var computedItemSpacing: CGFloat { rowAttributes.isEmpty ? 0 : itemSpacing }
            let attributes = NSCollectionViewLayoutAttributes(forItemWith: IndexPath(item: item, section: section))
            
            // ====
            if autoAlignLastLineItems && isItemWidthFixed {
                if lastItemWidth != nil {
                    isItemWidthFixed = lastItemWidth == (_verticalScrolling ? size.width : size.height)
                }
                lastItemWidth = _verticalScrolling ? size.width : size.height
            }
            
            var canFit: Bool
            switch scrollDirection {
            case .vertical:
                canFit = tracker.x + computedItemSpacing + size.width <= collectionView.bounds.width - inset.right
            default:
                canFit = tracker.y + computedItemSpacing + size.height <= collectionView.bounds.height - inset.bottom
            }
            
            if !canFit {
                rowAttributes._adjust(forCollectionViewLayout: self, bounds: collectionView.bounds, rowHeight: rowThicknessTracker)
                
                rowAttributes.forEach({ _caches[$0.key] = $0.value })
                rowAttributes = [:]
                
                tracker.x = _verticalScrolling ? inset.left : tracker.x + rowThicknessTracker + _computedMinimumLineSpacingForSection(at: section)
                tracker.y = _verticalScrolling ? tracker.y + rowThicknessTracker + _computedMinimumLineSpacingForSection(at: section) : inset.top
                
                rowThicknessTracker = 0
            }
            
            let x = _verticalScrolling ? tracker.x + computedItemSpacing : tracker.x
            let y = _verticalScrolling ? tracker.y : tracker.y + computedItemSpacing
            attributes.frame = NSMakeRect(x, y, size.width, size.height)
            
            rowThicknessTracker = _verticalScrolling ? max(size.height, rowThicknessTracker) : max(size.width, rowThicknessTracker)
            tracker.x += _verticalScrolling ? computedItemSpacing + size.width : 0
            tracker.y += _verticalScrolling ? 0 : computedItemSpacing + size.height
            // ====
       
            // store to row caches
            rowAttributes[indexPath] = attributes
        }
        
        // modify origin to align items in the same row
        rowAttributes._adjust(forCollectionViewLayout: self, bounds: collectionView.bounds, rowHeight: rowThicknessTracker, lastRowInSection: true, itemWidthConsistent: isItemWidthFixed)
        
        // move row caches to caches
        rowAttributes.forEach({ _caches[$0.key] = $0.value })
        rowAttributes = [:]
        
        // move tracker
        if _verticalScrolling {
            tracker.x = 0
            tracker.y += rowThicknessTracker + inset.bottom
        } else {
            tracker.y = 0
            tracker.x += rowThicknessTracker + inset.right
        }

        return tracker
    }
    
    private func _prepareSectionFooter(in section: Int, tracker: NSPoint) -> NSPoint {
        var tracker = tracker
        
        let footerSize = _computedFooterReferenceSize(in: section)
        let thickness = _verticalScrolling ? footerSize.height : footerSize.width
        
        guard let collectionView = collectionView, thickness != 0 else {
            return tracker
        }
        
        let attributes = NSCollectionViewLayoutAttributes(forSupplementaryViewOfKind: NSCollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
        
        switch scrollDirection {
        case .vertical:
            tracker.x = 0
            attributes.frame = NSMakeRect(tracker.x, tracker.y, collectionView.bounds.width, thickness)
            tracker.y += thickness
            
        default:
            tracker.y = 0
            attributes.frame = NSMakeRect(tracker.x, tracker.y, thickness, collectionView.bounds.height)
            tracker.x += thickness
        }
        
        _footerCaches[section] = attributes
        
        return tracker
    }
    
    override public func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        // Should we call `layoutAttributesForItem(at:) for item layout? or just ignore it?
        return _caches.compactMap {
            $0.value.frame.intersects(rect) ? $0.value : nil
        } + _headerCaches.compactMap {
            $0.value.frame.intersects(rect) ? $0.value : nil
        } + _footerCaches.compactMap {
            $0.value.frame.intersects(rect) ? $0.value : nil
        }
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return _caches[indexPath]
    }

    public override func layoutAttributesForSupplementaryView(ofKind elementKind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        switch elementKind {
            case NSCollectionView.elementKindSectionHeader:
                return _headerCaches[indexPath.section]
            case NSCollectionView.elementKindSectionFooter:
                return _footerCaches[indexPath.section]
            default: return nil
        }
    }
    
    
    // MARK: - Invalidating the Layout

    /// A visiable bounds tracker, for layout invalidation.
    private var _oldBounds: NSRect = .zero
    
    /// Returns a Boolean indicating whether a bounds change triggers a layout update.
    override public func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        // invalidate layout only when the visible width changed
        let invalidate = _verticalScrolling ? newBounds.width != _oldBounds.width : newBounds.height != _oldBounds.height
        _oldBounds = newBounds
        return invalidate
    }

    /// Returns a Boolean indicating whether changes to a cell’s layout attributes trigger a larger layout update.
//    override public func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: NSCollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: NSCollectionViewLayoutAttributes) -> Bool {
//        return false
//    }

    /// Returns an invalidation context object that defines the portions of the layout that need to be updated.
//    override public func invalidationContext(forBoundsChange newBounds: NSRect) -> NSCollectionViewLayoutInvalidationContext {
//        return super.invalidationContext(forBoundsChange: newBounds)
//    }
        
    /// Returns an invalidation context object that defines the portions of the layout that need to be updated.
//    override public func invalidationContext(forPreferredLayoutAttributes preferredAttributes: NSCollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutInvalidationContext {
//        return super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
//    }
    

    // MARK: -
        
//    override public func prepare(forCollectionViewUpdates updateItems: [NSCollectionViewUpdateItem]) {
//        print(#function)
//        super.prepare(forCollectionViewUpdates: updateItems)
//    }

//    override public func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
//        print(#function)
//        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
//    }
        
    
    // MARK: - Coordinating Animated Changes
        
    /// Prepares the layout object for animated changes to the collection view’s bounds or for the insertion or deletion of items.
//    override public func prepare(forAnimatedBoundsChange oldBounds: NSRect) {
//        print(#function)
//    }
        
    /// Cleans up after any animated changes to the collection view’s bounds or after the insertion or deletion of items.
//    override public func finalizeAnimatedBoundsChange() {
//        print(#function)
//    }
        
        //http://www.programmersought.com/article/8491914974/
        // https://stackoverflow.com/questions/52091074/how-to-animate-a-relayout-of-nscollectionviewlayout-on-bounds-change
        // https://www.objc.io/issues/12-animations/collectionview-animations/
        // https://developer.apple.com/documentation/appkit/nscollectionviewlayout/1533163-finalizeanimatedboundschange
        
    // http://aplus.rs/2019/multi-line-uilabel-self-sizing-layout/
    
        // MARK: - Transitioning Between Layouts
    
}

// MARK: - Helper extension
// Is making a extension a good approch rather then writing another function in layout class?

fileprivate extension IndexedAttributes where Key == IndexPath, Value: NSCollectionViewLayoutAttributes {
    
    
    /// <#Description#>
    /// - Parameter layout: <#layout description#>
    /// - Parameter bounds: <#bounds description#>
    /// - Parameter rowHeight: <#rowHeight description#>
    /// - Parameter lastRowInSection: <#lastRowInSection description#>
    /// - Parameter itemWidthConsistent: <#itemWidthConsistent description#>
    func _adjust(forCollectionViewLayout layout: CollectionViewFlowLayout, bounds: NSRect, rowHeight: CGFloat, lastRowInSection: Bool = false, itemWidthConsistent: Bool = false) {
        guard !isEmpty else { return }
        
        var wantsAlignedAsGrid: Bool {
            lastRowInSection && layout.autoAlignLastLineItems && itemWidthConsistent
        }
        
        var canAlignedAsGrid: Bool {
            layout.lineAlignment == .justify && layout.lastLineAlignment == .left
            || layout.lineAlignment == .justify && layout.lastLineAlignment == .right
        }
        
        let availableWidth = layout.scrollDirection == .vertical
                           ? bounds.size.width - layout.sectionInset.left - layout.sectionInset.right
                           : bounds.size.height - layout.sectionInset.top - layout.sectionInset.bottom
        
        let itemsWidth = layout.scrollDirection == .vertical
                       ? reduce(0, { $0 + $1.value.frame.width })
                       : reduce(0, { $0 + $1.value.frame.height })
        
        var itemSpacing = (lastRowInSection ? layout.lastLineAlignment : layout.lineAlignment) == .justify
                        ? (availableWidth - itemsWidth) / CGFloat(Swift.max(1, count - 1))
                        : layout.minimumInteritemSpacing
        
        if wantsAlignedAsGrid && canAlignedAsGrid {
            let itemWidth = layout.scrollDirection == .vertical ? first!.value.size.width : first!.value.size.height
            let maxItemsInRow = floor((availableWidth - itemWidth) / (itemWidth + layout.minimumInteritemSpacing)) + 1
            itemSpacing = (availableWidth - itemWidth * maxItemsInRow) / Swift.max(1, maxItemsInRow - 1)
        }
        
        // calculate extra leading space needed to align a row or column
        var leadingSpace: CGFloat = 0
        switch lastRowInSection ? layout.lastLineAlignment : layout.lineAlignment {
            case .justify:
                if count == 1 { fallthrough }
            case .center:
                leadingSpace = (availableWidth - itemsWidth - CGFloat(count - 1) * itemSpacing) / 2
            case .right, .top:
                leadingSpace = availableWidth - itemsWidth - CGFloat(count - 1) * itemSpacing
            default: ()
        }

        // temporaty x position tracker
        var x = layout.scrollDirection == .vertical ? layout.sectionInset.left : layout.sectionInset.bottom
        x += leadingSpace
        
        // apply modification
        for attrs in self.sorted(by: { $0.key.item < $1.key.item }).map({ $0.value }) {
            // modify item attributes to match item alignment
            switch (layout.scrollDirection, layout.interitemAlignment) {
                case (.vertical, .center):
                    attrs.frame.origin.y += (rowHeight - attrs.frame.size.height) / 2
                case (.vertical, .bottom), (.vertical, .right):
                    attrs.frame.origin.y += rowHeight - attrs.frame.size.height
                case (.horizontal, .center):
                    attrs.frame.origin.x += (rowHeight - attrs.frame.size.width) / 2
                case (.horizontal, .bottom), (.horizontal, .right):
                    attrs.frame.origin.x += rowHeight - attrs.frame.size.width
                default: ()
            }

            // modify item attributes to match line alignment
            switch layout.scrollDirection {
                case .vertical:
                    attrs.frame.origin.x = x
                    x += attrs.size.width + itemSpacing
                
                default:
                    attrs.frame.origin.y = x
                    x += attrs.size.height + itemSpacing
            }
        }
        
    }
    
}
