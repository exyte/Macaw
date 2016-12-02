import UIKit
import Macaw

class SVGChartsView: MacawView {

	required init?(coder aDecoder: NSCoder) {
		super.init(node: SVGParser.parse(path: "pie-chart") ?? Group(), coder: aDecoder)
	}

}
