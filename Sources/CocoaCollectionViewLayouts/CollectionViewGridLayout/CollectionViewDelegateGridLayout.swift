import AppKit

@objc public protocol CollectionViewDelegateGridLayout: class {
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, minimumItemSizeForItemsInSection section: Int) -> NSSize
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, growDirectionForItemsInSection section: Int) -> CollectionViewGridLayout.GrowDirection
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, interItemSpacingForSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, lineSpacingForSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, insetForSection section: Int) -> NSEdgeInsets
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, maximumNumberOfColumnsInSection section: Int) -> Int
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, maximumWidthInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> NSSize
    
}
