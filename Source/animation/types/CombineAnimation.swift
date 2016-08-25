
import Foundation

public class CombineAnimation: Animatable {

	let animations: [Animatable]

	required public init(animations: [Animatable]) {
		self.animations = animations

		super.init()

		type = .Combine
		self.node = animations.first?.node

	}

	override func getDuration() -> Double {
		if let maxElement = animations.map({ $0.getDuration() }).maxElement() {
			return maxElement
		}

		return 0.0
	}

	public override func stop() {
		animations.forEach { animation in
			animation.stop()
		}
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