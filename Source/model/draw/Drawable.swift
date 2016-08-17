import Foundation
import RxSwift

public class Drawable {

	public let visible: Bool
	public let tag: [String]
	public let bounds: Rect?

	public init(visible: Bool = true, tag: [String] = [], bounds: Rect? = nil) {
		self.visible = visible
		self.tag = tag
		self.bounds = bounds
	}

}
