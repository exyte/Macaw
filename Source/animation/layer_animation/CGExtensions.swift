import UIKit

extension Rect {
	func cgRect() -> CGRect {
		return CGRect(x: self.x, y: self.y, width: self.w, height: self.h)
	}
}

extension Point {
	func cgPoint() -> CGPoint {
		return CGPoint(x: self.x, y: self.y)
	}
}
