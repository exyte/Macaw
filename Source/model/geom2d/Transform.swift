import Foundation
import RxSwift

public final class Transform {

	public let m11: Double
	public let m12: Double
	public let m21: Double
	public let m22: Double
	public let dx: Double
	public let dy: Double

	public init(m11: Double = 1, m12: Double = 0, m21: Double = 0, m22: Double = 1, dx: Double = 0, dy: Double = 0) {
		self.m11 = m11
		self.m12 = m12
		self.m21 = m21
		self.m22 = m22
		self.dx = dx
		self.dy = dy
	}

	// GENERATED NOT
	public func move(mx: Double, my: Double) -> Transform {
		return Transform(m11: m11, m12: m12, m21: m21, m22: m22,
			dx: mx * m11 + my * m21 + dx, dy: mx * m12 + my * m22 + dy)
	}
	// GENERATED NOT
	public func scale(sx: Double, sy: Double) -> Transform {
		return Transform(m11: m11 * sx, m12: m12 * sx, m21: m21 * sy, m22: m22 * sy, dx: dx, dy: dy)
	}
	// GENERATED NOT
	public func shear(shx: Double, shy: Double) -> Transform {
		return Transform(m11: m11 + m21 * shy, m12: m12 + m22 * shy,
			m21: m11 * shx + m21, m22: m12 * shx + m22, dx: dx, dy: dy)
	}
	// GENERATED NOT
	public func rotate(angle: Double) -> Transform {
		let asin = sin(angle); let acos = cos(angle)
		return Transform(m11: acos * m11 + asin * m21, m12: acos * m12 + asin * m22,
			m21: -asin * m11 + acos * m21, m22: -asin * m12 + acos * m22, dx: dx, dy: dy)
	}

	// GENERATED
	public class func move(mx: Double, my: Double) -> Transform {
		return Transform(dx: mx, dy: my)
	}

	// GENERATED
	public class func scale(sx: Double, sy: Double) -> Transform {
		return Transform(m11: sx, m22: sy)
	}

	// GENERATED
	public class func shear(shx: Double, shy: Double) -> Transform {
		return Transform(m12: shx, m21: shy)
	}

	// GENERATED NOT
	public class func rotate(angle: Double) -> Transform {
		let asin = sin(angle); let acos = cos(angle)
		return Transform(m11: acos, m12: asin, m21: -asin, m22: acos)
	}

}
