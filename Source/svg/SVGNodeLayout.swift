enum SVGLength {
    case percent(Double)
    case pixels(Double)

    init(percent: Double) {
        self = .percent(percent)
    }

    init(pixels: Double) {
        self = .pixels(pixels)
    }

    func toPixels(total: Double) -> Double {
        switch self {
        case let .percent(percent):
            return total * percent / 100.0
        case let .pixels(pixels):
            return pixels
        }
    }

}

class SVGSize {

    let width: SVGLength
    let height: SVGLength

    public init(width: SVGLength, height: SVGLength) {
        self.width = width
        self.height = height
    }

    func toPixels(total: Size) -> Size {
        return Size(w: width.toPixels(total: total.w),
                    h: height.toPixels(total: total.h))
    }

}

protocol NodeLayout {

    func computeSize(parent: Size) -> Size

    func layout(node: Node, in size: Size)
}

class SVGNodeLayout: NodeLayout {

    let svgSize: SVGSize
    let viewBox: Rect?
    let scaling: AspectRatio
    let xAlign: Align
    let yAlign: Align

    init(svgSize: SVGSize, viewBox: Rect? = .none, scaling: AspectRatio? = nil, xAlign: Align? = nil, yAlign: Align? = nil) {
        self.svgSize = svgSize
        self.viewBox = viewBox
        self.scaling = scaling ?? .meet
        self.xAlign = xAlign ?? .mid
        self.yAlign = yAlign ?? .mid
    }

    func computeSize(parent: Size) -> Size {
        return svgSize.toPixels(total: parent)
    }

    func layout(node: Node, in size: Size) {
        let svgSizeInPixels = svgSize.toPixels(total: size)

        if let viewBox = self.viewBox {
            node.clip = viewBox
        }
        let viewBox = self.viewBox ?? Rect(x: 0, y: 0, w: svgSizeInPixels.w, h: svgSizeInPixels.h)

        if scaling === AspectRatio.slice {
            // setup new clipping to slice extra bits
            let newSize = AspectRatio.meet.fit(size: svgSizeInPixels, into: viewBox)
            let newX = viewBox.x + xAlign.align(outer: viewBox.w, inner: newSize.w)
            let newY = viewBox.y + yAlign.align(outer: viewBox.h, inner: newSize.h)
            node.clip = Rect(x: newX, y: newY, w: newSize.w, h: newSize.h)
        }

        let layout = ContentLayout.of(scaling: scaling, xAlign: xAlign, yAlign: yAlign)
        node.place = layout.layout(size: viewBox.size(), into: svgSizeInPixels)

        // move to (0, 0)
        node.place = node.place.move(dx: -viewBox.x, dy: -viewBox.y)
    }
}
