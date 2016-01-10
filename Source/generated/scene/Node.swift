import Foundation

public class Node: Drawable  {

	var pos: Transform
	var opaque: NSObject? = true
	var visible: NSObject? = true
	var clip: Locus? = nil

	public init(pos: Transform, opaque: NSObject? = true, visible: NSObject? = true, clip: Locus? = nil, tag: [String] = []) {
		self.pos = pos	
		self.opaque = opaque	
		self.visible = visible	
		self.clip = clip	
		super.init(
			tag: tag
		)
	}

	// GENERATED NOT
	public func mouse() -> Mouse {
		return Mouse(pos: Point(), onEnter: Signal(), onExit: Signal(), onWheel: Signal())
	}
	// GENERATED NOT
	public func bounds() -> Rect {
		return Rect()
	}

}
