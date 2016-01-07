import Foundation

public class Transform {

	let m11: Double
	let m12: Double
	let m21: Double
	let m22: Double
	let dx: Double
	let dy: Double

	public init(m11: Double = 1, m12: Double = 0, m21: Double = 0, m22: Double = 1, dx: Double = 0, dy: Double = 0) {
		self.m11 = m11	
		self.m12 = m12	
		self.m21 = m21	
		self.m22 = m22	
		self.dx = dx	
		self.dy = dy	
	}

	// GENERATED NOT
	public func move(dx: Double, dy: Double) -> Transform {
		return Transform()
	}
	// GENERATED NOT
	public func rotate(angle: Double) -> Transform {
		return Transform()
	}
	// GENERATED NOT
	public func scale(sx: Double, sy: Double) -> Transform {
		return Transform()
	}
	// GENERATED NOT
	public func shear(shx: Double, shy: Double) -> Transform {
		return Transform()
	}

	// GENERATED
	class func move(dx: Double, dy: Double) -> Transform {
		return Transform(dx: dx, dy: dy)
	}

	// GENERATED
	class func scale(sx: Double, sy: Double) -> Transform {
		return Transform(m11: sx, m22: sy)
	}

	// GENERATED
	class func shear(shx: Double, shy: Double) -> Transform {
		return Transform(m12: shx, m21: shy)
	}

	// GENERATED NOT
	class func rotate(angle: Double) -> Transform {
		return Transform()
	}

}
