import Foundation
import RxSwift

public class Font {

	public let name: String
	public let size: Int
	public let bold: Bool
	public let italic: Bool
	public let underline: Bool
	public let strike: Bool

	public init(name: String = "Serif", size: Int = 12, bold: Bool = false, italic: Bool = false, underline: Bool = false, strike: Bool = false) {
		self.name = name
		self.size = size
		self.bold = bold
		self.italic = italic
		self.underline = underline
		self.strike = strike
	}

}
