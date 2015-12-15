import Foundation

class Widget: Styleable  {

	var enable: Bool = true
	var tooltip: String = ""
	var bounds: Rect


	init(enable: Bool = true, tooltip: String = "", bounds: Rect) {
		self.enable = enable	
		self.tooltip = tooltip	
		self.bounds = bounds	
	}

	// GENERATED
	func mouse() -> Mouse {
		
	}

}
