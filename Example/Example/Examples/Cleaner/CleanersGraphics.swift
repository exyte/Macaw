import UIKit
import Macaw

enum CleanState {
	case PICKUP_REQUESTED
	case CLEANER_ON_WAY
	case NOW_CLEANING
	case CLOTHES_CLEAN
	case DONE
}

class CleanersGraphics {

	let activeColor = Color(val: 8375023)
	let disableColor = Color(val: 13421772)
	let buttonColor = Color(val: 1745378)
	let textColor = Color(val: 5940171)
	let size = 0.7
	let delta = 0.06
	let fontName = "MalayalamSangamMN"

	private let x: Double
	private let y: Double
	private let r: Double

	init() {
		let screenSize: CGRect = UIScreen.mainScreen().bounds
		x = Double(screenSize.size.width / 2)
		y = Double(screenSize.size.height / 2)
		r = Double(screenSize.size.width / 2) * size
	}

	func graphics(state: CleanState) -> Group {
		switch state {
		case .PICKUP_REQUESTED:
			return pickupRequested()
		case .CLEANER_ON_WAY:
			return cleanerOnTheWay()
		case .NOW_CLEANING:
			return nowCleaning()
		case .CLOTHES_CLEAN:
			return clothesClean()
		case .DONE:
			return cleanDone()
		}
	}

	func pickupRequested() -> Group {
		return Group(contents: [
			background(segment: 0),
			text("PICK UP", y, textColor),
			text("REQUESTED", y + 35, textColor)
		])
	}

	func cleanerOnTheWay() -> Group {
		return Group(contents: [
			background(segment: 1),
			fillSegment(),
			cancelGroup(),
			text("CLEANER", y, textColor),
			text("ON THE WAY", y + 35, textColor)
		])
	}

	func nowCleaning() -> Group {
		return Group(contents: [
			background(segment: 2),
			text("NOW", y, textColor),
			text("CLEANING", y + 35, textColor)
		])
	}

	func clothesClean() -> Group {
		let lineY = y + r * 0.65
		return Group(contents: [
			background(segment: 2),
			text("CLOTHES", y, textColor),
			text("CLEAN!", y + 35, textColor),
			fillSegment(),
			text("REQUEST", lineY, Color.white, 16),
			text("DELIVERY", lineY + 18, Color.white, 16)
		])
	}

	func cleanDone() -> Group {
		let doneCircle = Shape(form: Circle(cx: x, cy: y, r: r), fill: buttonColor)

		let clothes = text("Clothes", y, Color.white, 45)
		let clean = text("Clean!", y + 35, Color.white, 45)
		let firstLineY = y + r * 0.65

		let request = text("PAY & REQUEST", firstLineY, Color.white, 16)
		let delivery = text("DELIVERY", firstLineY + 18, Color.white, 16)

		let margin = r * 0.2
		let lineY = y + r * 0.4
		let line = Line(x1: x - r + margin, y1: lineY, x2: x + r - margin, y2: lineY)
		let hLine = Shape(form: line, stroke: Stroke(fill: Color.white, width: 1.0))

		return Group(contents: [
			doneCircle,
			clothes,
			clean,
			request,
			delivery,
			hLine
		])
	}

	func background(segment count: Int = 0) -> Group {
		func arc(extent: Double, shift: Double, color: Macaw.Color) -> Shape {
			let ellipse = Ellipse(cx: x, cy: y, rx: r, ry: r)
			let arc = Arc(ellipse: ellipse, shift: shift, extent: extent)
			let arcStroke = Stroke(fill: color, width: 6, cap: .round, join: .round)
			return Shape(form: arc, stroke: arcStroke)
		}

		func color(index: Int = 0) -> Color {
			if index < count {
				return activeColor
			}
			return disableColor
		}

		return Group(
			contents: [
				arc(M_PI + M_PI_2 + delta, shift: M_PI_2 - delta, color: color(0)),
				arc(delta, shift: M_PI_2 - delta, color: color(1)),
				arc(M_PI_2 + delta, shift: M_PI_2 - delta, color: color(2)),
				arc(M_PI + delta, shift: M_PI_2 - delta, color: color(3))
			]
		)
	}

	func cancelGroup() -> Group {
		let cancel = text("CANCEL", 0, Color.white, 16)
		cancel.place = .move(0, my: 0)

		let cancelCross = MoveTo(x: 0, y: 0).l(6, 6).M(6, 0).l(-6, 6).build()
		let cancelGroup = Group(contents: [
			Shape(
				form: cancelCross,
				stroke: Stroke(fill: Color.white, width: 1.3),
				place: Transform.scale(3, sy: 3).move(-20, my: -7)
			)
		])
		return Group(
			contents: [cancel, cancelGroup],
			place: .move(x + 20, my: y + r * 0.7)
		)
	}

	func fillSegment() -> Group {
		let fillSegment = Shape(
			form: Circle(cx: x, cy: y, r: r * 0.9),
			fill: buttonColor
		)
		let clip = Rect(x: x - r, y: y + r * 0.4, w: r * 2, h: r * 2)
		return Group(contents: [fillSegment], clip: clip)
	}

	func text(text: String, _ y: Double, _ color: Color, _ size: Int = 32) -> Text {
		return Text(
			text: text,
			font: Font(name: fontName, size: size),
			fill: color,
			align: Align.mid,
			baseline: Baseline.bottom,
			place: .move(x, my: y)
		)
	}
}