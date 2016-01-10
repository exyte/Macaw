import Foundation

public class Arc: Locus  {

	let ellipse: Ellipse
	let shift: Double
	let extent: Double

	public init(ellipse: Ellipse, shift: Double = 0, extent: Double = 0) {
		self.ellipse = ellipse	
		self.shift = shift	
		self.extent = extent	
	}

}
