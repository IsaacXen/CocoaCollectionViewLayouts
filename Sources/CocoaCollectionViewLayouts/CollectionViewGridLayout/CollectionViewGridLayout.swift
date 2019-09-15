import AppKit

/// A layout that displays multiple sections of items in a row and column grid.
///
/// In a grid layout, the first item is positioned in the top-left corner (or top-right corner in RTL environment) and other items are laid out either horizontally or vertically based on the scroll direction, which is configurable.
///
/// All items in a section are same size, which means the number of columns in every rows in a section are the same. The number of items in a row or column is determined by the collection view size and the minimum item size in that row, that is, the number of minimum-sized items a row can fit with iter item spacing.
public class CollectionViewGridLayout: NSCollectionViewLayout {
    
    // MARK: - Public Properties
    
    /// The smallest allowable size for an item’s view.
    ///
    /// In a grid layout, all items in the same section are same size. Items in the same row span the width (or height in horizontally scrolling layout) to equally fill the row with same inter item spacing. The height (or width) may adjust itself to keep the aspect ratio based on the value of `itemGrowDirection`.
    ///
    /// The default value of this property is (50.0, 50.0). Any value less than 0 will be ignored and the default value will be used.
    public var minimumItemSize: NSSize = NSSize(width: 50, height: 50)
    
    /// The direction the item should resize.
    ///
    /// This property decide the auto resizing behavior of the item height in vertically scroll layout or the width in horizontally scroll layout.
    /// When grow direction is `.bothDirection`, the layout adjust the height (or width) of the item to maintain the aspect ratio of the item according to `minimumItemSize`. When grow direction is `.counterScrollDirection`, the height (in vertically scrolling layout) or the width (in horizontally scrolling layout) is based on the value you specify in `minimumItemSize`.
    ///
    /// The default value of this property is `.bothDirection`.
    public var itemGrowDirection: CollectionViewGridLayout.GrowDirection = .bothDirection
    
    /// The spacing (in point) to use between items in a row.
    public var interItemSpacing: CGFloat = 10
    
    /// The spacing (in points) to use between rows.
    public var lineSpacing: CGFloat = 10
    
    // The margins used to lay out content in a section.
    public var sectionInset: NSEdgeInsets = NSEdgeInsetsZero
    
    /// The maximum number of columns allowed in section.
    ///
    /// The default value of thsi property is 0, which means use as many columns as needed. Any value less than 0 will be ignored.
    public var maximumNumberOfColumns: Int = 0
    
    /// The maximum width to use in section.
    ///
    /// The default value of this property is 0, which means use any width available. Any value less than minimum item width (or height when `.horizontal` scrolling) will be ignored and use the default value instead.
    public var maximumSectionWidth: CGFloat = 0
    
    public var headerReferenceSize: NSSize = .zero
    
    public var footerReferenceSize: NSSize = .zero
    
    /// The scroll direction of the layout.
    ///
    /// The grid layout scrolls along one axis only, either horizontally or vertically. When the scroll direction is `.vertical`, the width of the content
    /// never exceeds the width of the collection view itself but the height grows as needed to accommodate the current items. When the scroll direction is
    /// `.horizontal`, the height never exceeds the height of the collection view but the width grows as needed.
    ///
    /// The default value of this property is `vertical`.
    public var scrollDirection: NSCollectionView.ScrollDirection = .vertical
    
    // MARK: - Internal Properties
    // TODO: mark internal access control in framework
    
    typealias _IndexedAttributes<Key: Hashable> = [Key: NSCollectionViewLayoutAttributes]
    
    var _caches: _IndexedAttributes<IndexPath> = [:]
    
    var _headerCaches: _IndexedAttributes<Int> = [:]
    
    var _footerCaches: _IndexedAttributes<Int> = [:]
    
    var _contentSize: NSSize = .zero
    
    // MARK: - Override
    
    public override var collectionViewContentSize: NSSize {
        return _contentSize
    }
    
    public override func prepare() {
        guard let collectionView = collectionView else { return }
        
        _prepareContentSize()
        
        var tracker = _prepareTracker()

        for section in 0..<collectionView.numberOfSections {
            // prepare header
            tracker = _prepareItems(in: section, tracker: tracker)
            // prepare footer
        }
        
//        _updateLayoutAttributesForRightToLeftLayoutIfNeeded()
        
    }
    
    public override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        // Should we call `layoutAttributesForItem(at:) for item layout? or just ignore it?
        return _caches.compactMap {
            $0.value.frame.intersects(rect) ? $0.value : nil
        } + _headerCaches.compactMap {
            $0.value.frame.intersects(rect) ? $0.value : nil
        } + _footerCaches.compactMap {
            $0.value.frame.intersects(rect) ? $0.value : nil
        }
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
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
    
    private var _oldBounds: NSRect = .zero
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        // invalidate layout only when the visible width changed
        let invalidate = scrollDirection == .vertical ? newBounds.width != _oldBounds.width : newBounds.height != _oldBounds.height
        _oldBounds = newBounds
        return invalidate
    }
    
    // TODO: Animating item changes like ibooks maybe?
}
