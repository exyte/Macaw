import Foundation

class WidgetNode: Node  {

	var widget: Widget
	var rect: Rect


	init(widget: Widget, rect: Rect) {
		self.widget = widget	
		self.rect = rect	
	}

}
