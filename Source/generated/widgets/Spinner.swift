import Foundation

class Spinner: Widget  {

	var val: Int = 0
	var min: Int = 0
	var max: Int = 2147483647


	init(val: Int = 0, min: Int = 0, max: Int = 2147483647) {
		self.val = val	
		self.min = min	
		self.max = max	
	}

}
