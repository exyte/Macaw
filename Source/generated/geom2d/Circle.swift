import Foundation

public class Circle: Locus  {

	let cx: Double
	let cy: Double
	let r: Double

	public init(cx: Double = 0, cy: Double = 0, r: Double = 0) {
		self.cx = cx	
		self.cy = cy	
		self.r = r	
	}

}
