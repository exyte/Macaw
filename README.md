<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/header-dark.png"><img src="https://raw.githubusercontent.com/exyte/media/master/common/header-light.png"></picture></a>

<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/our-site-dark.png" width="80" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/our-site-light.png" width="80" height="16"></picture></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://twitter.com/exyteHQ"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/twitter-dark.png" width="74" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/twitter-light.png" width="74" height="16">
</picture></a> <a href="https://exyte.com/contacts"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-dark.png" width="128" height="24" align="right"><img src="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-light.png" width="128" height="24" align="right"></picture></a>

<h1>❗Macaw Deprecated❗</h1>

Check out <a href="https://github.com/exyte/Macaw/wiki/Deprecation">this post</a> for deatils. **TL;DR**:
* You can continue to use this framework as is: expect no new features or bug fixing; however, it will be updated to work in future Xcode releases.
* if you need some good declarative UI framework, please use [SwiftUI](https://developer.apple.com/xcode/swiftui/).
* If you need a powerful SVG support, please use [SVGView](https://github.com/exyte/SVGView).
* If you’d like to fix something in Macaw, feel free to fork this repo. Publish your PRs so that other people can use it as well. Some PRs will be merged from time to time.

<h1 align="center"></h1>

<img align="right" src="https://raw.githubusercontent.com/exyte/Macaw/master/demo.gif" width="480" />

<p><h1 align="left">Macaw</h1></p>

<p><h4>Powerful and easy-to-use vector graphics Swift library with SVG support</h4></p>

[![Version](https://img.shields.io/cocoapods/v/Macaw.svg?style=flat)](http://cocoapods.org/pods/Macaw)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-0473B3.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Macaw.svg?style=flat)](http://cocoapods.org/pods/Macaw)
[![Platform](https://img.shields.io/cocoapods/p/Macaw.svg?style=flat)](http://cocoapods.org/pods/Macaw)


## What is Macaw?

<img src="https://raw.githubusercontent.com/exyte/Macaw/master/logo.png" width="300">

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

<img src="http://i.imgur.com/rQIh3qD.gif" width="400"> 

<img src="http://i.imgur.com/bIgHtzt.gif" width="160"> <img src="http://i.imgur.com/NiBT2rv.gif" width="160"> <img src="http://i.imgur.com/Un8TJKc.gif" width="160">

<img src="http://i.imgur.com/o6tBKW6.gif" width="160"><img src="http://i.imgur.com/1JXF60f.gif" width="160">


## Requirements

* iOS 9.0+
* Mac OS X 10.11+
* Xcode 7.3+

## Installation

## [CocoaPods](http://cocoapods.org)

To install it, simply add the following line to your Podfile:
```ruby
pod "Macaw", "0.9.7"
```

## [Carthage](http://github.com/Carthage/Carthage)

```ogdl
github "Exyte/Macaw" ~> 0.9.7
```

## Building from sources

To build Macaw from sources:
* clone the repo `git@github.com:exyte/Macaw.git`
* open terminal and run `cd <MacawRepo>/Example/`
* run `pod install` to install all dependencies
* run `open Example.xcworkspace/` to open project in the Xcode

## Change Log

You can find list of all changes by version in the [Change Log](https://github.com/exyte/Macaw/wiki/Change-Log)

## License

Macaw is available under the MIT license. See the LICENSE file for more info.
