public enum AnimationState {
    case initial
    case running
    case paused
}

public class Animation {

    internal init() {
    }

    public func play() {
    }

    public func stop() {
    }

    public func pause() {

    }

    public func state() -> AnimationState {
        return .initial
    }

    public func easing(_ easing: Easing) -> Animation {
        return self
    }

    public func delay(_ delay: Double) -> Animation {
        return self
    }

    public func cycle(_ count: Double) -> Animation {
        return self
    }

    public func cycle() -> Animation {
        return self
    }

    public func reverse() -> Animation {
        return self
    }

    public func autoreversed() -> Animation {
        return self
    }

    @discardableResult public func onComplete(_: @escaping (() -> Void)) -> Animation {
        return self
    }
}
