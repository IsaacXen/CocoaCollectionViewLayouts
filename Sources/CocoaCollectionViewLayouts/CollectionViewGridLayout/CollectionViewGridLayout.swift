import AppKit

/// A layout that displays multiple sections of items in a row and column grid.
public class CollectionViewGridLayout: NSCollectionViewLayout {
    
    // MARK: - Public Properties
    
    /// The smallest allowable size for an item’s view.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:minimumItemSizeForItemsInSection:)` method, the grid layout object uses the value of
    /// this property as the minimum size for items in each section.
    ///
    /// In a grid layout, all items in the same section are same size. Items in the same row span the width (or height in horizontally scrolling layout) to
    /// equally fill the row with same item gap. The height (or width) may adjust itself to keep the aspect ratio based on the value of `itemGrowDirection`.
    ///
    /// The default value of this property is (50.0, 50.0). Any value less than 0 will be ignored and the default value will be used.
    public var minimumItemSize: NSSize = NSSize(width: 50, height: 50)
    
    /// The direction the item should resize.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:growDirectionForItemsInSection:)` method, the grid layout object uses the value of this
    /// property to set the grow direction for items in each section.
    ///
    /// This property decide the auto resizing behavior of the item height in vertically scroll layout or the width in horizontally scroll layout.
    /// When grow direction is `.bothDirection`, the layout adjust the height (or width) of the item to maintain the aspect ratio of the item according to
    /// `minimumItemSize`. When grow direction is `.counterScrollDirection`, the height (in vertically scrolling layout) or the width (in horizontally
    /// scrolling layout) is based on the value you specify in `minimumItemSize`.
    ///
    /// The default value of this property is `.bothDirection`.
    public var itemGrowDirection: CollectionViewGridLayout.GrowDirection = .bothDirection
    
    /// The spacing (in point) to use between items in the same row or column.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:interItemSpacingForSection:)` method, the grid layout object uses the value of this
    /// property to set the spacing between items in the same line.
    ///
    /// For a vertically scrolling layout, the value represents the spacing between items in the same row. For a horizontally scrolling layout, the value
    /// respresents the spacing between items in the same column. Unlike flow layout, the spacing is fixed.
    ///
    /// The default value of this property is `10.0`.
    public var interItemSpacing: CGFloat = 10.0
    
    /// The spacing (in points) to use between rows or columns.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:lineSpacingForSection:)` method, the grid layout object uses the value of this
    /// property to set the spacing between rows or columns.
    ///
    /// For a vertically scrolling layout, the value represents the spacing between rows. For a horizontally scrolling layout, the value respresents the
    /// spacing between columns. Unlike flow layout, the spacing is fixed.
    ///
    /// The default value of this property is `10.0`.
    public var lineSpacing: CGFloat = 10.0
    
    /// The margins used to lay out content in a section.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:insetForSection:)` method, the grid layout object uses the value of this property to
    /// set the margins for each section.
    ///
    /// Section insets reflect the spacing at the outer edges of the section. The margins affect the positioning of the header view, the minimum space on
    /// either side of each line of items, and the distance from the last line to the footer view. The margin insets do not affect the size of the header and
    /// footer views in the nonscrolling direction.
    ///
    /// ```
    /// +---------------------------+
    /// |           Header          |
    /// +---------------------------+
    /// •            top            •
    /// •       +-----------+       •
    /// •       |[x] [x] [x]|       •
    /// • left  |[x] [x] [x]| right •
    /// •       |[x] [x]    |       •
    /// •       +-----------+       •
    /// •          bottom           •
    /// +---------------------------+
    /// |          Footer           |
    /// +---------------------------+
    /// ```
    ///
    /// The default insets are all set to `0`.
    public var sectionInset: NSEdgeInsets = NSEdgeInsetsZero
    
    /// The maximum number of columns allowed in section.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:maximumNumberOfColumnsInSection:)` method, the grid layout object uses the value of
    /// this property to set the maximum width or height for each section to layout items.
    ///
    /// For a vertically scrolling layout, the value represents the maximum number of columns. For a horizontally scrolling layout, the value respresents the
    /// maximum number of rows.
    ///
    /// By default, grid layout will try to fit as many items as possible in a row or column, until the row or column can not fit another item. Depending on
    /// the width available and the minimum item size, the number of columns or rows can be infinite. By setting this property, grid layout will try to fit as
    /// many items as possible in a row or column until, however, reach the maximum number of columns or rows defined in this property.
    ///
    /// Although this property set a limit to the number of columns or rows, grid layout will still try to span items' size in rows or columns to equally fill
    /// available space. If you want to avoid this and set a maximum width for items to laid, use `maximumSectionWidth` to set a limit on that.
    ///
    /// The default value of thsi property is 0, which means use as many columns as needed.
    public var maximumNumberOfColumns: Int = 0
    
