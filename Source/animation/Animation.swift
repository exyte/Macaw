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
        .initial
    }

    public func easing(_ easing: Easing) -> Animation {
        self
    }

    public func delay(_ delay: Double) -> Animation {
        self
    }

    public func cycle(_ count: Double) -> Animation {
        self
    }

    public func cycle() -> Animation {
        self
    }

    public func reverse() -> Animation {
        self
    }

    public func autoreversed() -> Animation {
        self
    }

    @discardableResult public func onComplete(_: @escaping (() -> Void)) -> Animation {
        self
    }
}
