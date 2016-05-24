import UIKit

class AnimationsExampleController: UIViewController {

	@IBOutlet var animView: AnimationsView?

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		animView?.prepareAnimation()
	}

	@IBAction func startAnimationAction() {

		animView?.prepareAnimation()
		animView?.startAnimation()
	}

	@IBAction func stopAnimationAction() {
		animView?.stopAnimation()
	}
}
