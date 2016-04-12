import UIKit
import Macaw

class AnimationsView: MacawView {

	required init?(coder aDecoder: NSCoder) {

		let group = Group(
			contents: [
				pieChart(),
				arc()
			],
			pos: Transform().move(0.0, my: 0.0)
		)

		super.init(node: group, coder: aDecoder)
	}

	required init?(node: Node, coder aDecoder: NSCoder) {
		super.init(node: node, coder: aDecoder)
	}
}
