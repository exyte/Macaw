import Foundation

open class Shape: Node {

	open let formVar: AnimatableVariable<Locus>
	open var form: Locus {
		get { return formVar.value }
		set(val) { formVar.value = val }
	}

	open let fillVar: AnimatableVariable<Fill?>
	open var fill: Fill? {
		get { return fillVar.value }
		set(val) { fillVar.value = val }
	}

	open let strokeVar: AnimatableVariable<Stroke?>
	open var stroke: Stroke? {
		get { return strokeVar.value }
		set(val) { strokeVar.value = val }
	}

	public init(form: Locus, fill: Fill? = nil, stroke: Stroke? = nil, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
		self.formVar = AnimatableVariable<Locus>(form)
		self.fillVar = AnimatableVariable<Fill?>(fill)
		self.strokeVar = AnimatableVariable<Stroke?>(stroke)
		super.init(
			place: place,
			opaque: opaque,
			opacity: opacity,
			clip: clip,
			effect: effect,
			visible: visible,
			tag: tag
		)
        
        self.formVar.node = self
        self.strokeVar.node = self
        self.fillVar.node = self
	}

	// GENERATED NOT
	override internal func bounds() -> Rect? {

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
        } else if let arc = form as? Arc {
            let ellipse = arc.ellipse            
            bounds = Rect(
                x: ellipse.cx - ellipse.rx,
                y: ellipse.cy - ellipse.ry,
                w: ellipse.rx * 2.0,
                h: ellipse.ry * 2.0)
            
		} else if let rect = form as? Rect {
			bounds = rect
        } else if let roundRect = form as? RoundRect {
            bounds = roundRect.rect
        } else if let line = form as? Line {
            bounds = Rect(
                x: min(line.x1, line.x2),
                y: min(line.y1, line.y2),
                w: abs(line.x1 - line.x2),
                h: abs(line.y1 - line.y2))
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
