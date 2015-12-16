import Foundation

class Option: Widget  {

	var items: [String]
	var selection: Int = 0

	init(items: [String], selection: Int = 0, enable: Bool, tooltip: String, bounds: Rect, id: String, style: [String: NSObject], pseudo: [String: [String: NSObject]]) {
		self.items = items	
		self.selection = selection	
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
