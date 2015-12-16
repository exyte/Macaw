import Foundation

class Tabs: Widget  {

	var contents: [Tab]
	var selection: Int

	init(contents: [Tab], selection: Int, enable: Bool, tooltip: String, bounds: Rect, id: String, style: [String: NSObject], pseudo: [String: [String: NSObject]]) {
		self.contents = contents	
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
