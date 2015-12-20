import Foundation

public class Node: Drawable  {

	var pos: Transform
	var opaque: NSNumber = true
	var visible: NSNumber = true
	var clip: Locus

	public init(pos: Transform, opaque: NSNumber = true, visible: NSNumber = true, clip: Locus, tag: [String] = []) {
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
        // TODO initial implementation
        return Mouse(
            hover: false,
            pos: Point(),
            onEnter: Signal(),
            onExit: Signal(),
            onWheel: Signal()
        )
    }
	// GENERATED NOT
	public func bounds() -> Rect {
        // TODO initial implementation
        return Rect()
    }

}
