# Macaw

[![CI Status](https://travis-ci.org/exyte/Macaw.svg?style=flat)](https://travis-ci.org/exyte/Macaw)
[![Version](https://img.shields.io/cocoapods/v/Macaw.svg?style=flat)](http://cocoapods.org/pods/Macaw)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-0473B3.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Macaw.svg?style=flat)](http://cocoapods.org/pods/Macaw)
[![Platform](https://img.shields.io/cocoapods/p/Macaw.svg?style=flat)](http://cocoapods.org/pods/Macaw)

<img src="https://raw.githubusercontent.com/exyte/Macaw/master/logo.png" width="400">

## Macaw是什么?

Macaw 是一个以swift编写，强大兼且容易使用的矢量图形库。

#### Macaw非常简单

用以下几句程序代码来开始使用Macaw：

```swift
class MyView: MacawView {

	required init?(coder aDecoder: NSCoder) {
		let text = Text(text: "Hello, World!", place: .move(dx: 145, dy: 100))
		super.init(node: text, coder: aDecoder)
	}

}
```

<img src="http://i.imgur.com/ffPc4mr.png" width="475">

#### Macaw支援SVG (可缩放矢量图形)

直接在你的iOS应用程序里包含可缩放矢量图形：

<img src="http://i.imgur.com/NWkEzcu.png" width="300">

#### Macaw 非常强大

利用Macaw仿射映像、用户事件、动画和各种特效去建立亮丽的应用程序：

<img src="http://i.imgur.com/pjmxrDI.gif" width="600">

## 积极性

现代的设计包含大量图像与复杂的动画。程序开发员需要花费大量时间把设计转换成可缩放图像以配合各种屏幕大小。利用Macaw，你可以把开发时间缩到最短并把所有图像转换成高层次[场景图]( https://zh.wikipedia.org/wiki/%E5%9C%BA%E6%99%AF%E5%9B%BE)。你甚至可以使用Macaw事件和动画支持，直接从你的设计工具算绘SVG (可缩放矢量图形)。

## 资源

### 文件
我们现正努力编写整套参考文件，你现在可以先阅读一下以下的文件：
* [新手指南](https://github.com/exyte/Macaw/wiki/Getting-started)
* [算绘可缩放矢量图形](https://github.com/exyte/Macaw/wiki/Render-SVG-file)
* [动画内容](https://github.com/exyte/Macaw/wiki/Content-animation)
* [动画合成处理](https://github.com/exyte/Macaw/wiki/Morphing-animation)

### 帖子
* [复制获得苹果设计大奖的应用程序](https://medium.com/exyte/replicating-apple-design-awarded-applications-70e5df4c4b94#.ckt1hfnei)
* [在iOS绘画API有多容易?](https://medium.com/exyte/how-friendly-can-drawing-api-be-on-ios-b3a818bf8105#.o9i35zcai)
* [Macaw iOS 文档库：动画合成处理](https://medium.com/exyte/macaw-ios-library-morphing-animations-and-touch-events-a4cb1c0be97f)

## 例子

[Macaw 例子](https://github.com/exyte/macaw-examples) 是一个知识库。由使用Macaw制作简单图表到复杂的元素周期表，你都可以在这里找到。

<img src="http://i.imgur.com/rQIh3qD.gif" height="280"> <img src="http://i.imgur.com/bIgHtzt.gif" height="280"> <img src="http://i.imgur.com/NiBT2rv.gif" height="280"> <img src="http://i.imgur.com/Un8TJKc.gif" height="280">

<img src="http://i.imgur.com/o6tBKW6.gif" height="280"><img src="http://i.imgur.com/1JXF60f.gif" height="280">


## 系统要求

* iOS 9.0+
* Mac OS X 10.11+
* Xcode 7.3+

## 安装

## [CocoaPods](http://cocoapods.org)

要安装，把以下句子加到你的Podfile中：
```ruby
pod "Macaw", "0.9.7"
```

## [Carthage](http://github.com/Carthage/Carthage)

```ogdl
github "Exyte/Macaw" ~> 0.9.7
```

## 从原始檔建立

从原始檔建立Macaw：
* 复制`git@github.com:exyte/Macaw.git`
* 打开终端机并执行 `cd <MacawRepo>/Example/`
* 执行 `pod install` 安装所有附属对象
* 执行 `open Example.xcworkspace/` 在Xcode打开工作项目

## 谁在使用Macaw?
超过一千名用户在他们的应用程序中使用Macaw。我们正着手准备使用者名单。
跟我们分享你的使用经验info@exyte.com ，我们会以Macaw贴纸致以谢意。

<img src="https://i.imgur.com/m0pBChS.jpg" height="200">

## 更新纪录

你可以通过版本查阅所有更新内容[更新纪录](https://github.com/exyte/Macaw/wiki/Change-Log)

## 作者

这个工作项目由[exyte](http://www.exyte.com)负责。我们设计并建立手机及虚拟现实/扩充实境应用程序。

## 版权

Macaw在MIT版权下提供。 查阅版权档案以获得更多信息。
