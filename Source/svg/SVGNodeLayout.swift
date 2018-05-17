public enum SVGLength {
    case percent(Double)
    case pixels(Double)

    init(percent: Double) {
        self = .percent(percent)
    }

    init(pixels: Double) {
        self = .pixels(pixels)
    }
}

public class SVGSize {
    public let width: SVGLength
    public let height: SVGLength

    public init(width: SVGLength, height: SVGLength) {
        self.width = width
        self.height = height
    }
}

public protocol NodeLayout {

    func layout(node: Node, in rect: Rect)
}

public class SVGNodeLayout: NodeLayout {

    public let svgSize: SVGSize?
    public let viewBox: Rect?
    public let scalingMode: AspectRatio
    public let xAligningMode: Align
    public let yAligningMode: Align

    init(svgSize: SVGSize? = .none, viewBox: Rect? = .none, scalingMode: AspectRatio? = .meet, xAligningMode: Align? = .mid, yAligningMode: Align? = .mid) {
        self.svgSize = svgSize
        self.viewBox = viewBox
        self.scalingMode = scalingMode ?? .meet
        self.xAligningMode = xAligningMode ?? .mid
        self.yAligningMode = yAligningMode ?? .mid
    }

    public func layout(node: Node, in rect: Rect) {
        guard let size = svgSize else {
            return
        }
        let width = svgLengthToPixels(size.width, framePixels: rect.w)
        let height = svgLengthToPixels(size.height, framePixels: rect.h)
        let svgSizeInPixels = Size(w: width, h: height)

        if let viewBox = self.viewBox {
            node.clip = viewBox
        }
        let viewBox = self.viewBox ?? Rect(x: 0, y: 0, w: svgSizeInPixels.w, h: svgSizeInPixels.h)

        if scalingMode === AspectRatio.slice {
            // setup new clipping to slice extra bits
            let newSize = AspectRatio.meet.fit(size: svgSizeInPixels, into: viewBox)
            let newX = viewBox.x + xAligningMode.align(outer: viewBox.w, inner: newSize.w)
            let newY = viewBox.y + yAligningMode.align(outer: viewBox.h, inner: newSize.h)
            node.clip = Rect(x: newX, y: newY, w: newSize.w, h: newSize.h)
        }

        let contentLayout = SVGContentLayout(scalingMode: scalingMode, xAligningMode: xAligningMode, yAligningMode: yAligningMode)
        node.place = contentLayout.layout(rect: viewBox, into: Rect(x: 0, y: 0, w: svgSizeInPixels.w, h: svgSizeInPixels.h))

        // move to (0, 0)
        node.place = node.place.move(dx: -viewBox.x, dy: -viewBox.y)
    }
}

fileprivate func svgLengthToPixels(_ svgLength: SVGLength, framePixels: Double) -> Double {
    switch svgLength {
    case let .percent(percent):
        return framePixels * percent / 100.0
    case let .pixels(pixels):
        return pixels
    }
}
