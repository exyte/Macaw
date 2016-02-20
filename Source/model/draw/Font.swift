import Foundation

public class Font {

	public let name: String
	public let size: Int
	public let bold: NSObject
	public let italic: NSObject
	public let underline: NSObject
	public let strike: NSObject

	public init(name: String = "Serif", size: Int = 12, bold: NSObject = false, italic: NSObject = false, underline: NSObject = false, strike: NSObject = false) {
		self.name = name	
		self.size = size	
		self.bold = bold	
		self.italic = italic	
		self.underline = underline	
		self.strike = strike	
	}

}
