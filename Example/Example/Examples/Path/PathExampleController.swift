import UIKit

class PathExampleController: UIViewController {
	@IBOutlet var sceneView: PathExampleView?

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		sceneView?.testAnimation()
	}
}
