import UIKit
import Macaw

class SVGExampleView: MacawView {

	required init?(coder aDecoder: NSCoder) {
		let path = NSBundle.mainBundle().pathForResource("tiger", ofType: "svg")
		let text = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)

		//let transform = Transform().move(150, my: 150).scale(0.8, sy: 0.8)
		let parser = SVGParser(text)
		let tigerNode = parser.parse()

		super.init(node: tigerNode, coder: aDecoder)
	}

	required init?(node: Node?, coder aDecoder: NSCoder) {
		super.init(node: node, coder: aDecoder)
	}
}
