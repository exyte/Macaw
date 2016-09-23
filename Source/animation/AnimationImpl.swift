//
//  AnimationImpl.swift
//  Pods
//
//  Created by Yuri Strot on 9/2/16.
//
//

import Foundation
import RxSwift

enum AnimationType {
	case Unknown
	case AffineTransformation
	case Opacity
	case Sequence
	case Combine
	case Empty
}

class BasicAnimation: Animation {

	var node: Node?
	var type = AnimationType.Unknown
	let ID: String
	var next: BasicAnimation?
	var removeFunc: (() -> ())?
    var manualStop = false
	var progress = 0.0
	var repeatCount = 0.0
	var delay = 0.0
	var autoreverses = false
	var onProgressUpdate: ((Double) -> ())?
	var easing = Easing.Ease
	var completion: (() -> ())?

	override init() {
		ID = NSUUID().UUIDString
		super.init()
	}

    override public func delay(delay: Double) -> Animation {
        self.delay += delay
        return self
    }

	override public func cycle(count: Double) -> Animation {
		self.repeatCount = count
		return self
	}

	override public func easing(easing: Easing) -> Animation {
		self.easing = easing
		return self
	}

	override public func autoreversed() -> Animation {
		self.autoreverses = true
		return self
	}

	override public func onComplete(f: (() -> ())) -> Animation {
		self.completion = f
		return self
	}

	override public func play() {
		animationProducer.addAnimation(self)
	}

	override public func stop() {
        manualStop = true
		removeFunc?()
	}

	override public func reverse() -> Animation {
		return self
	}

	func getDuration() -> Double { return 0 }

}

// Animated property list https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreAnimation_guide/AnimatableProperties/AnimatableProperties.html
internal class AnimationImpl<T: Interpolable>: BasicAnimation {

	let value: Variable<T>
    let timeFactory: ((Node) -> ((Double) -> T))
	let duration: Double
	let logicalFps: UInt

    private var vFunc: ((Double) -> T)?

	init(observableValue: Variable<T>, valueFunc: (Double) -> T, animationDuration: Double, delay: Double = 0.0, fps: UInt = 30) {
		self.value = observableValue
		self.duration = animationDuration
        self.timeFactory = { (node) in return valueFunc }
		self.vFunc = valueFunc
		self.logicalFps = fps

		super.init()

		self.delay = delay
	}
    
    init(observableValue: Variable<T>, factory: ((Node) -> ((Double) -> T)), animationDuration: Double, delay: Double = 0.0, fps: UInt = 30) {
        self.value = observableValue
        self.duration = animationDuration
        self.timeFactory = factory
        self.logicalFps = fps
        
        super.init()
        
        self.delay = delay
    }

	convenience init(observableValue: Variable<T>, startValue: T, finalValue: T, animationDuration: Double) {
		let interpolationFunc = { (t: Double) -> T in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(observableValue: observableValue, valueFunc: interpolationFunc, animationDuration: animationDuration)
	}

	convenience init(observableValue: Variable<T>, finalValue: T, animationDuration: Double) {
		self.init(observableValue: observableValue, startValue: observableValue.value, finalValue: finalValue, animationDuration: animationDuration)
	}

	public override func getDuration() -> Double {
		return duration
	}

    public func getVFunc() -> ((Double) -> T) {
        if (vFunc == nil) {
            vFunc = timeFactory(self.node!)
        }
        return vFunc!
    }

}

// For sequence completion
class EmptyAnimation: BasicAnimation {
	required init(completion: (() -> ())) {
		super.init()

		self.completion = completion
		self.type = .Empty
	}
}

// MARK: - Animation Description

public class AnimationDescription <T> {
	public let valueFunc: (Double) -> T
	public var duration = 0.0
	public var delay = 0.0
	public init(valueFunc: (Double) -> T, duration: Double = 1.0, delay: Double = 0.0) {
		self.valueFunc = valueFunc
		self.duration = duration
		self.delay = delay
	}

	public func t(duration: Double, delay: Double = 0.0) -> AnimationDescription<T> {
		return AnimationDescription(valueFunc: valueFunc, duration: duration, delay: delay)
	}
}
