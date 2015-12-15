import Foundation

class Button: Widget  {

	var text: String = ""
	var image: NSObject
	var onClick: Signal


	init(text: String = "", image: NSObject, onClick: Signal) {
		self.text = text	
		self.image = image	
		self.onClick = onClick	
	}

}
