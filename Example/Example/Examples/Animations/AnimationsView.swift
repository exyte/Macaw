import UIKit
import Macaw

class AnimationsView: MacawView {

	var animation: TransformAnimation?

	required init?(coder aDecoder: NSCoder) {
		let path = NSBundle.mainBundle().pathForResource("tree", ofType: "svg")
		let text = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)

		let transform = Transform().move(0, my: 0).scale(0.1, sy: 0.1)
		let parser = SVGParser(text, pos: transform)
		let tigerNode = parser.parse()

		print("Bounds: \(tigerNode.bounds()!.description())")

		animation = TransformAnimation(animatedShape: tigerNode, observableValue: tigerNode.posVar,
			startValue: Transform().scale(0.2, sy: 0.2),
			finalValue: Transform().scale(0.4, sy: 0.4),
			animationDuration: 8.0)
		animation?.autoreverses = true

		super.init(node: tigerNode, coder: aDecoder)
	}

	required init?(node: Node, coder aDecoder: NSCoder) {
		super.init(node: node, coder: aDecoder)
	}

	func testAnimation() {
		if let animation = animation {
			// self.addAnimation(animation)
		}
	}
}
