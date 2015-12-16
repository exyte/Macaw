import Foundation

class Styleable {

	var id: String
	var style: [String: NSObject]
	var pseudo: [String: [String: NSObject]]

	init(id: String, style: [String: NSObject], pseudo: [String: [String: NSObject]]) {
		self.id = id	
		self.style = style	
		self.pseudo = pseudo	
	}

}
