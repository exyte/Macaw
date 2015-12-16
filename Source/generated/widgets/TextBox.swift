import Foundation

class TextBox: Widget  {

	var text: String = ""

	init(text: String = "", enable: Bool, tooltip: String, bounds: Rect, id: String, style: [String: NSObject], pseudo: [String: [String: NSObject]]) {
		self.text = text	
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
