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

`ASLayoutSpec` subclasses:
- ASWrapperLayoutSpec
- ASStackLayoutSpec
- ASInsetLayoutSpec
- ASOverlayLayoutSpec
- ASBackgroundLayoutSpec
- ASCenterLayoutSpec
- ASRatioLayoutSpec
- ASRelativeLayoutSpec
- ASAbsoluteLayoutSpec
- ASCornerLayoutSpec

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

### Batch Fetching API
Texture’s Batch Fetching API makes it easy to add fetching chunks of new data. Usually this would be done in a `-scrollViewDidScroll:` method, but Texture provides a more structured mechanism.

### Automatic Subnode Management
By setting `.automaticallyManagesSubnodes` to `YES` on the `ASCellNode`, ASM means that your nodes no longer require `addSubnode:` or `removeFromSupernode` method calls. The presence or absence of the ASM node and its subnodes is completely determined in its `layoutSpecThatFits:` method.

ASM knows whether or not to include these elements in the UI based on the information provided in the cell’s `ASLayoutSpec`. An `ASLayoutSpec` completely describes the UI of a view in your app by specifying the hierarchy state of a node and its subnodes. An `ASLayoutSpec` is returned by a node from its `layoutSpecThatFits:` method.

If something happens that you know will change your `ASLayoutSpec`, it is your job to call `setNeedsLayout`.

### Inversion
`ASTableNode` and `ASCollectionNode` have a `inverted` property of type `BOOL` that when set to `YES`, will automatically invert the content so that it’s layed out bottom to top, that is the ‘first’ (indexPath 0, 0) node is at the bottom rather than the top as usual. This is extremely covenient for chat/messaging apps, and with Texture it only takes one property.
