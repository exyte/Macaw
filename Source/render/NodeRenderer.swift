import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

enum ColoringMode {
    case rgb, greyscale, alphaOnly
}

class CachedLayer {
    let rootLayer: ShapeLayer
    let animationLayer: ShapeLayer

    required init(rootLayer: ShapeLayer, animationLayer: ShapeLayer) {
        self.rootLayer = rootLayer
        self.animationLayer = animationLayer
    }
}

class NodeRenderer {

    weak var view: DrawingView?
    var sceneLayer: CALayer? {
        return view?.mLayer
    }
    var layer: CachedLayer?
    var zPosition: Int = 0

    private(set) weak var parentRenderer: GroupRenderer?

    fileprivate let onNodeChange: () -> Void
    fileprivate let disposables = GroupDisposable()
    fileprivate var active = false

    fileprivate var cachedAbsPlace: Transform?
    fileprivate var absPlace: Transform {
        if let place = cachedAbsPlace {
            return place
        }

        if let place = parentRenderer?.absPlace.concat(with: node.place) {
            cachedAbsPlace = place
            return place
        }

        return node.place
    }

    func freeCachedAbsPlace() {
        cachedAbsPlace = nil
    }

    public func place(in relativity: Relativity = .parent) -> Transform {
        switch relativity {
        case .parent:
            return node.place
        case .scene:
            return absPlace
        case .view:
            if let viewPlace = view?.place {
                return viewPlace.concat(with: absPlace)
            }
            return absPlace
        }
    }

    open var node: Node {
        fatalError("Unsupported")
    }

    init(node: Node, view: DrawingView?, parentRenderer: GroupRenderer? = nil) {
        self.view = view
        self.parentRenderer = parentRenderer

        onNodeChange = { [weak view] in
            if node.isAnimating() {
                return
            }

            view?.setNeedsDisplay()
        }

        addObservers()
    }

    deinit {
        disposables.dispose()
    }

    func doAddObservers() {
        observe(node.placeVar)
        observe(node.opaqueVar)
        observe(node.opacityVar)
        observe(node.clipVar)
        observe(node.effectVar)

        node.animationObservers.append(self)

        node.placeVar.onChange { [weak self] _ in
            self?.freeCachedAbsPlace()
        }
    }

    func observe<E>(_ v: Variable<E>) {
        let disposable = v.onChange { [weak self] _ in
            self?.onNodeChange()
        }

        addDisposable(disposable)
    }

    func addDisposable(_ disposable: Disposable) {
        disposable.addTo(disposables)
    }

    open func dispose() {
        removeObservers()
        node.animationObservers = node.animationObservers.filter { !($0 as? NodeRenderer === self) }
        freeLayer()
    }

    final public func render(in context: CGContext, force: Bool, opacity: Double, coloringMode: ColoringMode = .rgb) {
        context.saveGState()
        defer {
            context.restoreGState()
        }
        let newOpacity = node.opacity * opacity

        context.concatenate(node.place.toCG())
        applyClip(in: context)

        // draw masked image
        if let mask = node.mask, let bounds = mask.bounds, let maskedImage = getMaskedImage(bounds: bounds) {
            context.draw(maskedImage, in: bounds.toCG())
            return
        }

        // no effects, just draw as usual
        guard let effect = node.effect else {
            directRender(in: context, force: force, opacity: newOpacity, coloringMode: coloringMode)
            return
        }

        let (offset, otherEffects) = separateEffects(effect)
        let hasAlpha = otherEffects.contains { $0 is AlphaEffect }
        let effectColoringMode = hasAlpha ? ColoringMode.alphaOnly : coloringMode

        // move to offset
        if let offset = offset {
            context.concatenate(CGAffineTransform(translationX: CGFloat(offset.dx), y: CGFloat(offset.dy)))
        }

        if otherEffects.isEmpty {
            // just draw offset shape
            directRender(in: context, force: force, opacity: newOpacity, coloringMode: effectColoringMode)
        } else {
            // apply other effects to offset shape and draw it
            applyEffects(otherEffects, context: context, opacity: opacity, coloringMode: effectColoringMode)
        }

        if otherEffects.contains(where: { effect -> Bool in
            effect is BlendEffect
        }) {
            // move back and draw the shape itself
            if let offset = offset {
                context.concatenate(CGAffineTransform(translationX: CGFloat(-offset.dx), y: CGFloat(-offset.dy)))
            }
            directRender(in: context, force: force, opacity: newOpacity)
        }
    }

