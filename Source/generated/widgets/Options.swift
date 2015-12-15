import Foundation

class Options: Widget  {

	var items: [String]
	var selection: [Int]


	init(items: [String], selection: [Int]) {
		self.items = items	
		self.selection = selection	
	}

}
