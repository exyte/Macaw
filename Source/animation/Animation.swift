open class Animation {

	internal init() {
	}

    open func play() {
    }

    open func stop() {
    }

    open func easing(_ easing: Easing) -> Animation {
        return self
    }

    open func delay(_ delay: Double) -> Animation {
        return self
    }

	open func cycle(_ count: Double) -> Animation {
		return self
	}

    open func reverse() -> Animation {
        return self
    }

	open func autoreversed() -> Animation {
		return self
	}

	@discardableResult open func onComplete(_: @escaping (() -> ())) -> Animation {
		return self
	}
}
