import AppKit

@objc public protocol CollectionViewDelegateFlowLayout: class {
    
    // MARK: - Getting the Size of Items
    
    /// Asks the delegate for the size of the specified item.
    ///
    /// Implement this method when you want to provide the size of items in the flow layout. Your implementation can return the same size for all items or it
    /// can return different sizes for items. You can also adjust the size of items dynamically each time you update the layout. If you do not implement this
    /// method, the size of items is obtained from the properties of the flow layout object.
    ///
    /// The size value you return from this method must allow the item to be displayed fully by the collection view. In the scrolling direction, items can be
    /// larger than the collection view because the remaining content can always be scrolled into view, but in the nonscrolling directions, items should always
    /// be smaller than the collection view itself. For example, the width of an item in a vertically scrolling collection view must not exceed the width of
    /// the collection view minus any section insets. The flow layout does not crop an item’s bounds to make it fit into the available space.
    ///
    /// - Parameter collectionView: The collection view object displaying the flow layout.
    /// - Parameter layout: The layout object requesting the information.
    /// - Parameter indexPath: The index path of the item.
    ///
    /// - Returns: The size of the item. The width and height values must both be greater than 0. Items must also not exceed the available space in the
    /// collection view.
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewFlowLayout, sizeForItemAt indexPath: IndexPath) -> NSSize
    
    
    // MARK: - Getting the Section Spacing
    
    /// Asks the delegate for the margins to apply to content in the specified section.
    ///
    /// Implement this method when you want to provide margins for sections in the flow layout. Your implementation can return the same margins for all
    /// sections or it can return different margins for different sections. You can also adjust the margins of each section dynamically each time you update
    /// the layout. If you do not implement this method, the margins are obtained from the properties of the flow layout object.
    ///
    /// The insets you return reflect the spacing between the items and the header and footer views of the section. They also reflect the spacing at the edges
    /// of a single row or column. For more information about how insets are applied, see the description of the `sectionInset` property.
    ///
    /// - Parameter collectionView: The collection view object displaying the flow layout.
    /// - Parameter layout: The layout object requesting the information.
    /// - Parameter indexPath: The index of the section whose margins are needed.
    ///
    /// - Returns: The margins to apply to items in the specified section.
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewFlowLayout, insetForSectionAt section: Int) -> NSEdgeInsets
    
    /// Asks the delegate for the spacing between successive rows or columns of a section.
    ///
    /// Implement this method when you want to provide custom line spacing for sections in the flow layout. Your implementation can return the same line
    /// spacing for all sections or it can return different line spacing for different sections. You can also adjust the line spacing of each section
    /// dynamically each time you update the layout. If you do not implement this method, the line spacing is obtained from the properties of the flow layout
    /// object.
    ///
    /// For a vertically scrolling layout, this value represents the minimum spacing between successive rows. For a horizontally scrolling layout, this value
    /// represents the minimum spacing between successive columns. This spacing is not applied to the space between the header and the first line or between
    /// the last line and the footer. For more information about how line spacing is applied, see the description of the `minimumLineSpacing` property.
    ///
    /// - Parameter collectionView: The collection view object displaying the flow layout.
    /// - Parameter layout: The layout object requesting the information.
    /// - Parameter indexPath: The index of the section whose line spacing is needed.
    ///
    /// - Returns: The minimum space (in points) to apply between successive lines in a section.
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewFlowLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    
    
    /// Asks the delegate for the spacing between successive items of a single row or column.
    ///
    /// Implement this method when you want to provide custom inter-item spacing for sections in the flow layout. Your implementation can return the same
    /// spacing for all sections or it can return different spacing for different sections. You can also adjust the inter-item spacing of each section
    /// dynamically each time you update the layout. If you do not implement this method, the inter-item spacing is obtained from the properties of the flow
    /// layout object.
    ///
    /// For a vertically scrolling layout, this value represents the minimum spacing between items in the same row. For a horizontally scrolling layout, this
    /// value represents the minimum spacing between items in the same column. The layout object uses this spacing only to compute how many items can fit in a
    /// single row or column. The actual spacing may be increased after the number of items has been determined. For more information about how inter-item
    /// spacing is applied, see the description of the `minimumInteritemSpacing` property.
    ///
    /// - Parameter collectionView: The collection view object displaying the flow layout.
    /// - Parameter layout: The layout object requesting the information.
    /// - Parameter indexPath: The index of the section whose inter-item spacing is needed.
    ///
    /// - Returns: The minimum space (in points) to apply between successive items in a single row or column.
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewFlowLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    
    
    // MARK: - Getting the Header and Footer Sizes
    
    /// Asks the delegate for the size of the header view in the specified section.
    ///
    /// If you implement this method, the flow layout object calls it to obtain the size of the header in each section and uses that information to set the
    /// size of the corresponding views. If you do not implement this method, the header size is obtained from the properties of the flow layout object.
    ///
    /// The flow layout object uses only one of the returned size values. For a vertically scrolling layout, the layout object uses the height value. For a
    /// horizontally scrolling layout, the layout object uses the width value. The other value is sized appropriately to match the opposing dimension of the
    /// collection view itself. Set the size of the header to `0` to prevent it from being displayed.
    ///
    /// - Parameter collectionView: The collection view object displaying the flow layout.
    /// - Parameter layout: The layout object requesting the information.
    /// - Parameter section: The index of the section whose header size is requested.
    ///
    /// - Returns: The size of the header. Return `.zero` if you do not want a header added to the section.
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewFlowLayout, referenceSizeForHeaderInSection section: Int) -> NSSize
    
    /// Asks the delegate for the size of the footer view in the specified section.
    ///
    /// If you implement this method, the flow layout object calls it to obtain the size of the footer in each section and uses that information to set the
    /// size of the corresponding views. If you do not implement this method, the footer size is obtained from the properties of the flow layout object.
    ///
    /// The flow layout object uses only one of the returned size values. For a vertically scrolling layout, the layout object uses the height value. For a
    /// horizontally scrolling layout, the layout object uses the width value. The other value is sized appropriately to match the opposing dimension of the
    /// collection view itself. Set the size of the footer to `0` to prevent it from being displayed.
    ///
    /// - Parameter collectionView: The collection view object displaying the flow layout.
    /// - Parameter layout: The layout object requesting the information.
    /// - Parameter section: The index of the section whose footer size is requested.
    ///
    /// - Returns: The size of the footer. Return `.zero` if you do not want a footer added to the section.
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: CollectionViewFlowLayout, referenceSizeForFooterInSection section: Int) -> NSSize
}
