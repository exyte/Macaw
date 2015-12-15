import Foundation

class Panel: Widget  {

	var contents: [Widget]


	init(contents: [Widget]) {
		self.contents = contents	
	}

}
