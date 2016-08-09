import Foundation
import RxSwift

public class Shape: Node {

	public let formVar: Variable<Locus>
	public var form: Locus {
		get { return formVar.value }
		set(val) { formVar.value = val }
	}

	public let fillVar: Variable<Fill?>
	public var fill: Fill? {
		get { return fillVar.value }
		set(val) { fillVar.value = val }
	}

	public let strokeVar: Variable<Stroke?>
	public var stroke: Stroke? {
		get { return strokeVar.value }
		set(val) { strokeVar.value = val }
	}

	public let onTap = PublishSubject<TapEvent>()
	public let onPan = PublishSubject<PanEvent>()
	public let onRotate = PublishSubject<RotateEvent>()
	public let onPinch = PublishSubject<PinchEvent>()

	public init(form: Locus, fill: Fill? = nil, stroke: Stroke? = nil, pos: Transform = Transform(), opaque: NSObject = true, opacity: Double = 1, clip: Locus? = nil, visible: NSObject = true, tag: [String] = [], bounds: Rect? = nil) {
		self.formVar = Variable<Locus>(form)
		self.fillVar = Variable<Fill?>(fill)
		self.strokeVar = Variable<Stroke?>(stroke)
		super.init(
			pos: pos,
			opaque: opaque,
			opacity: opacity,
			clip: clip,
			visible: visible,
			tag: tag,
			bounds: bounds
		)
	}

	// GENERATED NOT
	override public func bounds() -> Rect? {

		// TODO: Implement more form types

		var bounds = Rect(x: 0.0, y: 0.0, w: 0.0, h: 0.0)
		if let path = form as? Path {
			bounds = pathBounds(path)!
		} else if let circle = form as? Circle {
			bounds = Rect(
				x: circle.cx - circle.r,
				y: circle.cy - circle.r,
				w: circle.r * 2.0,
				h: circle.r * 2.0)
		} else if let ellipse = form as? Ellipse {
			bounds = Rect(
				x: ellipse.cx - ellipse.rx,
				y: ellipse.cy - ellipse.ry,
				w: ellipse.rx * 2.0,
				h: ellipse.ry * 2.0)
		} else if let rect = form as? Rect {
			bounds = rect
		} else {
			bounds = form.bounds()
		}

		if let shapeStroke = self.stroke {
			let r = shapeStroke.width / 2.0
			bounds = Rect(
				x: bounds.x - r,
				y: bounds.y - r,
				w: bounds.w + r * 2.0,
				h: bounds.h + r * 2.0)
		}

		return bounds
	}

}