import Foundation

open class LinearGradient: Gradient {

	open let x1: Double
	open let y1: Double
	open let x2: Double
	open let y2: Double

	public init(x1: Double = 0, y1: Double = 0, x2: Double = 0, y2: Double = 0, userSpace: Bool = false, stops: [Stop] = []) {
		self.x1 = x1
		self.y1 = y1
		self.x2 = x2
		self.y2 = y2
		super.init(
			userSpace: userSpace,
			stops: stops
		)
	}

    public init(degree: Double = 0, from: Color, to: Color) {
        self.x1 = degree >= 135 && degree < 270 ? 1 : 0
        self.y1 = degree < 225 ? 0 : 1
        self.x2 = degree < 90 || degree >= 315 ? 1 : 0
        self.y2 = degree >= 45 && degree < 180 ? 1 : 0
        super.init(
            userSpace: false,
            stops: [Stop(offset: 0, color: from), Stop(offset: 1, color: to)]
        )
    }

}
