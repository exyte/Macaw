import Foundation

class Tabs: Widget  {

	var contents: [Tab]
	var selection: Int


	init(contents: [Tab], selection: Int) {
		self.contents = contents	
		self.selection = selection	
	}

}
