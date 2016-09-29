import UIKit
import Macaw

class RectShapeView: MacawView {

	var roundedRect: RoundRect!
	var rectShape: Shape!

	required init?(coder aDecoder: NSCoder) {
		let screenSize: CGRect = UIScreen.main.bounds

		let rect = RoundRect(
			rect: Rect(x: Double(screenSize.width / 2) - 50, y: Double(screenSize.height / 2) - 50, w: 100, h: 100),
			rx: 5,
			ry: 5
		)

		let rectShape = Shape(
			form: rect,
			fill: Color.rgb(r: 255, g: 0, b: 0)
		)

		self.rectShape = rectShape
		super.init(node: rectShape, coder: aDecoder)
	}

}
