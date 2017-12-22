# Macaw

[![CI Status](https://travis-ci.org/exyte/Macaw.svg?style=flat)](https://travis-ci.org/exyte/Macaw)
[![Version](https://img.shields.io/cocoapods/v/Macaw.svg?style=flat)](http://cocoapods.org/pods/Macaw)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-0473B3.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Macaw.svg?style=flat)](http://cocoapods.org/pods/Macaw)
[![Platform](https://img.shields.io/cocoapods/p/Macaw.svg?style=flat)](http://cocoapods.org/pods/Macaw)

<img src="https://github.com/exyte/Macaw/blob/master/logo.png" width="400">

## What is Macaw?

Macaw is a powerful and easy-to-use vector graphics library written in Swift.

#### It's simple

Get started with Macaw in several lines of code:

```swift
class MyView: MacawView {

	required init?(coder aDecoder: NSCoder) {
		let text = Text(text: "Hello, World!", place: .move(dx: 145, dy: 100))
		super.init(node: text, coder: aDecoder)
	}

}
```

<img src="http://i.imgur.com/ffPc4mr.png" width="475">

#### It has SVG support

Include Scalable Vector Graphics right into your iOS application:

<img src="http://i.imgur.com/NWkEzcu.png" width="300">

#### It's powerful

Affine transformations, user events, animation and various effects to build beautiful apps with Macaw:

<img src="http://i.imgur.com/pjmxrDI.gif" width="600">

## Motivation

Modern designs contain tons of illustrations and complex animations. Mobile developers have to spend a lot of time on converting designs into native views that will be resizable for different screens. With Macaw you can reduce development time to a minimum and describe all graphics in high level [scene](https://en.wikipedia.org/wiki/Scene_graph) elements. Or even render SVG graphics right from your design tool with Macaw events and animation support.

## Resources

### Docs
We're working hard to provide full documentation. Currently you can take a look at the following docs:
* [Getting started guide](https://github.com/exyte/Macaw/wiki/Getting-started)
* [Render SVG file](https://github.com/exyte/Macaw/wiki/Render-SVG-file)
* [Content animation](https://github.com/exyte/Macaw/wiki/Content-animation)
* [Morphing animation](https://github.com/exyte/Macaw/wiki/Morphing-animation)

### Posts
* [Replicating Apple Design Awarded Applications](https://medium.com/exyte/replicating-apple-design-awarded-applications-70e5df4c4b94#.ckt1hfnei)
* [How friendly can drawing API be on iOS?](https://medium.com/exyte/how-friendly-can-drawing-api-be-on-ios-b3a818bf8105#.o9i35zcai)
* [Macaw iOS Library: Morphing Animations](https://medium.com/exyte/macaw-ios-library-morphing-animations-and-touch-events-a4cb1c0be97f)

## Examples

[Macaw-Examples](https://github.com/exyte/macaw-examples) is a repository where you can find various usages of the `Macaw` library from simple charts to the complex periodic table.

<img src="http://i.imgur.com/rQIh3qD.gif" height="280"> <img src="http://i.imgur.com/bIgHtzt.gif" height="280"> <img src="http://i.imgur.com/NiBT2rv.gif" height="280"> <img src="http://i.imgur.com/Un8TJKc.gif" height="280">

<img src="http://i.imgur.com/o6tBKW6.gif" height="280"><img src="http://i.imgur.com/1JXF60f.gif" height="280">


## Requirements

* iOS 8.0+
* Mac OS X 10.11+
* Xcode 7.3+

## Installation

## [CocoaPods](http://cocoapods.org)

To install it, simply add the following line to your Podfile:
```ruby
pod "Macaw", "0.9.1"
```

## [Carthage](http://github.com/Carthage/Carthage)

```ogdl
github "Exyte/Macaw" ~> 0.9.1
```

## Building from sources

To build Macaw from sources:
* clone the repo `git@github.com:exyte/Macaw.git`
* open terminal and run `cd <MacawRepo>/Example/`
* run `pod install` to install all dependencies
* run `open Example.xcworkspace/` to open project in the Xcode

## Who is using Macaw?
Over one thousand users already utilize Macaw in their applications. We would like to prepare the list of top use cases.
Please share your story with us at info@exyte.com and we will thank you with Macaw stickers!

<img src="https://i.imgur.com/m0pBChS.jpg" height="200">

## Change Log

You can find list of all changes by version in the [Change Log](https://github.com/exyte/Macaw/wiki/Change-Log)

## Author

This project is maintained by [exyte](http://www.exyte.com). We design and build mobile and VR/AR applications.

## License

Macaw is available under the MIT license. See the LICENSE file for more info.
