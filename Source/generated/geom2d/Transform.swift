import Foundation

class Transform {

	var m11: Float = 1
	var m12: Float = 0
	var m21: Float = 0
	var m22: Float = 1
	var dx: Float = 0
	var dy: Float = 0


	init(m11: Float = 1, m12: Float = 0, m21: Float = 0, m22: Float = 1, dx: Float = 0, dy: Float = 0) {
		self.m11 = m11	
		self.m12 = m12	
		self.m21 = m21	
		self.m22 = m22	
		self.dx = dx	
		self.dy = dy	
	}

	// GENERATED
	func move(dx: Float, dy: Float) -> Transform {
		return Transform(dx: dx, dy: dy)
	}

	// GENERATED
	func scale(sx: Float, sy: Float) -> Transform {
		return Transform(m11: sx, m22: sy)
	}

	// GENERATED
	func shear(shx: Float, shy: Float) -> Transform {
		return Transform(m12: shx, m21: shy)
	}

	// GENERATED
	func rotate(angle: Float) -> Transform {
		
	}

	// GENERATED
	func move(dx: Float, dy: Float) -> Transform {
		
	}

	// GENERATED
	func rotate(angle: Float) -> Transform {
		
	}

	// GENERATED
	func scale(sx: Float, sy: Float) -> Transform {
		
	}

	// GENERATED
	func shear(shx: Float, shy: Float) -> Transform {
		
	}

}
