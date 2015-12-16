import Foundation

class WidgetNode: Node  {

	var widget: Widget
	var rect: Rect

	init(widget: Widget, rect: Rect, pos: Transform, opaque: Bool, visible: Bool, clip: Locus, tag: [String]) {
		self.widget = widget	
		self.rect = rect	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
