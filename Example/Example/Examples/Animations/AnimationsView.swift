import UIKit
import Macaw
import RxSwift

class AnimationsView: MacawView {

	var animations = [Animatable]()
	var ballNodes = [Group]()

	let n = 100
	let speed = 20.0
	let r = 10.0

	required init?(coder aDecoder: NSCoder) {
		super.init(node: Group(), coder: aDecoder)
	}

	func startAnimation() {

		animations.combine().start()
	}

	func prepareAnimation() {

		animations.removeAll()
		ballNodes.removeAll()

		let startPos = Transform.move(Double(self.center.x), my: Double(self.center.y))

		var velocities = [Point]()
		var positions = [Point]()

		func posForTime(t: Double, index: Int) -> Point {

			let prevPos = positions[index]
			var velocity = velocities[index]

			var pos = prevPos.add(velocity)

			// Borders
			if pos.x < 0.0 || pos.x > Double(self.bounds.width) {
				velocity = Point(x: -1.0 * velocity.x, y: velocity.y)
				velocities[index] = velocity
				pos = prevPos.add(velocity)
			}

			if pos.y < 0.0 || pos.y > Double(self.bounds.height) {
				velocity = Point(x: velocity.x, y: -1.0 * velocity.y)
				velocities[index] = velocity
				pos = prevPos.add(velocity)
			}

			return pos
		}

		for i in 0 ... (n - 1) {

			// Node
			let circle = Circle(cx: r, cy: r, r: r)
			let shape = Shape(
				form: circle,
				fill: [Color.red, Color.green, Color.blue, Color.yellow, Color.olive, Color.purple][Int(rand() % 6)]
			)

			let ballGroup = Group(contents: [shape], pos: startPos)
			ballNodes.append(ballGroup)

			// Animation
			let velocity = Point(
				x: -0.5 * speed + speed * Double(rand() % 1000) / 1000.0,
				y: -0.5 * speed + speed * Double(rand() % 1000) / 1000.0)
			velocities.append(velocity)
			positions.append(Point(x: startPos.dx, y: startPos.dy))

			let animation = TransformAnimation(animatedNode: ballGroup, valueFunc: { t -> Transform in

				let pos = posForTime(t, index: i)
				positions[i] = pos

				return Transform().move(
					pos.x,
					my: pos.y)
				}, animationDuration: 3.0)

			// animation.autoreverses = true

			let opacityAnimation = OpacityAnimation(animatedNode: ballGroup, startValue: 0.1, finalValue: 1.0, animationDuration: 3.0)

			animations.append([animation, opacityAnimation].combine())
		}

		let node = Group(contents: ballNodes)
		self.node = node
	}

	func stopAnimation() {
		animations.forEach { animation in
			animation.stop()
		}
	}
}
