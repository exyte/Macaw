import Foundation

public class Arc: Locus  {

	var ellipse: Ellipse? = nil
	var shift: NSNumber = 0
	var extent: NSNumber = 0

	public init(ellipse: Ellipse? = nil, shift: NSNumber = 0, extent: NSNumber = 0) {
		self.ellipse = ellipse	
		self.shift = shift	
		self.extent = extent	
	}

}
