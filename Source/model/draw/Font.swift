import Foundation
import RxSwift

public class Font {

	public let name: String
	public let size: Int

	public init(name: String = "Serif", size: Int = 12) {
		self.name = name
		self.size = size
	}

}
