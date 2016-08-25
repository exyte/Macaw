
import Foundation

class GeomUtils {
	class func concat(t1: Transform, t2: Transform) -> Transform {
		let nm11 = t2.m11 * t1.m11 + t2.m12 * t1.m21
		let nm21 = t2.m21 * t1.m11 + t2.m22 * t1.m21
		let ndx = t2.dx * t1.m11 + t2.dy * t1.m21 + t1.dx
		let nm12 = t2.m11 * t1.m12 + t2.m12 * t1.m22
		let nm22 = t2.m21 * t1.m12 + t2.m22 * t1.m22
		let ndy = t2.dx * t1.m12 + t2.dy * t1.m22 + t1.dy
		return Transform(m11: nm11, m12: nm12, m21: nm21, m22: nm22, dx: ndx, dy: ndy)
	}
}
