import Foundation
import RxSwift

public class Arc: Locus  {

	public let ellipse: Ellipse
	public let shift: Double
	public let extent: Double

	public init(ellipse: Ellipse, shift: Double = 0, extent: Double = 0) {
		self.ellipse = ellipse	
		self.shift = shift	
		self.extent = extent	
	}

}
