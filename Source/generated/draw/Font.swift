import Foundation

class Font {

	var name: String = "Serif"
	var size: Int = 12
	var bold: Bool = false
	var italic: Bool = false
	var underline: Bool = false
	var strike_through: Bool = false


	init(name: String = "Serif", size: Int = 12, bold: Bool = false, italic: Bool = false, underline: Bool = false, strike_through: Bool = false) {
		self.name = name	
		self.size = size	
		self.bold = bold	
		self.italic = italic	
		self.underline = underline	
		self.strike_through = strike_through	
	}

}