    /// The maximum width or height to use for each section.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:maximumWidthInSection:)` method, the grid layout object uses the value of this
    /// property to set the maximum width or height for each section to layout items.
    ///
    /// For a vertically scrolling layout, the value respresents the maximum width of rect where all items are laid out. For a horizontally scrolling layout,
    /// the value respresents the maximum height of rect where all items are laid out.
    ///
    /// The figure below showcases the relationship between section inset and maximum section width.
    ///
    /// ```
    /// +-------------------------------------------+
    /// |                   Header                  |
    /// +-------------------------------------------+
    /// •       <------------(2)------------>       •
    /// •       • • • • +-----------+ • • • •       •
    /// •       •       |[x] [x] [x]|       •       •
    /// •<-(1)->•<-(4)->|[x] [x] [x]|<-(4)->•<-(1)->•
    /// •       •       |[x] [x]    |       •       •
    /// •       • • • • +-----------+ • • • •       •
    /// •               <----(3)---->               •
    /// +-------------------------------------------+
    /// |                   Footer                  |
    /// +-------------------------------------------+
    /// ```
    ///
    /// - 1: Section inset.
    /// - 2: Items' content width.
    /// - 3: Maximum section width.
    /// - 4: Preserved empty space.
    ///
    /// The default value of this property is 0, which means use any content width available.
    public var maximumSectionWidth: CGFloat = 0
    
    /// The default size to use for section headers.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:referenceSizeForHeaderInSection:)` method, the grid layout object uses the value of
    /// this property as the header size.
    ///
    /// The layout object use only one value that is appropriate for the current scrolling direction. Int other words, the layout object uses only the height
    /// value when the content scrolls vertically, setting the width of the header to the width of the collection view. Similarly, the layout object use only
    /// the width value when the content scrolls horizontally, setting the header's height to the height of the collection view. If the size value for the
    /// appropriate dimension is `0`, the layout object omits the header entirely.
    ///
    /// The default value of this property is `.zero`.
    public var headerReferenceSize: NSSize = .zero
    
    /// The default size to use for section footers.
    ///
    /// If the delegate does not implement the `collectionView(_:layout:referenceSizeForFooterInSection:)` method, the grid layout object uses the value of
    /// this property as the footer size.
    ///
    /// The layout object use only one value that is appropriate for the current scrolling direction. Int other words, the layout object uses only the height
    /// value when the content scrolls vertically, setting the width of the footer to the width of the collection view. Similarly, the layout object use only
    /// the width value when the content scrolls horizontally, setting the footer's height to the height of the collection view. If the size value for the
    /// appropriate dimension is `0`, the layout object omits the footer entirely.
    ///
    /// The default value of this property is `.zero`.
    public var footerReferenceSize: NSSize = .zero
    
    /// Display header view on top of items in sections.
    ///
    /// If the delegate does not imolement the `collectionView(_:layout:displayOnTopOfItemsForHeaderInSection:)` method, the grid layout object uses the value
    /// of this property to determine the header frame.
    ///
    /// When this value is `false`, the header view appear above the items in a section and takes up its own space. When this value is `true`, the header view
    /// appear on top of items in a section and takes up no space, in consequence, the items' content height (in vertically scrolling layout) or width (in
    /// horizontally scrolling layout) are constrainted to contain the section header view's height or width. If both header and footer in a section are
    /// display on top of items, the items' content height or width are constrainted to contain the section header and footer view's height or width combine.
    ///
    /// The default value of this value is `false`.
//    public var displaySectionHeaderOnTopOfItems: Bool = false
    
