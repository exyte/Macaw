import Foundation

public class RoundRect: Locus  {

	let rect: Rect?
	let rx: NSNumber
	let ry: NSNumber

	public init(rect: Rect? = nil, rx: NSNumber = 0, ry: NSNumber = 0) {
		self.rect = rect	
		self.rx = rx	
		self.ry = ry	
	}

}
