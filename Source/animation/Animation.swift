public class Animation {

	internal init() {
	}

	public func cycle(count count: Double) -> Animation {
		return self
	}

	public func autoreversed() -> Animation {
		return self
	}

	public func easing(easing: Easing) -> Animation {
		return self
	}

	public func onComplete(_: (() -> ())) -> Animation {
		return self
	}

	public func play() {
	}

	public func stop() {
	}

	public func reverse() -> Animation {
		return self
	}

}