    final func directRender(in context: CGContext,
                            force: Bool = true,
                            opacity: Double = 1.0,
                            coloringMode: ColoringMode = .rgb) {
        if isAnimating() {
            self.removeObservers()
            if !force {
                return
            }
        } else {
            self.addObservers()
        }
        doRender(in: context, force: force, opacity: opacity, coloringMode: coloringMode)
    }

    fileprivate func separateEffects(_ effect: Effect) -> (OffsetEffect?, [Effect]) {
        var next: Effect? = effect
        var otherEffects = [Effect]()
        var dx: Double = 0, dy: Double = 0
        while next != nil {
            if let offset = next as? OffsetEffect {
                dx += offset.dx
                dy += offset.dy
            } else {
                otherEffects.append(next!)
            }
            next = next?.input
        }
        let offset = dx != 0 || dy != 0 ? OffsetEffect(dx: dx, dy: dy, input: nil) : nil
        return (offset, otherEffects.reversed())
    }

    fileprivate func applyEffects(_ effects: [Effect], context: CGContext, opacity: Double, coloringMode: ColoringMode = .rgb) {
        guard let bounds = node.bounds else {
            return
        }
        var inset: Double = 0
        for effect in effects {
            if let blur = effect as? GaussianBlur {
                inset = min(blur.r * 6 + 1, 150)
            }
        }

        guard let shapeCGImage = renderToImage(bounds: bounds, inset: inset, coloringMode: coloringMode)?.cgImage else {
            return
        }
        
        let shapeImage = CIImage(cgImage: shapeCGImage)
        var filteredImage = shapeImage
        for effect in effects {
            if let blur = effect as? GaussianBlur {
                filteredImage = applyBlur(filteredImage, blur: blur)
            }
            if let matrix = effect as? ColorMatrixEffect {
                filteredImage = applyColorMatrix(filteredImage, colorMatrixEffect: matrix)
            }
        }

        let ciContext = CIContext(options: nil)
        let finalImage = ciContext.createCGImage(filteredImage, from: shapeImage.extent)!
        context.draw(finalImage, in: CGRect(x: bounds.x - inset / 2, y: bounds.y - inset / 2, width: bounds.w + inset, height: bounds.h + inset))
    }

    fileprivate func applyBlur(_ image: CIImage, blur: GaussianBlur) -> CIImage {
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setDefaults()
        filter.setValue(Int(blur.r), forKey: kCIInputRadiusKey)
        filter.setValue(image, forKey: kCIInputImageKey)
        return filter.outputImage!
    }

    fileprivate func applyColorMatrix(_ image: CIImage, colorMatrixEffect: ColorMatrixEffect) -> CIImage {
        let matrix = colorMatrixEffect.matrix.values.map { CGFloat($0) }
        let filter = CIFilter(name: "CIColorMatrix")!
        filter.setDefaults()
        filter.setValue(CIVector(x: matrix[0], y: matrix[1], z: matrix[2], w: matrix[3]), forKey: "inputRVector")
        filter.setValue(CIVector(x: matrix[5], y: matrix[6], z: matrix[7], w: matrix[8]), forKey: "inputGVector")
        filter.setValue(CIVector(x: matrix[10], y: matrix[11], z: matrix[12], w: matrix[13]), forKey: "inputBVector")
        filter.setValue(CIVector(x: matrix[15], y: matrix[16], z: matrix[17], w: matrix[18]), forKey: "inputAVector")
        filter.setValue(CIVector(x: matrix[4], y: matrix[9], z: matrix[14], w: matrix[19]), forKey: "inputBiasVector")
        filter.setValue(image, forKey: kCIInputImageKey)
        return filter.outputImage!
    }

    func renderToImage(bounds: Rect, inset: Double = 0, coloringMode: ColoringMode = .rgb) -> MImage? {
        let screenScale: CGFloat = MMainScreen()?.mScale ?? 1.0
        MGraphicsBeginImageContextWithOptions(CGSize(width: bounds.w + inset, height: bounds.h + inset), false, screenScale)
        let tempContext = MGraphicsGetCurrentContext()!

        // flip y-axis and leave space for the blur
        tempContext.translateBy(x: CGFloat(inset / 2 - bounds.x), y: CGFloat(bounds.h + inset / 2 + bounds.y))
        tempContext.scaleBy(x: 1, y: -1)
        directRender(in: tempContext, force: false, opacity: 1.0, coloringMode: coloringMode)

        let img = MGraphicsGetImageFromCurrentImageContext()
        MGraphicsEndImageContext()
        return img
    }

