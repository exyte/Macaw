//
//  CombineAnimation.swift
//  Pods
//
//  Created by Victor Sukochev on 08/08/16.
//
//

import Foundation

public class CombineAnimation: Animatable {

	let animations: [Animatable]

	required public init(animations: [Animatable]) {
		self.animations = animations

		super.init()

		type = .Combine

	}

	override func getDuration() -> Double {
		if let maxElement = animations.map({ $0.getDuration() }).maxElement() {
			return maxElement
		}

		return 0.0
	}
}

public extension SequenceType where Generator.Element: Animatable {
	public func combine() -> Animatable {

		var toCombine = [Animatable]()
		self.forEach { animation in
			toCombine.append(animation)
		}
		return CombineAnimation(animations: toCombine)
	}
}