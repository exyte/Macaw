import Foundation

public class Circle: Locus  {

	let cx: NSNumber
	let cy: NSNumber
	let r: NSNumber

	public init(cx: NSNumber = 0, cy: NSNumber = 0, r: NSNumber = 0) {
		self.cx = cx	
		self.cy = cy	
		self.r = r	
	}

}
