import Foundation

class Tab {

	var name: String = ""
	var image: NSObject
	var content: Widget


	init(name: String = "", image: NSObject, content: Widget) {
		self.name = name	
		self.image = image	
		self.content = content	
	}

}
