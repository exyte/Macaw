import Foundation

public class RoundRect: Locus  {

	let rect: Rect?
	let rx: Double
	let ry: Double

	public init(rect: Rect? = nil, rx: Double = 0, ry: Double = 0) {
		self.rect = rect	
		self.rx = rx	
		self.ry = ry	
	}

}
