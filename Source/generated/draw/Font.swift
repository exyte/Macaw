import Foundation

public class Font {

	var name: String = "Serif"
	var size: Int = 12
	var bold: NSNumber = false
	var italic: NSNumber = false
	var underline: NSNumber = false
	var strike_through: NSNumber = false

	init(name: String = "Serif", size: Int = 12, bold: NSNumber = false, italic: NSNumber = false, underline: NSNumber = false, strike_through: NSNumber = false) {
		self.name = name	
		self.size = size	
		self.bold = bold	
		self.italic = italic	
		self.underline = underline	
		self.strike_through = strike_through	
	}

}
