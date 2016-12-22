//
//  AnimationImpl.swift
//  Pods
//
//  Created by Yuri Strot on 9/2/16.
//
//

import Foundation

enum AnimationType {
	case unknown
    case contents
	case affineTransformation
	case opacity
	case sequence
	case combine
	case empty
}

class BasicAnimation: Animation {

	var node: Node?
	var type = AnimationType.unknown
	let ID: String
	var next: BasicAnimation?
	var removeFunc: (() -> ())?
    var manualStop = false
	var progress = 0.0
	var repeatCount = 0.0
	var delay = 0.0
	var autoreverses = false
	var onProgressUpdate: ((Double) -> ())?
	var easing = Easing.ease
	var completion: (() -> ())?

	override init() {
		ID = UUID().uuidString
		super.init()
	}

    override open func delay(_ delay: Double) -> Animation {
        self.delay += delay
        return self
    }

	override open func cycle(_ count: Double) -> Animation {
		self.repeatCount = count
		return self
	}

	override open func easing(_ easing: Easing) -> Animation {
		self.easing = easing
		return self
	}

	override open func autoreversed() -> Animation {
		self.autoreverses = true
        
		return self
	}

	override open func onComplete(_ f: @escaping (() -> ())) -> Animation {
		self.completion = f
		return self
	}

	override open func play() {
		animationProducer.addAnimation(self)
	}

	override open func stop() {
        manualStop = true
		removeFunc?()
	}

	override open func reverse() -> Animation {
		return self
	}

	func getDuration() -> Double { return 0 }

}

// Animated property list https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreAnimation_guide/AnimatableProperties/AnimatableProperties.html
internal class AnimationImpl<T: Interpolable>: BasicAnimation {

	let value: AnimatableVariable<T>
    let timeFactory: (() -> ((Double) -> T))
	let duration: Double
	let logicalFps: UInt

    private var vFunc: ((Double) -> T)?

	init(observableValue: AnimatableVariable<T>, valueFunc: @escaping (Double) -> T, animationDuration: Double, delay: Double = 0.0, fps: UInt = 30) {
		self.value = observableValue
		self.duration = animationDuration
        self.timeFactory = { (node) in return valueFunc }
		self.vFunc = .none
		self.logicalFps = fps

		super.init()

		self.delay = delay
	}
    
    init(observableValue: AnimatableVariable<T>, factory: @escaping (() -> ((Double) -> T)), animationDuration: Double, delay: Double = 0.0, fps: UInt = 30) {
        self.value = observableValue
        self.duration = animationDuration
        self.timeFactory = factory
        self.logicalFps = fps
        
        super.init()
        
        self.delay = delay
    }

	convenience init(observableValue: AnimatableVariable<T>, startValue: T, finalValue: T, animationDuration: Double) {
		let interpolationFunc = { (t: Double) -> T in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(observableValue: observableValue, valueFunc: interpolationFunc, animationDuration: animationDuration)
	}

	convenience init(observableValue: AnimatableVariable<T>, finalValue: T, animationDuration: Double) {
		self.init(observableValue: observableValue, startValue: observableValue.value, finalValue: finalValue, animationDuration: animationDuration)
	}

	open override func getDuration() -> Double {
		return duration
	}

    open func getVFunc() -> ((Double) -> T) {
        if let vFunc = vFunc {
            return vFunc
        }
        
        var timeFunc = { (t: Double) -> Double in
            return t
        }
        
        if autoreverses {
            let original = timeFunc
            timeFunc = { (t: Double) -> Double in
                if t <= 0.5 {
                    return original(t * 2.0)
                } else {
                    return original((1.0 - t) * 2.0)
                }
            }
        }
        
        vFunc = { (t: Double) -> T in
            return self.timeFactory()(timeFunc(t))
        }
        
        return vFunc!
    }

}

// For sequence completion
class EmptyAnimation: BasicAnimation {
	required init(completion: @escaping (() -> ())) {
		super.init()

		self.completion = completion
		self.type = .empty
	}
}

// MARK: - Animation Description

open class AnimationDescription <T> {
	open let valueFunc: (Double) -> T
	open var duration = 0.0
	open var delay = 0.0
	public init(valueFunc: @escaping (Double) -> T, duration: Double = 1.0, delay: Double = 0.0) {
		self.valueFunc = valueFunc
		self.duration = duration
		self.delay = delay
	}

	open func t(_ duration: Double, delay: Double = 0.0) -> AnimationDescription<T> {
		return AnimationDescription(valueFunc: valueFunc, duration: duration, delay: delay)
	}
}
