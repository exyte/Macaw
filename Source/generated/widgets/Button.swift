import Foundation

class Button: Widget  {

	var text: String = ""
	var image: NSObject
	var onClick: Signal

	init(text: String = "", image: NSObject, onClick: Signal, enable: Bool, tooltip: String, bounds: Rect, id: String, style: [String: NSObject], pseudo: [String: [String: NSObject]]) {
		self.text = text	
		self.image = image	
		self.onClick = onClick	
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
