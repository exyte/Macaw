import UIKit
import Macaw

class AnimationsView: MacawView {

	var animations = [TransformAnimation]()

	required init?(coder aDecoder: NSCoder) {

		let n = 50
		let speed = 10.0
		let startPoint = Point(x: 150.0, y: 150.0)
		var ballNodes = [Group]()
		var velocities = [Point]()
		var positions = [Point]()

		let epsi = speed

		func posForTime(t: Double, index: Int) -> Point {

			let prevPos = positions[index]
			var velocity = velocities[index]

			var pos = prevPos.add(velocity)
			let scenePos = pos.add(startPoint)

			if scenePos.x < 0.0 || scenePos.x > 320.0 {
				velocity = Point(x: -1.0 * velocity.x, y: velocity.y)
				velocities[index] = velocity
				pos = prevPos.add(velocity)
			}

			if scenePos.y < 0.0 || scenePos.y > 640.0 {
				velocity = Point(x: velocity.x, y: -1.0 * velocity.y)
				velocities[index] = velocity
				pos = prevPos.add(velocity)
			}

			return pos
		}

		for i in 0 ... (n - 1) {
			let velocity = Point(
				x: -0.5 * speed + Double(rand()) % speed,
				y: -0.5 * speed + Double(rand()) % speed)
			velocities.append(velocity)
			positions.append(Point(x: 0.0, y: 0.0))
			let circle = Circle(cx: startPoint.x, cy: startPoint.y, r: 10)
			let shape = Shape(
				form: circle,
				fill: [Color.red, Color.green, Color.blue, Color.yellow, Color.olive, Color.purple][Int(rand() % 6)]
			)

			let ballGroup = Group(contents: [shape], pos: Transform())
			let animation = TransformAnimation(animatedShape: ballGroup, observableValue: ballGroup.posVar, valueFunc: { t -> Transform in

				let pos = posForTime(t, index: i)
				positions[i] = pos

				// print("New pos: \(newPos.description()) t = \(t)")

				return Transform().move(
					pos.x,
					my: pos.y)
				}, animationDuration: 20.0)

			animations.append(animation)
			ballNodes.append(ballGroup)
		}

		let node = Group(contents: ballNodes,
			pos: Transform().move(0.0, my: 0.0))

		super.init(node: node, coder: aDecoder)
	}

	required init?(node: Node, coder aDecoder: NSCoder) {
		super.init(node: node, coder: aDecoder)
	}

	func startAnimation() {
		animations.forEach { animation in
			super.addAnimation(animation)
		}
	}

	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
	}
}
