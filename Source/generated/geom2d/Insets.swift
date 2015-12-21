import Foundation

public class Insets {

	let top: NSNumber
	let right: NSNumber
	let bottom: NSNumber
	let left: NSNumber

	public init(top: NSNumber = 0, right: NSNumber = 0, bottom: NSNumber = 0, left: NSNumber = 0) {
		self.top = top	
		self.right = right	
		self.bottom = bottom	
		self.left = left	
	}

}
