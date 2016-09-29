import UIKit

class AnimationsExampleController: UIViewController {

	var animView: AnimationsView?

	override func viewDidAppear(_ animated: Bool) {
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
