import Macaw
import Foundation

func pieChart() -> Node {
	return Shape(
		form: Circle(cx: 100.0, cy: 100.0, r: 50.0),
		stroke: Stroke(
			fill: Color.rgb(255, g: 40, b: 105),
			width: 2,
			cap: .round,
			join: .round
	))
}

func arc() -> Node {

	let arc = Arc(ellipse: Ellipse(cx: 250, cy: 250, rx: 50, ry: 50), shift: M_PI / 2, extent: M_PI / 2)

	return Shape(
		form: arc,
		fill: Color.red,
		stroke: Stroke(
			fill: Color.rgb(255, g: 40, b: 105),
			width: 2,
			cap: .round,
			join: .round
	))
}
