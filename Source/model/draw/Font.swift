import Foundation

open class Font {

	open let name: String
	open let size: Int

	public init(name: String = "Serif", size: Int = 12) {
		self.name = name
		self.size = size
	}

}
