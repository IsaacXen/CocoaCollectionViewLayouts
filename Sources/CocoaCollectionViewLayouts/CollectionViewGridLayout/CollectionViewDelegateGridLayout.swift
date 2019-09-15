import AppKit

@objc public protocol CollectionViewDelegateGridLayout: class {
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewGridLayout, minimumItemSizeInSection section: Int) -> NSSize
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewGridLayout, itemGrowDirectionInSection section: Int) -> CollectionViewGridLayout.GrowDirection
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewGridLayout, interItemSpacingInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewGridLayout, lineSpacingInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewGridLayout, insetForSection section: Int) -> NSEdgeInsets
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewGridLayout, maximumNumberOfColumnsInSection section: Int) -> Int
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewGridLayout, maximumWidthForSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewGridLayout, headerReferenceSizeInSection section: Int) -> NSSize
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewGridLayout, footerReferenceSizeInSection section: Int) -> NSSize
    
}
