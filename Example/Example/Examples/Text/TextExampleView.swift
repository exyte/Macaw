
import UIKit
import Macaw

class TextExampleView: MacawView {

	required init?(coder aDecoder: NSCoder) {
		let line2 = Line(x1: 10, y1: 450, x2: 350, y2: 450)
		let textLine = Shape(
			form: line2,
			stroke: Stroke(
				fill: Color.black,
				width: 1,
				cap: .round,
				join: .round
			)
		)

		let text = Text(
			text: "Toy top",
			font: Font(),
			fill: Fill(),
			align: Align.min,
			baseline: Baseline.top,
			pos: Transform().move(10, my: 450)
		)

		let text2 = Text(
			text: "Toy alphabetic",
			font: Font(),
			fill: Fill(),
			align: Align.min,
			baseline: Baseline.alphabetic,
			pos: Transform().move(80, my: 450)
		)

		let text3 = Text(
			text: "Toy bottom",
			font: Font(),
			fill: Fill(),
			align: Align.min,
			baseline: Baseline.bottom,
			pos: Transform().move(180, my: 450)
		)

		let text4 = Text(
			text: "Toy middle",
			font: Font(),
			fill: Fill(),
			align: Align.min,
			baseline: Baseline.mid,
			pos: Transform().move(250, my: 450)
		)

		let line3 = Line(x1: 50, y1: 470, x2: 50, y2: 600)
		let textLine2 = Shape(
			form: line3,
			stroke: Stroke(
				fill: Color.black,
				width: 1,
				cap: .round,
				join: .round
			)
		)

		let text5 = Text(
			text: "text",
			font: Font(),
			fill: Color.fuchsia,
			align: Align.min,
			baseline: Baseline.top,
			pos: Transform().move(50, my: 480)
		)

		let text6 = Text(
			text: "text",
			font: Font(),
			fill: Color.blue,
			align: Align.mid,
			baseline: Baseline.top,
			pos: Transform().move(50, my: 500)
		)

		let text7 = Text(
			text: "text",
			font: Font(),
			fill: Color.aqua,
			align: Align.max,
			baseline: Baseline.top,
			pos: Transform().move(50, my: 520)
		)

		let image1 = Image(src: "../sweet.png",
			xAlign: Align.min,
			yAlign: Align.min,
			aspectRatio: AspectRatio.slice,
			w: 100,
			h: 100,
			pos: Transform().move(100, my: 520)
		)

		let leftImage1 = Line(x1: 100, y1: 520, x2: 100, y2: 620)
		let l11 = Shape(
			form: leftImage1,
			stroke: Stroke(
				fill: Color.black,
				width: 1,
				cap: .round,
				join: .round
			)
		)

		let topImage1 = Line(x1: 100, y1: 520, x2: 200, y2: 520)
		let l12 = Shape(
			form: topImage1,
			stroke: Stroke(
				fill: Color.black,
				width: 1,
				cap: .round,
				join: .round
			)
		)

		let rightImage1 = Line(x1: 200, y1: 520, x2: 200, y2: 620)
		let l13 = Shape(
			form: rightImage1,
			stroke: Stroke(
				fill: Color.black,
				width: 1,
				cap: .round,
				join: .round
			)
		)

		let bottomImage1 = Line(x1: 100, y1: 620, x2: 200, y2: 620)
		let l14 = Shape(
			form: bottomImage1,
			stroke: Stroke(
				fill: Color.black,
				width: 1,
				cap: .round,
				join: .round
			)
		)

		let image2 = Image(src: "../sweet.png",
			xAlign: Align.min,
			yAlign: Align.min,
			aspectRatio: AspectRatio.meet,
			w: 100,
			h: 100,
			pos: Transform().move(250, my: 520)
		)

		let leftImage2 = Line(x1: 250, y1: 520, x2: 250, y2: 620)
		let l21 = Shape(
			form: leftImage2,
			stroke: Stroke(
				fill: Color.black,
				width: 1,
				cap: .round,
				join: .round
			)
		)

		let topImage2 = Line(x1: 250, y1: 520, x2: 350, y2: 520)
		let l22 = Shape(
			form: topImage2,
			stroke: Stroke(
				fill: Color.black,
				width: 1,
				cap: .round,
				join: .round
			)
		)

		let rightImage2 = Line(x1: 350, y1: 520, x2: 350, y2: 620)
		let l23 = Shape(
			form: rightImage2,
			stroke: Stroke(
				fill: Color.black,
				width: 1,
				cap: .round,
				join: .round
			)
		)

		let bottomImage2 = Line(x1: 250, y1: 620, x2: 350, y2: 620)
		let l24 = Shape(
			form: bottomImage2,
			stroke: Stroke(
				fill: Color.black,
				width: 1,
				cap: .round,
				join: .round
			)
		)

		let group = Group(
			contents: [
				textLine,
				text,
				text2,
				text3,
				text4,
				textLine2,
				text5,
				text6,
				text7,
				image1,
				l11,
				l12,
				l13,
				l14,
				image2,
				l21,
				l22,
				l23,
				l24,
			],
			pos: Transform().move(0, my: -400)
		)

		super.init(node: group, coder: aDecoder)
	}

}
