import Foundation

public class Node: Drawable  {

	var pos: Transform? = nil
	var opaque: NSObject? = true
	var visible: NSObject? = true
	var clip: Locus? = nil

	public init(pos: Transform? = nil, opaque: NSObject? = true, visible: NSObject? = true, clip: Locus? = nil, tag: [String] = []) {
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
		return Mouse()
	}
	// GENERATED NOT
	public func bounds() -> Rect {
		return Rect()
	}

}
