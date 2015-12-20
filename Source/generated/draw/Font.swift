import Foundation

public class Font {

	var name: String = "Serif"
	var size: Int = 12
	var bold: NSObject? = false
	var italic: NSObject? = false
	var underline: NSObject? = false
	var strike_through: NSObject? = false

	public init(name: String = "Serif", size: Int = 12, bold: NSObject? = false, italic: NSObject? = false, underline: NSObject? = false, strike_through: NSObject? = false) {
		self.name = name	
		self.size = size	
		self.bold = bold	
		self.italic = italic	
		self.underline = underline	
		self.strike_through = strike_through	
	}

}
