import UIKit
import Macaw

class CleanerExampleController: UIViewController {
	@IBOutlet var macawView: CleanerView!

	@IBAction func pickUpRequested(sender: AnyObject) {
		update(.PICKUP_REQUESTED)
	}

	@IBAction func cleanerOnWay(sender: AnyObject) {
		update(.CLEANER_ON_WAY)
	}

	@IBAction func nowCleaning(sender: AnyObject) {
		update(.NOW_CLEANING)
	}

	@IBAction func clothesClean(sender: AnyObject) {
		update(.CLOTHES_CLEAN)
	}

	@IBAction func cleanDone(sender: AnyObject) {
		update(.DONE)
	}

	func update(newState: CleanState) {
		let g = CleanersGraphics()
		macawView.groupNode.contentsVar.removeAll()
		macawView.groupNode.contentsVar.append(g.graphics(newState))
	}
}
