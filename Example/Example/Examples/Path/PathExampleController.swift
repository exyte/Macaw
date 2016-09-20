import UIKit

class PathExampleController: UIViewController {
	var sceneView: PathExampleView?
	@IBOutlet var slider: UISlider?

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		sceneView?.testAnimation()
		sceneView?.onScaleUpdate = { scale in
			// self.slider?.value = Float(scale)

		}
	}

	@IBAction func onScaleUpdate(slider: UISlider) {
		sceneView?.updateScale(slider.value)
	}
}
