import Foundation

public class Circle: Locus  {

	var cx: Double = 0
	var cy: Double = 0
	var r: Double = 0

	public init(cx: Double = 0, cy: Double = 0, r: Double = 0) {
		self.cx = cx	
		self.cy = cy	
		self.r = r	
	}

}
