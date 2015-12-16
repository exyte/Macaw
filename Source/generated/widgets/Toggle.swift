import Foundation

class Toggle: Widget  {

	var on: Bool = false
	var text: String = ""
	var image: NSObject

	init(on: Bool = false, text: String = "", image: NSObject, enable: Bool, tooltip: String, bounds: Rect, id: String, style: [String: NSObject], pseudo: [String: [String: NSObject]]) {
		self.on = on	
		self.text = text	
		self.image = image	
		super.init(
			enable: enable,
			tooltip: tooltip,
			bounds: bounds,
			id: id,
			style: style,
			pseudo: pseudo
		)
	}

}
