//
//  CustomView.swift
//  Example
//
//  Created by Yuri Strot on 12/19/15.
//  Copyright © 2015 Exyte. All rights reserved.
//

import UIKit
import Macaw

class ShapesExampleView: MacawView {

	required init?(coder aDecoder: NSCoder) {
		let text1 = ShapesExampleView.newText("Point", .move(dx: 100, dy: 40))
		let point = Point(x: 100, y: 50).stroke(fill: Color.black, width: 7, cap: .round)

		let text2 = ShapesExampleView.newText("Line", .move(dx: 250, dy: 40))
		let line = Line(x1: 200, y1: 50, x2: 300, y2: 50).stroke(fill: Color.black, width: 4)

		let text3 = ShapesExampleView.newText("Polyline", .move(dx: 100, dy: 90))
		let polyline = Polyline(points: [100, 100, 150, 150, 50, 150]).stroke(fill: Color.navy, dashes: [3, 3])

		let text4 = ShapesExampleView.newText("Polygon", .move(dx: 250, dy: 90))
		let polygon = Polygon(points: [250, 100, 300, 150, 200, 150]).fill(with: Color.blue)

		let text5 = ShapesExampleView.newText("Rect", .move(dx: 100, dy: 200))
        
		let rect = Rect(x: 50, y: 200, w: 100, h: 50).fill(with:
            LinearGradient(degree: 45, from: Color(val: 0xFFAE27), to: Color(val: 0xDE496D)))

		let text6 = ShapesExampleView.newText("RoundRect", .move(dx: 250, dy: 200))
		let round = Rect(x: 200, y: 200, w: 100, h: 50).round(rx: 10, ry: 10).fill(with: LinearGradient(
			x2: 1, y2: 1,
			stops: [
				Stop(offset: 0, color: Color(val: 0xDE496D)),
				Stop(offset: 0.5, color: Color(val: 0xAB49DE)),
				Stop(offset: 1, color: Color(val: 0x4954DE))
			]
		))

		let text7 = ShapesExampleView.newText("Circle", .move(dx: 75, dy: 300))
		let circle = Circle(cx: 75, cy: 325, r: 25).fill(with: RadialGradient(
			stops: [
				Stop(offset: 0, color: Color(val: 0xF5027C)),
				Stop(offset: 1, color: Color(val: 0x850143))
			]
		))

		let text8 = ShapesExampleView.newText("Ellipse", .move(dx: 175, dy: 300))
		let ellipse = Ellipse(cx: 175, cy: 325, rx: 50, ry: 25).fill(with: RadialGradient(
			fx: 0.05, fy: 0.05, r: 0.65,
			stops: [
				Stop(offset: 0, color: Color(val: 0x00ee00)),
				Stop(offset: 1, color: Color(val: 0x006600))
			]
		))

		let text9 = ShapesExampleView.newText("Arc", .move(dx: 275, dy: 300))
		let arc = Circle(cx: 250, cy: 300, r: 50).arc(shift: 0, extent: Double.pi / 2.0).stroke(fill: Color.green)

		let group = Group(
			contents: [
				point, line, polyline, polygon, rect, round, circle, ellipse, arc,
				text1, text2, text3, text4, text5, text6, text7, text8, text9
			]
		)

		super.init(node: group, coder: aDecoder)
	}

	fileprivate static func newText(_ text: String, _ place: Transform, baseline: Baseline = .bottom) -> Text {
		return Text(text: text, fill: Color.black, align: .mid, baseline: baseline, place: place)
	}

}