    /// Display footer view on top of items in sections.
    ///
    /// If the delegate does not imolement the `collectionView(_:layout:displayOnTopOfItemsForFooterInSection:)` method, the grid layout object uses the value
    /// of this property to determine the footer frame.
    ///
    /// When this value is `false`, the footer view appear above the items in a section and takes up its own space. When this value is `true`, the footer view
    /// appear on top of items in a section and takes up no space, in consequence, the items' content height (in vertically scrolling layout) or width (in
    /// horizontally scrolling layout) are constrainted to contain the section footer view's height or width. If both header and footer in a section are
    /// display on top of items, the items' content height or width are constrainted to contain the section header and footer view's height or width combine.
    ///
    /// The default value of this value is `false`.
//    public var displaySectionFooterOnTopOfItems: Bool = false
    
    /// A Boolean value indicating whether headers pin to the top of the collection view bounds during scrolling.
    ///
    /// When this property is true, section header views scroll with content until they reach the top of the screen, at which point they are pinned to the
    /// upper bounds of the collection view. Each new header view that scrolls to the top of the screen pushes the previously pinned header view offscreen.
    ///
    /// The default value of this property is `false`.
    public var sectionHeaderPinToVisibleBounds: Bool = false
    
    /// A Boolean value indicating whether footers pin to the bottom of the collection view bounds during scrolling.
    ///
    /// When this property is true, section footer views scroll with content until they reach the bottom of the screen, at which point they are pinned to the
    /// lower bounds of the collection view. Each new footer view that scrolls to the bottom of the screen pushes the previously pinned footer view offscreen.
    ///
    /// The default value of this property is `false`.
    public var sectionFooterPinToVisibleBounds: Bool = false
    
    /// The scroll direction of the layout.
    ///
    /// The grid layout scrolls along one axis only, either horizontally or vertically. When the scroll direction is `.vertical`, the width of the content
    /// never exceeds the width of the collection view itself but the height grows as needed to accommodate the current items. When the scroll direction is
    /// `.horizontal`, the height never exceeds the height of the collection view but the width grows as needed.
    ///
    /// The default value of this property is `vertical`.
    public var scrollDirection: NSCollectionView.ScrollDirection = .vertical
    
    // MARK: - Internal Properties
    
    internal typealias _IndexedAttributes<Key: Hashable> = [Key: NSCollectionViewLayoutAttributes]
    
    internal var _itemCaches: _IndexedAttributes<IndexPath> = [:]
    
    internal var _headerCaches: _IndexedAttributes<Int> = [:]
    
    internal var _footerCaches: _IndexedAttributes<Int> = [:]
    
    internal var _contentSize: NSSize = .zero
    
    // MARK: - Override
    
    public override var collectionViewContentSize: NSSize {
        return _contentSize
    }
    
    public override func prepare() {
        guard let collectionView = collectionView else { return }
        
        _contentSize = _prepareContentSize()
        
        var tracker = NSCollectionViewLayout._ODSTracker(originInRect: NSRect(origin: .zero, size: _contentSize), scrollDirection: scrollDirection, layoutDirection: _layoutDirection)

        for section in 0..<collectionView.numberOfSections {
            tracker = _prepareSectionHeader(for: section, tracker: tracker)
            tracker = _prepareItems(in: section, tracker: tracker)
            tracker = _prepareSectionFooter(for: section, tracker: tracker)
        }
                
    }
    
    public override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        // Should we call `layoutAttributesForItem(at:) for item layout? or just ignore it?
        return _itemCaches.compactMap {
            $0.value.frame.intersects(rect) ? $0.value : nil
        } + _headerCaches.compactMap {
            $0.value.frame.intersects(rect) ? $0.value : nil
        } + _footerCaches.compactMap {
            $0.value.frame.intersects(rect) ? $0.value : nil
        }
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return _itemCaches[indexPath]
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        switch elementKind {
            case NSCollectionView.elementKindSectionHeader:
                return _headerCaches[indexPath.section]
            case NSCollectionView.elementKindSectionFooter:
                return _footerCaches[indexPath.section]
            case NSCollectionView.elementKindInterItemGapIndicator:
                // TODO: support inter item gap
                fallthrough
            default: return nil
        }
    }
    
    private var _oldBounds: NSRect = .zero
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        // invalidate layout only when the visible width changed
        let invalidate = scrollDirection == .vertical ? newBounds.width != _oldBounds.width : newBounds.height != _oldBounds.height
        _oldBounds = newBounds
        return invalidate
    }
    
    // TODO: Animating item changes like ibooks maybe?
    
    
}
