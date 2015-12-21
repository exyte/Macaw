import Foundation

public class Transform {

	let m11: Float
	let m12: Float
	let m21: Float
	let m22: Float
	let dx: Float
	let dy: Float

	public init(m11: Float = 1, m12: Float = 0, m21: Float = 0, m22: Float = 1, dx: Float = 0, dy: Float = 0) {
		self.m11 = m11	
		self.m12 = m12	
		self.m21 = m21	
		self.m22 = m22	
		self.dx = dx	
		self.dy = dy	
	}

	// GENERATED NOT
	public func move(dx: Float, dy: Float) -> Transform {
		return Transform()
	}
	// GENERATED NOT
	public func rotate(angle: Float) -> Transform {
		return Transform()
	}
	// GENERATED NOT
	public func scale(sx: Float, sy: Float) -> Transform {
		return Transform()
	}
	// GENERATED NOT
	public func shear(shx: Float, shy: Float) -> Transform {
		return Transform()
	}

	// GENERATED
	class func move(dx: Float, dy: Float) -> Transform {
		return Transform(dx: dx, dy: dy)
	}

	// GENERATED
	class func scale(sx: Float, sy: Float) -> Transform {
		return Transform(m11: sx, m22: sy)
	}

	// GENERATED
	class func shear(shx: Float, shy: Float) -> Transform {
		return Transform(m12: shx, m21: shy)
	}

	// GENERATED NOT
	class func rotate(angle: Float) -> Transform {
		return Transform()
	}

}
