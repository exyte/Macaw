import UIKit
import Macaw

class SVGExampleView: MacawView {

	required init?(coder aDecoder: NSCoder) {
		super.init(node: SVGParser.parse(path: "tiger"), coder: aDecoder)
	}

}
