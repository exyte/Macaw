import UIKit
import Macaw

class CleanerView: MacawView {

	var groupNode: Group

	required init?(node: Node?, coder aDecoder: NSCoder) {
		let group = Group()
//        let g = CleanersGraphics()
//        group.contents.append(g.graphics(.PICKUP_REQUESTED))

		self.groupNode = group
		super.init(node: group, coder: aDecoder)
	}
}