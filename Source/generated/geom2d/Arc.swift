import Foundation

public class Arc: Locus  {

	var ellipse: Ellipse
	var shift: Double = 0
	var extent: Double = 0

	public init(ellipse: Ellipse, shift: Double = 0, extent: Double = 0) {
		self.ellipse = ellipse	
		self.shift = shift	
		self.extent = extent	
	}

}
