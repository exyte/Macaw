import Foundation

class Widget: Styleable  {

	var enable: Bool = true
	var tooltip: String = ""
	var bounds: Rect

	init(enable: Bool = true, tooltip: String = "", bounds: Rect, id: String, style: [String: NSObject], pseudo: [String: [String: NSObject]]) {
		self.enable = enable	
		self.tooltip = tooltip	
		self.bounds = bounds	
		super.init(
			id: id,
			style: style,
			pseudo: pseudo
		)
	}

	// GENERATED NOT
	func mouse() -> Mouse {
        // TODO initial implementation
        return Mouse(hover: false, pos: Point(), onEnter: Signal(), onExit: Signal(), onWheel: Signal())
    }

}