    func doRender(in context: CGContext, force: Bool, opacity: Double, coloringMode: ColoringMode = .rgb) {
        fatalError("Unsupported")
    }

    final func findNodeAt(location: CGPoint, ctx: CGContext) -> NodePath? {
        guard node.opaque, let inverted = node.place.invert() else {
            return .none
        }

        ctx.saveGState()
        defer {
            ctx.restoreGState()
        }

        ctx.concatenate(node.place.toCG())
        applyClip(in: ctx)
        let loc = location.applying(inverted.toCG())
        let path = NodePath(node: node, location: loc)
        let result = doFindNodeAt(path: path, ctx: ctx)
        return result
    }

    final func findNodeAt(parentNodePath: NodePath, ctx: CGContext) -> NodePath? {
        guard node.opaque, let inverted = node.place.invert() else {
            return .none
        }

        ctx.saveGState()
        defer {
            ctx.restoreGState()
        }

        ctx.concatenate(node.place.toCG())
        applyClip(in: ctx)
        let loc = parentNodePath.location.applying(inverted.toCG())
        let path = NodePath(node: node, location: loc, parent: parentNodePath)
        let result = doFindNodeAt(path: path, ctx: ctx)
        return result
    }

    public func doFindNodeAt(path: NodePath, ctx: CGContext) -> NodePath? {
        return nil
    }

    func calculateZPositionRecursively() {
        calculateZPosition(self)
    }

    private func applyClip(in context: CGContext) {
        guard let clip = node.clip else {
            return
        }

        MGraphicsPushContext(context)
        defer {
            MGraphicsPopContext()
        }

        if let rect = clip as? Rect {
            context.clip(to: CGRect(x: rect.x, y: rect.y, width: rect.w, height: rect.h))
            return
        }

        RenderUtils.toBezierPath(clip).addClip()
    }

    private func getMaskedImage(bounds: Rect) -> CGImage? {
        guard let mask = node.mask, let image = renderToImage(bounds: bounds) else {
            return .none
        }
        let nodeRenderer = RenderUtils.createNodeRenderer(mask, view: .none)
        guard let maskImage = nodeRenderer.renderToImage(bounds: bounds, coloringMode: .greyscale) else {
            return .none
        }
        return apply(maskImage: maskImage, to: image)
    }

    func apply(maskImage: MImage, to image: MImage) -> CGImage {
        let imageReference = image.cgImage!
        let maskReference = maskImage.cgImage!

        let decode = [CGFloat(1), CGFloat(0),
                      CGFloat(0), CGFloat(1),
                      CGFloat(0), CGFloat(1),
                      CGFloat(0), CGFloat(1)]

        let invertedMask = CGImage(maskWidth: maskReference.width,
                                   height: maskReference.height,
                                   bitsPerComponent: maskReference.bitsPerComponent,
                                   bitsPerPixel: maskReference.bitsPerPixel,
                                   bytesPerRow: maskReference.bytesPerRow,
                                   provider: maskReference.dataProvider!,
                                   decode: decode,
                                   shouldInterpolate: maskReference.shouldInterpolate)!

        return imageReference.masking(invertedMask)!
    }

    private func addObservers() {
        if !active {
            active = true
            doAddObservers()
        }
    }

    fileprivate func removeObservers() {
        if active {
            active = false
            disposables.dispose()
        }
    }

    func getAllChildrenRecursive() -> [NodeRenderer] {
        var children = getAllChildren(self)
        children.removeAll { r -> Bool in
            r === self
        }
        return children
    }

    private func getAllChildren(_ nodeRenderer: NodeRenderer) -> [NodeRenderer] {
        var result = [nodeRenderer]
        if let groupRenderer = nodeRenderer as? GroupRenderer {
            for child in groupRenderer.renderers {
                result.append(contentsOf: getAllChildren(child))
            }
        }
        return result
    }
}

protocol AnimationObserver {
    func processAnimation(_ animation: BasicAnimation)
}

extension NodeRenderer: AnimationObserver {
    func processAnimation(_ animation: BasicAnimation) {
        animation.nodeRenderer = self
    }

}

@discardableResult fileprivate func calculateZPosition(_ nodeRenderer: NodeRenderer, currentIndex: Int = 0) -> Int {
    nodeRenderer.zPosition = currentIndex
    if let groupRenderer = nodeRenderer as? GroupRenderer {
        var i = currentIndex + 1
        for child in groupRenderer.renderers {
            i = calculateZPosition(child, currentIndex: i)
        }
        return i
    }
    return currentIndex + 1
}
