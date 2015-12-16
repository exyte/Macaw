import Foundation

class Section: Panel  {

	var text: String = ""

	init(text: String = "", contents: [Widget], enable: Bool, tooltip: String, bounds: Rect, id: String, style: [String: NSObject], pseudo: [String: [String: NSObject]]) {
		self.text = text	
		super.init(
			contents: contents,
			enable: enable,
			tooltip: tooltip,
			bounds: bounds,
			id: id,
			style: style,
			pseudo: pseudo
		)
	}

}
