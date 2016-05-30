import UIKit
import Macaw

class AnimationsView: MacawView {

	var animations = [TransformAnimation]()
	var ballNodes = [Group]()

	let n = 100
	let speed = 20.0
	let r = 10.0

	required init?(coder aDecoder: NSCoder) {

		super.init(node: nil, coder: aDecoder)
	}

	required init?(node: Node?, coder aDecoder: NSCoder) {
		super.init(node: node, coder: aDecoder)
	}

	func startAnimation() {

		animations.forEach { animation in
			super.addAnimation(animation)
		}
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
			let scenePos = pos.add(Point(x: startPos.dx, y: startPos.dy))

			// Borders
			if scenePos.x < 0.0 || scenePos.x > Double(self.bounds.width) {
				velocity = Point(x: -1.0 * velocity.x, y: velocity.y)
				velocities[index] = velocity
				pos = prevPos.add(velocity)
			}

			if scenePos.y < 0.0 || scenePos.y > Double(self.bounds.height) {
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
			positions.append(Point(x: 0.0, y: 0.0))

			let animation = TransformAnimation(animatedNode: ballGroup, observableValue: ballGroup.posVar, valueFunc: { t -> Transform in

				let pos = posForTime(t, index: i)
				positions[i] = pos

				return startPos.move(
					pos.x,
					my: pos.y)
				}, animationDuration: 6.0)

			// animation.autoreverses = true

			animations.append(animation)
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
