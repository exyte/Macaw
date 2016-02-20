import Foundation

public class Circle: Locus  {

	public let cx: Double
	public let cy: Double
	public let r: Double

	public init(cx: Double = 0, cy: Double = 0, r: Double = 0) {
		self.cx = cx	
		self.cy = cy	
		self.r = r	
	}

}
