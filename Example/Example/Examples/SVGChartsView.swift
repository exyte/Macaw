import UIKit
import Macaw

class SVGChartsView: MacawView {

	required init?(coder aDecoder: NSCoder) {
		let path = NSBundle.mainBundle().pathForResource("pie-chart", ofType: "svg")
		let text = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)

		let parser = SVGParser(text)
		let chartNode = parser.parse()

		super.init(node: chartNode, coder: aDecoder)
	}

	required init?(node: Node?, coder aDecoder: NSCoder) {
		super.init(node: node, coder: aDecoder)
	}
}
