import UIKit
import Macaw

class AnimationsView: MacawView {

	required init?(coder aDecoder: NSCoder) {
		let path = NSBundle.mainBundle().pathForResource("sunset-tree", ofType: "svg")
		let text = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)

		let transform = Transform().move(150, my: 150).scale(0.8, sy: 0.8)
		let parser = SVGParser(text, pos: transform)
		let tigerNode = parser.parse()

		super.init(node: tigerNode, coder: aDecoder)
	}

	required init?(node: Node, coder aDecoder: NSCoder) {
		super.init(node: node, coder: aDecoder)
	}
}
