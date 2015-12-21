import Foundation

public class Arc: Locus  {

	let ellipse: Ellipse?
	let shift: NSNumber
	let extent: NSNumber

	public init(ellipse: Ellipse? = nil, shift: NSNumber = 0, extent: NSNumber = 0) {
		self.ellipse = ellipse	
		self.shift = shift	
		self.extent = extent	
	}

}
