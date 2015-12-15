import Foundation

class Option: Widget  {

	var items: [String]
	var selection: Int = 0


	init(items: [String], selection: Int = 0) {
		self.items = items	
		self.selection = selection	
	}

}
