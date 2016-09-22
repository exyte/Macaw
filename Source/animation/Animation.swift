public class Animation {

	internal init() {
	}

    public func play() {
    }

    public func stop() {
    }

    public func easing(easing: Easing) -> Animation {
        return self
    }

    public func delay(delay: Double) -> Animation {
        return self
    }

	public func cycle(count: Double) -> Animation {
		return self
	}

    public func reverse() -> Animation {
        return self
    }

	public func autoreversed() -> Animation {
		return self
	}

	public func onComplete(_: (() -> ())) -> Animation {
		return self
	}
}
