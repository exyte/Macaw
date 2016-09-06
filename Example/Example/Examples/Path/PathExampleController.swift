import UIKit

class PathExampleController: UIViewController {
	@IBOutlet var sceneView: PathExampleView?

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		sceneView?.testAnimation()
	}

	@IBAction func onScaleUpdate(slider: UISlider) {
		sceneView?.updateScale(slider.value)
	}
}
