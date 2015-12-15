import Foundation

class RadioButton: Widget  {

	var on: Bool = false
	var text: String = ""
	var image: NSObject


	init(on: Bool = false, text: String = "", image: NSObject) {
		self.on = on	
		self.text = text	
		self.image = image	
	}

}
