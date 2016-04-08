import Foundation
import UIKit
import Macaw

class ModelListenersExampleController: UIViewController {
	@IBOutlet weak var macawView: RectShapeView!

	@IBOutlet weak var heightStepper: UIStepper!
	@IBOutlet weak var widthSteppter: UIStepper!
	@IBOutlet weak var radiusStepper: UIStepper!

	@IBAction func onHeightChange(sender: AnyObject) {
		updateForm()
	}

	@IBAction func onWidthChange(sender: AnyObject) {
		updateForm()
	}

	@IBAction func onRadiusChange(sender: AnyObject) {
		updateForm()
	}

	func updateForm() {
		let screenSize: CGRect = UIScreen.mainScreen().bounds
		let height = heightStepper.value
		let width = widthSteppter.value
		let radius = radiusStepper.value

		let newForm = RoundRect(
			rect: Rect(x: Double(screenSize.width / 2) - height / 2, y: Double(screenSize.height / 2) - width / 2, w: height, h: width),
			rx: radius,
			ry: radius
		)
		macawView.rectShape.form = newForm
	}
}
