
import UIKit
import Macaw

class DiagramExampleView: MacawView {

	required init?(coder aDecoder: NSCoder) {

		func chartExample() -> Group {

			let rect = Rect(x: 10, y: 20, w: 355, h: 300)
			let baseRect = Shape(
				form: rect,
				fill: Color.rgb(r: 33, g: 39, b: 53)
			)

			var lines: [Node] = []
			for lineIndex in 1 ... 15 {
				let y: Double = Double(lineIndex * lineIndex) + 20
				let l = Line(x1: 20, y1: y, x2: 350, y2: y)
				let line = Shape(
					form: l,
					stroke: Stroke(
                        fill: Color.rgb(r: 60, g: 68, b: 80),
						width: 1,
						cap: .round,
						join: .round
					)
				)
				lines.append(line)
			}

			var dates: [Text] = []
			for dateIndex in 1 ... 8 {
				let x: Double = Double(dateIndex) * 45
				var text = Text(
					text: "0\(dateIndex)",
					font: Font(name: "Helvetica", size: 14),
					fill: dateIndex != 5 ? Color.gray : Color.white,
					align: Align.max,
					baseline: Baseline.top,
					place: .move(dx: x, dy: 300)
				)
				dates.append(text)
			}

			func blueLine() -> Path {
                return MoveTo(x: 18.00, y: 234.00)
                    .C(50.16, 202.39, 70.88, 213.58, 74.00, 213.00)
                    .C(164.00, 231.00, 117.00, 115.00, 251.00, 144.00)
                    .C(298.00, 159.54, 348.00, 111.00, 345.00, 98.00).build()
			}

			let blueLineShape = Shape(
				form: blueLine(),
				stroke: Stroke(
                    fill: Color.rgb(r: 62, g: 180, b: 254),
					width: 2,
					cap: .round,
					join: .round
				)
			)

			func redLine() -> Path {
                return MoveTo(x: 18.00, y: 154.00)
                    .C(61.50, 189.00, 81.50, 166.50, 85.50, 160.50)
                    .C(121.50, 113.50, 116.50, 131.00, 208.50, 104.00)
                    .C(285.00, 173.50, 294.50, 43.00, 350.50, 47.00).build()
			}

			let redLineShape = Shape(
				form: redLine(),
				stroke: Stroke(
					fill: Color.rgb(r: 255, g: 40, b: 105),
					width: 2,
					cap: .round,
					join: .round
				)
			)

			let outerCircle = Circle(cx: 220, cy: 140, r: 14)
			let outerCircleShape = Shape(
				form: outerCircle,
				fill: Color.rgb(r: 33, g: 39, b: 53)
			)

			let innerCircle = Circle(cx: 220, cy: 140, r: 9)
			let innerCircleShape = Shape(
				form: innerCircle,
				fill: Color.rgb(r: 62, g: 180, b: 254)
			)

			let textCloud = RoundRect(
				rect: Rect(x: 185, y: 95, w: 70, h: 20),
				rx: 8,
				ry: 8
			)

			let textCloudShape = Shape(
				form: textCloud,
				fill: Color.rgb(r: 62, g: 180, b: 254)
			)

			let cloudTriangle = Polygon(points: [215, 115, 225, 115, 220, 123])
			let cloudTriangleShape = Shape(
				form: cloudTriangle,
				fill: Color.rgb(r: 62, g: 180, b: 254)
			)

			let numberText = Text(
				text: "210.5",
				font: Font(name: "Helvetica", size: 14),
				fill: Color.white,
				align: Align.max,
				baseline: Baseline.top,
				place: .move(dx: 238, dy: 97)
			)

			let legend1 = RoundRect(
				rect: Rect(x: 80, y: 260, w: 90, h: 30),
				rx: 15,
				ry: 15
			)

			let legend1Shape = Shape(
				form: legend1,
				stroke: Stroke(
					fill: Color.white,
					width: 1,
					cap: .round,
					join: .round
				)
			)

			let legend1Circle = Circle(cx: 100, cy: 275, r: 8)
			let legend1CircleShape = Shape(
				form: legend1Circle,
				fill: Color.rgb(r: 62, g: 180, b: 254)
			)

			let legend1Text = Text(
				text: "Views",
				font: Font(name: "Helvetica", size: 14),
				fill: Color.white,
				align: Align.max,
				baseline: Baseline.top,
				place: .move(dx: 155, dy: 267)
			)

			let legend2 = RoundRect(
				rect: Rect(x: 220, y: 260, w: 90, h: 30),
				rx: 15,
				ry: 15
			)

			let legend2Shape = Shape(
				form: legend2,
				stroke: Stroke(
					fill: Color.gray,
					width: 1,
					cap: .round,
					join: .round
				)
			)

			let legend2Circle = Circle(cx: 240, cy: 275, r: 8)
			let legend2CircleShape = Shape(
				form: legend2Circle,
				fill: Color.rgb(r: 255, g: 40, b: 105)
			)

			let legend2Text = Text(
				text: "Likes",
				font: Font(name: "Helvetica", size: 14),
				fill: Color.gray,
				align: Align.max,
				baseline: Baseline.top,
				place: .move(dx: 290, dy: 267)
			)

			var groupContents = [Node]()
			groupContents.append(baseRect)
			groupContents.append(contentsOf: lines)
			groupContents.append(blueLineShape)
			groupContents.append(redLineShape)
			groupContents.append(outerCircleShape)
			groupContents.append(innerCircleShape)
			groupContents.append(textCloudShape)
			groupContents.append(cloudTriangleShape)
			groupContents.append(numberText)
			for date in dates {
				groupContents.append(date)
			}
			groupContents.append(legend1Shape)
			groupContents.append(legend2Shape)
			groupContents.append(legend1CircleShape)
			groupContents.append(legend2CircleShape)
			groupContents.append(legend1Text)
			groupContents.append(legend2Text)

			return Group(
				contents: groupContents
			)
		}

		let group = Group(
			contents: [
				chartExample()
			],
			place: .move(dx: 0, dy: 0)
		)

		super.init(node: group, coder: aDecoder)
	}

}
