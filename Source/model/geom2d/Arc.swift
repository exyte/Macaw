import Foundation

open class Arc: Locus {

	open let ellipse: Ellipse
	open let shift: Double
	open let extent: Double

	public init(ellipse: Ellipse, shift: Double = 0, extent: Double = 0) {
		self.ellipse = ellipse
		self.shift = shift
		self.extent = extent
	}

}
