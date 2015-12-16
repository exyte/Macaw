import Foundation

class Textual: Style  {

	var font_family: String
	var font_size: NSNumber
	var font_style: FontStyle
	var font_weight: FontWeight

	init(font_family: String, font_size: NSNumber, font_style: FontStyle, font_weight: FontWeight) {
		self.font_family = font_family	
		self.font_size = font_size	
		self.font_style = font_style	
		self.font_weight = font_weight	
	}

}
