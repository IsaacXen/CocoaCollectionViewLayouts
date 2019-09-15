# CocoaCollectionViewLayouts

### FAQ

<details><summary>Q: Horizontal scrolling doesn't work.</summary>

A: This appears to be a bug on apple-side.

When using a layout that subclass from `NSCollectionViewLayout`, the collection view will not use the width provided by the layout, instead, it use a fixed visible rect width.

Some fired radars long ago but this never get patch.

To fix this, you can subclass `NSCollectionView` and override the following method:
```swift
override func setFrameSize(_ newSize: NSSize) {
  var newSize = newSize
  if let layout = collectionViewLayout as? CollectionViewFlowLayout {
     newSize.width = newSize.width != layout.collectionViewContentSize.width ? layout.collectionViewContentSize.width : newSize.width
     enclosingScrollView?.verticalScrollElasticity = .none
     enclosingScrollView?.hasHorizontalScroller = true
  } 
   super.setFrameSize(newSize)
}
```

This is not a good sulotion, but probably the only way to get around.

</details> 

<details><summary>Q: Can't scroll / contents are clipped until resize the window. </summary>

A: This also appears to be a bug on apple-side, at lease to me.

Some said you can fix this by calling:

```swift
collectionView.setFrameSize(collectionView.collectionViewLayout.collectionViewContentSize)
```

But to me, this may be an issue related to Xcode.

When force quitting your application with Xcode (by ether clicking Run or Stop when application is running), Xcode saves the window's frame and restore it on next launch, even when your window is not configured to autosave its frame.

This is good for development but for some reasons, this causes the document view of the scroll view (mostly collection view) to not use the correct bounds in the next application run.

However, if you quit your application normally:

- Click Application Menu and select Quit Application Name
- Use keyboard shortcut ⌘Q
- Right click on Dock icon and select Quit (with ⌥ or not)
- Force quit in Force Quit Applications window (⌘⌥⎋)
- ...

Anything will works as you expected in the next application run (including launching from Xcode).

</details> 

---

Any suggestions and pull requests is welcome.
