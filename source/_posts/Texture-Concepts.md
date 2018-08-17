---
title: Texture Concepts
date: 2018-08-08 21:52:08
updated:
categories: iOS
tags: Framework
keywords: Texture
---

[Texture Docs](https://texturegroup.org/)

## Node Subclasses
Node Inheritance Hierarchy
``` bash
ASDisplayNode
├── ASTableNode
├── ASCollectionNode
│   └── ASPagerNode
├── ASCellNode
├── ASScrollNode
├── ASEditableTextNode
└── ASControlNode
    ├── ASButtonNode
    ├── ASTextNode
    ├── ASMapNode
    └── ASImageNode
        ├── ASNetworkImageNode
        │   └── ASVideoNode
        └── ASMultiplexImageNode
```

<!-- more -->

## Subclassing
### ASDisplayNode
#### -init
This method is called on a **background thread** when using nodeBlocks. However, because no other method can run until `-init` is finished, it should never be necessary to have a lock in this method.

The most important thing to remember is that your init method must be capable of being called on any queue. Most notably, this means you should never initialize any UIKit objects, touch the view or layer of a node (e.g. `node.layer.X` or `node.view.X`) or add any gesture recognizers in your initializer. Instead, do these things in `-didLoad`.

#### -didLoad
This method is conceptually similar to UIViewController’s `-viewDidLoad` method; it’s called once and is the point where the backing view has been loaded. It is guaranteed to be called on the **main thread** and is the appropriate place to do any UIKit things (such as adding gesture recognizers, touching the view / layer, initializing UIKit objects).

#### -layoutSpecThatFits:
This method defines the layout and does the heavy calculation on a **background thread**. This method is where you build out a layout spec object that will produce the size of the node, as well as the size and position of all subnodes. This is where you will put the majority of your layout code.

Because it is run on a background thread, you should not set any `node.view` or `node.layer` properties here. Also, unless you know what you are doing, do not create any nodes in this method. Additionally, it is not neccessary to begin this method with a call to super, unlike other method overrides.

#### -layout
The call to super in this method is where the results of the layoutSpec are applied; Right after the call to super in this method, the layout spec will have been calculated and all subnodes will have been measured and positioned.

`-layout` is conceptually similar to UIViewController’s `-viewWillLayoutSubviews`. This is a good spot to change the hidden property, set view based properties if needed (not layoutable properties) or set background colors. You could put background color setting in -layoutSpecThatFits:, but there may be timing problems. If you happen to be using any UIViews, you can set their frames here. However, you can always create a node wrapper with `-initWithViewBlock:` and then size this on the background thread elsewhere.

This method is called on the **main thread**. However, if you are using layout Specs, you shouldn’t rely on this method too much, as it is much preferable to do layout off the main thread. Less than 1 in 10 subclasses will need this.

One great use of `-layout` is for the specific case in which you want a subnode to be your exact size. E.g. when you want a collectionNode to take up the full screen. This case is not supported well by layout specs and it is often easiest to set the frame manually with a single line in this method:
``` swift
subnode.frame = self.bounds;
```
If you desire the same effect in a ASViewController, you can do the same thing in -viewWillLayoutSubviews, unless your node is the node in initWithNode: and in that case it will do this automatically.

### ASViewController
An `ASViewController` is a regular `UIViewController` subclass that has special features to manage nodes. Since it is a UIViewController subclass, all methods are called on the **main thread** (and you should always create an ASViewController on the main thread).

#### -init
This method is called once, at the very beginning of an ASViewController’s lifecycle. As with UIViewController initialization, it is best practice to **never access** `self.view` or `self.node.view` in this method as it will force the view to be created early. Instead, do any view access in `-viewDidLoad`.

ASViewController’s designated initializer is `initWithNode:`. A typical initializer will look something like the code below. Note how the ASViewController’s node is created before calling super. An ASViewController manages a node similarly to how a UIViewController manages a view, but the initialization is slightly different.
``` swift
init() {
  let pagerNode = ASPagerNode()
  super.init(node: pagerNode)

  pagerNode.setDataSource(self)
  pagerNode.setDelegate(self)
}
```

#### -loadView
We recommend that you do not use this method because it is has no particular advantages over `-viewDidLoad` and has some disadvantages. However, it is safe to use as long as you do not set the `self.view` property to a different value. The call to `[super loadView]` will set it to the `node.view` for you.

#### -viewDidLoad
This method is called once in a ASViewController’s lifecycle, immediately after `-loadView`. This is the earliest time at which you should access the node’s view. It is a great spot to put any **setup code that should only be run once and requires access to the view/layer**, such as adding a gesture recognizer.

Layout code should never be put in this method, because it will not be called again when geometry changes. Note this is equally true for UIViewController; it is bad practice to put layout code in this method even if you don’t currently expect geometry changes.

#### -viewWillLayoutSubviews
This method is called at the exact same time as a node’s `-layout` method and it may be called multiple times in a ASViewController’s lifecycle; it will be called whenever the bounds of the ASViewController’s node are changed (including rotation, split screen, keyboard presentation) as well as when there are changes to the hierarchy (children being added, removed, or changed in size).

For consistency, it is best practice to put all layout code in this method. Because it is not called very frequently, even code that does not directly depend on the size belongs here.

#### -viewWillAppear: / -viewDidDisappear:
These methods are called just before the ASViewController’s node appears on screen (the earliest time that it is visible) and just after it is removed from the view hierarchy (the earliest time that it is no longer visible). These methods provide a good opportunity to start or stop animations related to the presentation or dismissal of your controller. This is also a good place to make a log of a user action.

Although these methods may be called multiple times and geometry information is available, they are not called for all geometry changes and so should not be used for core layout code (beyond setup required for specific animations).

## Layout
All `ASDisplayNodes` and `ASLayoutSpecs` conform to the `<ASLayoutElement>` protocol. This means that you can compose layout specs from both nodes and other layout specs.

### Layout Specs
A layout spec, short for “layout specification”, has no physical presence. Instead, layout specs act as containers for other layout elements by understanding how these children layout elements relate to each other.

#### ASWrapperLayoutSpec
`ASWrapperLayoutSpec` is a simple `ASLayoutSpec` subclass that can wrap a `ASLayoutElement` and calculate the layout of the child based on the size set on the layout element.
``` swift
// return a single subnode from layoutSpecThatFits:
override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec 
{
  return ASWrapperLayoutSpec(layoutElement: _subnode)
}

// set a size (but not position)
override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec 
{
  _subnode.style.preferredSize = CGSize(width: constrainedSize.max.width,
                                        height: constrainedSize.max.height / 2.0)
  return ASWrapperLayoutSpec(layoutElement: _subnode)
}
```

#### ASStackLayoutSpec
`ASStackLayoutSpec` uses the flexbox algorithm to determine the position and size of its children.
``` swift
override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec 
{
  let mainStack = ASStackLayoutSpec(direction: .horizontal,
                                    spacing: 6.0,
                                    justifyContent: .start,
                                    alignItems: .center,
                                    children: [titleNode, subtitleNode])

  // Set some constrained size to the stack
  mainStack.style.minWidth = ASDimensionMakeWithPoints(60.0)
  mainStack.style.maxHeight = ASDimensionMakeWithPoints(40.0)

  return mainStack
}
```

#### ASInsetLayoutSpec
If you set `INFINITY` as a value in the `UIEdgeInsets`, the inset spec will just use the intrinisic size of the child.
``` swift
override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec
{
  ...
  let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
  let headerWithInset = ASInsetLayoutSpec(insets: insets, child: textNode)
  ...
}
```

#### ASOverlayLayoutSpec
`ASOverlayLayoutSpec` lays out its child (blue), stretching another component on top of it as an overlay (red).
``` swift
override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec
{
  let backgroundNode = ASDisplayNodeWithBackgroundColor(UIColor.blue)
  let foregroundNode = ASDisplayNodeWithBackgroundColor(UIColor.red)
  return ASOverlayLayoutSpec(child: backgroundNode, overlay: foregroundNode)
}
```

#### ASBackgroundLayoutSpec
`ASBackgroundLayoutSpec` lays out a component (blue), stretching another component behind it as a backdrop (red).
``` swift
override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec
{
  let backgroundNode = ASDisplayNodeWithBackgroundColor(UIColor.red)
  let foregroundNode = ASDisplayNodeWithBackgroundColor(UIColor.blue)

  return ASBackgroundLayoutSpec(child: foregroundNode, background: backgroundNode)
}
```

#### ASCenterLayoutSpec
`ASCenterLayoutSpec` centers its child within its max `constrainedSize`.
```swift
override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec
{
  let subnode = ASDisplayNodeWithBackgroundColor(UIColor.green, CGSize(width: 60.0, height: 100.0))
  let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: subnode)
  return centerSpec
}
```

#### ASRatioLayoutSpec
`ASRatioLayoutSpec` lays out a component at a fixed aspect ratio which can scale.
``` swift
override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec
{
  // Half Ratio
  let subnode = ASDisplayNodeWithBackgroundColor(UIColor.green, CGSize(width: 100, height: 100.0))
  let ratioSpec = ASRatioLayoutSpec(ratio: 0.5, child: subnode)
  return ratioSpec
}
```

#### ASRelativeLayoutSpec
Lays out a component and positions it within the layout bounds according to vertical and horizontal positional specifiers. Similar to the “9-part” image areas, a child can be positioned at any of the 4 corners, or the middle of any of the 4 edges, as well as the center.
``` swift
override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec
{
  ...
  let backgroundNode = ASDisplayNodeWithBackgroundColor(UIColor.blue)
  let foregroundNode = ASDisplayNodeWithBackgroundColor(UIColor.red, CGSize(width: 70.0, height: 100.0))

  let relativeSpec = ASRelativeLayoutSpec(horizontalPosition: .start,
                                          verticalPosition: .start,
                                          sizingOption: [],
                                          child: foregroundNode)

  let backgroundSpec = ASBackgroundLayoutSpec(child: relativeSpec, background: backgroundNode)
  ...
}
```

#### ASAbsoluteLayoutSpec
Within `ASAbsoluteLayoutSpec` you can specify exact locations (x/y coordinates) of its children by setting their `layoutPosition` property.
``` swift
override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec
{
  let maxConstrainedSize = constrainedSize.max

  // Layout all nodes absolute in a static layout spec
  guitarVideoNode.style.layoutPosition = CGPoint.zero
  guitarVideoNode.style.preferredSize = CGSize(width: maxConstrainedSize.width, height: maxConstrainedSize.height / 3.0)

  nicCageVideoNode.style.layoutPosition = CGPoint(x: maxConstrainedSize.width / 2.0, y: maxConstrainedSize.height / 3.0)
  nicCageVideoNode.style.preferredSize = CGSize(width: maxConstrainedSize.width / 2.0, height: maxConstrainedSize.height / 3.0)

  simonVideoNode.style.layoutPosition = CGPoint(x: 0.0, y: maxConstrainedSize.height - (maxConstrainedSize.height / 3.0))
  simonVideoNode.style.preferredSize = CGSize(width: maxConstrainedSize.width / 2.0, height: maxConstrainedSize.height / 3.0)

  hlsVideoNode.style.layoutPosition = CGPoint(x: 0.0, y: maxConstrainedSize.height / 3.0)
  hlsVideoNode.style.preferredSize = CGSize(width: maxConstrainedSize.width / 2.0, height: maxConstrainedSize.height / 3.0)

  return ASAbsoluteLayoutSpec(children: [guitarVideoNode, nicCageVideoNode, simonVideoNode, hlsVideoNode])
}
```

#### ASCornerLayoutSpec
The easy way to position an element in corner is to use declarative code expression rather than manual coordinate calculation, and `ASCornerLayoutSpec` can achieve this goal.
``` swift
override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec
{
  ...
  // Layout the center of badge to the top right corner of avatar.
  let cornerSpec = ASCornerLayoutSpec(child: avatarNode, corner: badgeNode, location: .topRight)
  // Slightly shift center of badge inside of avatar.
  cornerSpec.offset = CGPoint(x: -3, y: 3)
  ...
}
```

### Layout Elements
Layout specs contain and arrange layout elements.

### Layout API Sizing
#### Values (`CGFloat`, `ASDimension`)
`ASDimension` is essentially a normal `CGFloat` with support for representing either a point value, a relative percentage value, or an auto value.

#### Sizes (`CGSize`, `ASLayoutSize`)
`ASLayoutSize` is similar to a `CGSize`, but its width and height values may represent either a point or percent value. The type of the width and height are independent; either one may be a point or percent value.

#### Size Range (ASSizeRange)
`UIKit` doesn’t provide a structure to bundle a minimum and maximum `CGSize`. So, `ASSizeRange` was created to support a minimum and maximum `CGSize` pair.

### Some nodes need Sizes Set
Some elements have an “intrinsic size” based on their immediately available content. For example, `ASTextNode` can calculate its size based on its attributed string. Nodes that have an intrinsic size include:
- `ASImageNode`
- `ASTextNode`
- `ASButtonNode`

All other nodes either do not have an intrinsic size or lack an intrinsic size until their external resource is loaded. For example, an `ASNetworkImageNode` does not know its size until the image has been downloaded from the URL. These sorts of elements include:
- `ASVideoNode`
- `ASVideoPlayerNode`
- `ASNetworkImageNode`
- `ASEditableTextNode`

These nodes that lack an initial intrinsic size must have an initial size set for them using an `ASRatioLayoutSpec`, an `ASAbsoluteLayoutSpec` or the size properties on the style object.

## Notices
- Make sure you access your data source outside of a `nodeBlock`.
- Take steps to avoid a retain cycle in `viewBlocks`.
- `ASCellNodes` are not reusable.
- A node’s layoutSpec gets regenerated every time its `layoutThatFits:` method is called.
- If you care about performance, do not use `CALayer`'s `.cornerRadius` property (or shadowPath, border or mask).
- Texture does not support UIKit Auto Layout or InterfaceBuilder.
- `ASDisplayNode` keep alive reference.

## Conveniences
### Hit Test Slop
`ASDisplayNode` has a `hitTestSlop` property of type `UIEdgeInsets` that when set to a non-zero inset, increase the bounds for hit testing to make it easier to tap or perform gestures on this node.
``` swift
let textNode = ASTextNode()
let padding = (44.0 - button.bounds.size.height)/2.0
textNode.hitTestSlop = UIEdgeInsetsMake(-padding, 0, -padding, 0)
```

### Batch Fetching API
Texture’s Batch Fetching API makes it easy to add fetching chunks of new data. Usually this would be done in a `-scrollViewDidScroll:` method, but Texture provides a more structured mechanism.

### Automatic Subnode Management
By setting `.automaticallyManagesSubnodes` to `YES` on the `ASCellNode`, ASM means that your nodes no longer require `addSubnode:` or `removeFromSupernode` method calls. The presence or absence of the ASM node and its subnodes is completely determined in its `layoutSpecThatFits:` method.

ASM knows whether or not to include these elements in the UI based on the information provided in the cell’s `ASLayoutSpec`. An `ASLayoutSpec` completely describes the UI of a view in your app by specifying the hierarchy state of a node and its subnodes. An `ASLayoutSpec` is returned by a node from its `layoutSpecThatFits:` method.

If something happens that you know will change your `ASLayoutSpec`, it is your job to call `setNeedsLayout`.

``` swift
class PhotoCellNode {
  private let photoModel: PhotoModel
  
  private let userAvatarImageNode = ASNetworkImageNode()
  private let photoImageNode = ASNetworkImageNode()
  private let userNameTextNode = ASTextNode()
  private let photoLocationTextNode = ASTextNode()

  init(photo: PhotoModel) {
    photoModel = photo
    
    super.init()
    
    automaticallyManagesSubnodes = true
    
    userAvatarImageNode.URL = photo.ownerUserProfile.userPicURL
    photoImageNode.URL = photo.URL
    userNameTextNode.attributedText = poto.ownerUserProfile.usernameAttributedString(fontSize: fontSize)
    
    photo.location.reverseGeocodeLocation { [weak self] location in 
      if locationModel == self?.photoModel.location {
        self?.photoLocationTextNode.attributedText = photo.locationAttributedString(fontSize: fontSize)
        self?.setNeedsLayout()
      }
    }
  }
}

override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
  let headerSubStack: ASStackLayoutSpec = .vertical()
  headerSubStack.style.flexShrink = 1

  if photoLocationLabel.attributedText != nil {
    headerSubStack.children = [userNameLabel, photoLocationLabel]
  } else {
    headerSubStack.children = [userNameLabel]
  }

  userAvatarImageNode.style.preferredSize = CGSize(width: userImageHeight, height: userImageHeight) //  constrain avatar image frame size

  let spacer = ASLayoutSpec()
  spacer.style.flexGrow = 1

  let avatarInsets = UIEdgeInsets(top: horizontalBuffer, left: 0, bottom: horizontalBuffer, right: horizontalBuffer)
  let avatarInset = ASInsetLayoutSpec(insets: avatarInsets, child: userAvatarImageNode)

  let headerStack: ASStackLayoutSpec = .horizontal()
  headerStack.alignItems = .center      // center items vertically in horizontal stack
  headerStack.justifyContent = .start   // justify content to the left side of the header stack
  headerStack.children = [avatarInset, headerSubStack, spacer]

  // header inset stack
  let insets = UIEdgeInsets(top: 0, left: horizontalBuffer, bottom: 0, right: horizontalBuffer)
  let headerWithInset = ASInsetLayoutSpec(insets: insets, child: headerStack)

  // footer inset stack
  let footerInsets = UIEdgeInsets(top: verticalBuffer, left: horizontalBuffer, bottom: verticalBuffer, right: horizontalBuffer)
  let footerWithInset = ASInsetLayoutSpec(insets: footerInsets, child: photoCommentsNode)

  // vertical stack
  let cellWidth = constrainedSize.max.width
  photoImageNode.style.preferredSize = CGSize(width: cellWidth, height: cellWidth)  // constrain photo frame size

  let verticalStack: ASStackLayoutSpec = .vertical()
  verticalStack.alignItems = .stretch   // stretch headerStack to fill horizontal space
  verticalStack.children = [headerWithInset, photoImageNode, footerWithInset]

  return verticalStack
}
```

### Inversion
`ASTableNode` and `ASCollectionNode` have a `inverted` property of type `BOOL` that when set to `YES`, will automatically invert the content so that it’s layed out bottom to top, that is the ‘first’ (indexPath 0, 0) node is at the bottom rather than the top as usual. This is extremely covenient for chat/messaging apps, and with Texture it only takes one property.

### Image Modification Blocks
By assigning an `imageModificationBlock` to your imageNode, you can define a set of transformations that need to happen asynchronously to any image that gets set on the imageNode.
``` swift
backgroundImageNode.imageModificationBlock = { image in
    let newImage = image.applyBlurWithRadius(30, tintColor: UIColor(white: 0.5, alpha: 0.3),
    								 saturationDeltaFactor: 1.8,
    								 			 maskImage: nil)
    return (newImage != nil) ? newImage : image
}

//some time later...

backgroundImageNode.image = someImage
```
The image named “someImage” will now be blurred asynchronously before being assigned to the imageNode to be displayed.

### Placeholders
#### ASDisplayNodes may Implement Placeholders
Any `ASDisplayNode` subclass may implement the `-placeholderImage` method to provide a placeholder that covers content until a node’s contents are finished displaying.

#### ASNetworkImageNode also have Default Images
In addition to placeholders, `ASNetworkImageNodes` also have a `.defaultImage` property. While placeholders are meant to be transient, default images will persist if the image node’s `.URL` property is `nil` or if the URL fails to load.

Use default images for avatars, while use placeholder images for photos.

## Optimizations
### Layer Backing
In some cases, you can substantially improve your app’s performance by using layers instead of views. It's recommended to enable layer-backing in any custom node that doesn’t need touch handling.

With all Texture nodes, converting an entire subtree from views to layers is as simple as:
``` swift
rootNode.isLayerBacked = true
```

### Subtree Rasterization
Flattening an entire view hierarchy into a single layer improves performance, but with UIKit, comes with a hit to maintainability and hierarchy-based reasoning.

With all Texture nodes, enabling precompositing is as simple as:
``` swift
rootNode.enableSubtreeRasterization()
```
This line will cause the entire node hierarchy from that point on to be rendered into one layer.

### Synchronous Concurrency
Both `ASViewController` and `ASCellNode` have a property called `neverShowPlaceholders`. By setting this property to YES, the main thread will be blocked until display has completed for the cell or view controller’s view.

Using this option does not eliminate all of the performance advantages of Texture. Normally, a given node has been preloading and is almost done when it reaches the screen, so the blocking time is very short. Even if the rangeTuningParameters are set to 0 this option outperforms UIKit. While the main thread is waiting, all subnode display executes concurrently, thus synchronous concurrency.

``` swift
node.neverShowPlaceholders = true
```

Usually, if a cell hasn’t finished its display pass before it has reached the screen it will show placeholders until it has drawing its content. Setting this option to YES makes your scrolling node or ASViewController act more like UIKit, and in fact makes Texture scrolling visually indistinguishable from UIKit’s, except that it’s faster.

### Corner Rounding
#### Performant Corner Rounding Strategies
There are only three things to consider when picking a corner rounding strategy:
1. Is there movement underneath the corner?
2. Is there movement through the corner?
3. Are all 4 corners the same node *and* no other nodes intersect in the corner area?

Movement **underneath the corner**: Any movement behind the corner. For example, as a rounded-corner collection cell scrolls over a background, the background will move underneath and out from under the corners.

Movement **through the corner**: Imagine a small rounded-corner scroll view containing a much larger photo. As you zoom and pan the photo inside of the scroll view, the photo will move through the corners of the scroll view.

##### Precomposited Corners
Precomposited corners refer to corners drawn using bezier paths to clip the content in a CGContext / UIGraphicsContext (`[path clip]`). In this scenario, the corners become part of the image itself — and are “baked in” to the single CALayer. There are two types of precomposited corners.

The absolute best method is to use **precomposited opaque corners**. This is the most efficient method available, resulting in zero alpha blending (although this is much less critical than avoiding offscreen rendering). Unfortunately, this method is also the least flexible; the background behind the corners will need to be a solid color if the rounded image needs to move around on top of it. It’s possible, but tricky to make precomposited corners with a textured or photo background - usually it’s best to use precomposited alpha corners instead’.’

The second method involves using bezier paths with **precomposited alpha corners**. This method is pretty flexible and should be one of the most frequently used. It does incur the cost of alpha blending across the full size of the content, and including an alpha channel increases memory impact by 25% over opaque precompositing - but these costs are tiny on modern devices, and a different order of magnitude than `.cornerRadius` offscreen rendering.

Note that Texture nodes have a special optimization of `.cornerRadius` that automatically implements precomposited corners only when using `.shouldRasterizeDescendants`.

##### Clip Corner
This strategy involves placing **4 seperate opaque corners that sit on top of the content** that needs corner rounding. This method is flexible and has quite good performance. It has minor CPU overhead of 4 seperate layers, one layer for each corner.

#### CALayer’s .cornerRadius property
There are a few, quite rare cases in which it is appropriate to use `.cornerRadius`. These include when there is dynamic content moving both through the inside and underneath the corner. For certain animations, this is impossible to avoid. However, in many cases, it is easy to adjust your design to eliminate one of the sources of movement.

#### Corner Rounding Strategy Flowchart
<img src="/blog/Texture-Concepts/CornerRoundingFlowchart.png"  alt="Corner Rounding Flowchart" style="width:624px;">

#### Texture Support
Use `.cornerRadius`
``` swift
var cornerRadius: CGFloat = 20.0
photoImageNode.cornerRoundingType = ASCornerRoundingTypeDefaultSlowCALayer
photoImageNode.cornerRadius = cornerRadius
```

Use clipping for rounding corners
``` swift
var cornerRadius: CGFloat = 20.0
photoImageNode.cornerRoundingType = ASCornerRoundingTypeClipping
photoImageNode.backgroundColor = UIColor.white
photoImageNode.cornerRadius = cornerRadius
```

Use precomposition for rounding corners
``` swift
var cornerRadius: CGFloat = 20.0
photoImageNode.cornerRoundingType = ASCornerRoundingTypePrecomposited
photoImageNode.cornerRadius = cornerRadius
```

Use `willDisplayNodeContentWithRenderingContext` to set a clipping path for the content for rounding corners
``` swift
var cornerRadius: CGFloat = 20.0

// Use the screen scale for corner radius to respect content scale
var screenScale: CGFloat = UIScreen.main.scale
photoImageNode.willDisplayNodeContentWithRenderingContext = { context, drawParameters in
    var bounds: CGRect = context.boundingBoxOfClipPath()
    var radius: CGFloat = cornerRadius * screenScale
    var overlay = UIImage.as_resizableRoundedImage(withCornerRadius: radius, cornerColor: UIColor.clear, fill: UIColor.clear)
    overlay.draw(in: bounds)
    UIBezierPath(roundedRect: bounds, cornerRadius: radius).addClip()
}
```

Use `ASImageNode` extras to round the image and add a border.
``` swift
var cornerRadius: CGFloat = 20.0
photoImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(5.0, UIColor.orange)
```

## Advanced Technologies
### ASVisibility
`ASNavigationController` and `ASTabBarController` both implement the `ASVisibility` protocol. These classes can be used even without `ASDisplayNodes`, making them suitable base classes for your inheritance hierarchy. For any child view controllers that are `ASViewControllers`, these classes know the exact number of user taps it would take to make the view controller visible (0 if currently visible).

Knowing a view controller’s visibility depth allows view controllers to automatically take appropriate actions as a user approaches or leaves them. Non-default tabs in an app might preload some of their data; a controller 3 levels deep in a navigation stack might progressively free memory for images, text, and fetched data as it gets deeper.

Any container view controller can implement a simple protocol to integrate with the system. For example, `ASNavigationController` will return a visibility depth of it’s own `visibilityDepth` + 1 for a view controller that would be revealed by tapping the back button once.

You can opt into some of this behavior automatically by enabling `automaticallyAdjustRangeModeBasedOnViewEvents` on `ASViewController`s. With this enabled, if either the view controller or its node conform to `ASRangeControllerUpdateRangeProtocol` (`ASCollectionNode` and ASTableNode do by default), the ranges will automatically be decreased as the visibility depth increases to save memory.

### ASEnvironment
`ASEnvironment` is a performant and scalable way to enable upward and downward propagation of information throughout the node hierarchy. It stores a variety of critical “environmental” metadata, like the trait collection, interface state, hierarchy state, and more.

Any object that conforms to the `<ASEnvironment>` protocol can propagate specific states defined in an `ASEnvironmentState` up and/or down the ASEnvironment tree. To define how merges of States should happen, specific merge functions can be provided.

Compared to UIKit, this system is very efficient and one of the reasons why nodes are much lighter weight than UIViews. This is achieved by using simple structures to store data rather than creating objects. For example, `UITraitCollection` is an object, but `ASEnvironmentTraitCollection` is just a struct.

This means that whenever a node needs to query something about its environment, for example to check its interface state, instead of climbing the entire tree or checking all of its children, it can go to one spot and read the value that was propogated to it.

A key operating principle of ASEnvironment is to update values when new subnodes are added or removed.

### ASRunLoopQueue
Even with main thread work, Texture is able to dramatically reduce its impact on the user experience by way of the rather amazing ASRunLoopQueue.

`ASRunloopQueue` breaks up operations that must be performed on the main thread into far smaller chunks, easily 1/10th of the size that they otherwise would be, so that operation such as allocating UIViews or even destroying objects can be spread out and allow the run loops to more frequently turn. This more periodic turning allows the device to much more frequently check if a user touch has started or if an animation timer requires a new frame to be drawn, allowing far greater responsiveness even when the device is very busy and processing a large queue of main thread work.

It’s a longer discussion why this kind of technique is extremely challenging to implement with `UIKit`, but it has to do with the fact that `Texture` prepares content in advance, giving it a buffer of time where it can spread out the creation of these objects in tiny chunks. If it doesn’t finish by the time it needs to be on screen, then it finishes the rest of what needs to be created in a single chunk. `UIKit` has no similar mechanisms to create things in advance, and there is always just one huge chunk as a view controller or cell needs to come on screen.

`ASRunLoopQueue` is enabled by default when running Texture. A developer does not need to be aware of it’s existence except to know that it helps reduce main thread blockage.

## Node Containers
### ASTableNode
`ASTableNode` replaces `UITableView`’s required method
``` swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
```
with your choice of one of the following methods
``` swift
func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode
func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock
```

> It is recommended that you use the node block version of these methods so that your table node will be able to prepare and display all of its cells concurrently. This means that all subnode initialization methods can be run in the background. Make sure to keep 'em thread safe.

Note that neither of these methods require a reuse mechanism.

#### Replacing UITableViewController with ASViewController
Texture does not offer an equivalent to `UITableViewController`. Instead, use an `ASViewController` initialized with an `ASTableNode`.
``` swift
init(models: [Model]) {
    let tableNode = ASTableNode(style: .plain)

    super.init(node: tableNode)

    self.models = models  
    self.tableNode = tableNode
    self.tableNode.dataSource = self
    
    return self
}
```

#### Node Block Thread Safety Warning
It is very important that node blocks be thread-safe. One aspect of that is ensuring that the data model is accessed outside of the node block. Therefore, it is unlikely that you should need to use the index inside of the block.
``` swift
func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
  guard photoFeed.count > indexPath.row else { return { ASCellNode() } }
    
  let photoModel = photoFeed[indexPath.row]
    
  // this may be executed on a background thread - it is important to make sure it is thread safe
  let cellNodeBlock = { () -> ASCellNode in
    let cellNode = PhotoCellNode(photo: photoModel)
    cellNode.delegate = self
    return cellNode
  }
    
  return cellNodeBlock
}
```

#### Accessing the ASTableView
`ASTableView` can be used directly by accessing the `.view` property of an `ASTableNode`. 
``` swift
override func viewDidLoad() {
  super.viewDidLoad()

  tableNode.view.allowsSelection = false
  tableNode.view.separatorStyle = .none
  tableNode.view.leadingScreensForBatching = 3.0  // default is 2.0
}
```

#### Table Row Height
A node defines its height by way of the layoutSpec returned in the `-layoutSpecThatFits:` method.

If you call `-setNeedsLayout` on an `ASCellNode`, it will automatically perform another layout pass and if its overall desired size has changed, the table will be informed and will update itself. This is different from `UIKit` where normally you would have to call reload row / item.

### ASCollectionNode
As noted in the `ASTableNode` section:
- `ASCollectionNodes` do not utilize cell reuse.
- Using the "nodeBlock" method is preferred.
- It is very important that the returned node blocks are thread-safe.
- `ASCellNodes` can be used by `ASTableNode`, `ASCollectionNode` and `ASPagerNode`.
