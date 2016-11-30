import Foundation

open class Circle: Locus {

	open let cx: Double
	open let cy: Double
	open let r: Double

	public init(cx: Double = 0, cy: Double = 0, r: Double = 0) {
		self.cx = cx
		self.cy = cy
		self.r = r
	}

	// GENERATED NOT
	open func arc(shift: Double, extent: Double) -> Arc {
		return Arc(ellipse: Ellipse(cx: cx, cy: cy, rx: r, ry: r), shift: shift, extent: extent)
	}

}
