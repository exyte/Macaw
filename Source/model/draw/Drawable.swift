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

	// GENERATED NOT
	public func mouse() -> Mouse {
		return Mouse(pos: Point(), onEnter: Signal(), onExit: Signal(), onWheel: Signal())
	}

}
