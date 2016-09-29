import UIKit

public extension Rect {

	convenience init(cgRect: CGRect) {
		self.init(
			x: Double(cgRect.origin.x),
			y: Double(cgRect.origin.y),
			w: Double(cgRect.size.width),
			h: Double(cgRect.size.height))
	}

	func cgRect() -> CGRect {
		return CGRect(x: self.x, y: self.y, width: self.w, height: self.h)
	}

	func applyTransform(_ transform: Transform) -> Rect {

		// TODO: Rewrite using math

		let cgTransform = RenderUtils.mapTransform(transform)
		return Rect(cgRect: self.cgRect().applying(cgTransform))
	}

	public func description() -> String {
		return "x: \(self.x) y:\(self.y) w:\(self.w) h:\(self.h)"
	}
}

public extension Point {
	public func cgPoint() -> CGPoint {
		return CGPoint(x: self.x, y: self.y)
	}

	public func description() -> String {
		return "x: \(self.x) y:\(self.y)"
	}
}
