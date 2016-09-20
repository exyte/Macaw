# Macaw

[![CI Status](http://img.shields.io/travis/Igor Zapletnev/Macaw.svg?style=flat)](https://travis-ci.org/Igor Zapletnev/Macaw)
[![Version](https://img.shields.io/cocoapods/v/Macaw.svg?style=flat)](http://cocoapods.org/pods/Macaw)
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

<img src="https://www.dropbox.com/s/o4xe3eezk4zv901/macaw-readme-001.png?dl=1" width="450">

#### It has SVG support

Include Scalable Vector Graphics right into your application:

```swift
class SVGView: MacawView {

    required init?(coder aDecoder: NSCoder) {
        super.init(node: SVGParser.parse(path: "tiger"), coder: aDecoder)
    }

}
```

<img src="https://www.dropbox.com/s/p84o7komopmb2yn/macaw-howto-004.png?dl=1" width="450">

#### It's powerful

Affine transformations, user events, animation and various effects to build beautiful apps with Macaw:

<img src="https://www.dropbox.com/s/l4di5aswo28ksix/periodic.gif?dl=1" width="508">

Take a look at [getting started guide](https://github.com/exyte/Macaw/wiki/Getting-started) to learn more.

## Requirements

* iOS 8.0+ / Mac OS X 10.9+
* Xcode 7.3+

## Installation

Macaw is available through [CocoaPods](http://cocoapods.org).
To install it, simply add the following line to your Podfile:

```ruby
pod "Macaw"
```

## Building from sources

To build Macaw from sources:
* clone the repo `git@github.com:exyte/Macaw.git`
* open terminal and run `cd <MacawRepo>/Example/`
* run `pod install` to install all dependencies
* run `open Example.xcworkspace/` to open project in the Xcode

## Author

exyte, [info@exyte.com](mailto:info@exyte.com)

## License

Macaw is available under the MIT license. See the LICENSE file for more info.
