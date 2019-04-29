import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

class AnimationCache {

    class CachedLayer {
        let rootLayer: ShapeLayer
        let animationLayer: ShapeLayer

        required init(rootLayer: ShapeLayer, animationLayer: ShapeLayer) {
            self.rootLayer = rootLayer
            self.animationLayer = animationLayer
        }
    }

    weak var sceneLayer: CALayer?
    var cache = [NodeRenderer: CachedLayer]()

    required init(sceneLayer: CALayer) {
        self.sceneLayer = sceneLayer
    }

    func layerForNodeRenderer(_ renderer: NodeRenderer, _ context: AnimationContext, animation: Animation, customBounds: Rect? = .none, shouldRenderContent: Bool = true) -> ShapeLayer {

        let node = renderer.node
        if let cachedLayer = cache[renderer] {
            cachedLayer.rootLayer.transform = CATransform3DMakeAffineTransform(uncachedParentsPlace(renderer).toCG())
            cachedLayer.animationLayer.opacity = Float(node.opacity)
            return cachedLayer.animationLayer
        }

        // 'sublayer' is for actual CAAnimations, and 'layer' is for manual transforming and hierarchy changes
        let sublayer = ShapeLayer()
        sublayer.shouldRenderContent = shouldRenderContent
        sublayer.animationCache = self

        let layer = ShapeLayer()
        layer.addSublayer(sublayer)
        layer.masksToBounds = false

        // Use to debug animation layers
//        sublayer.backgroundColor = MColor.green.cgColor
//        sublayer.borderWidth = 2.0
//        sublayer.borderColor = MColor.red.cgColor
//        layer.backgroundColor = MColor.blue.cgColor
//        layer.borderWidth = 2.0
//        layer.borderColor = MColor.cyan.cgColor

        let calculatedBounds = customBounds ?? node.bounds
        if let shapeBounds = calculatedBounds {
            let cgRect = shapeBounds.toCG()

            let anchorPoint = CGPoint(
                x: -1.0 * cgRect.origin.x / cgRect.width,
                y: -1.0 * cgRect.origin.y / cgRect.height
            )

            layer.bounds = cgRect
            sublayer.bounds = cgRect
            layer.anchorPoint = anchorPoint
            sublayer.anchorPoint = anchorPoint
            layer.zPosition = CGFloat(renderer.zPosition)

            // Clip
            if let clip = AnimationUtils.absoluteClip(renderer) {
                let maskLayer = CAShapeLayer()
                let origPath = clip.toCGPath()
                var offsetTransform = CGAffineTransform(translationX: -1.0 * cgRect.origin.x, y: -1.0 * cgRect.origin.y)
                let clipPath = origPath.mutableCopy(using: &offsetTransform)
                maskLayer.path = clipPath
                layer.mask = maskLayer
            }
        }

        sublayer.opacity = Float(node.opacity)
        sublayer.renderer = renderer
        sublayer.contentsScale = calculateAnimationScale(animation: animation)
        sublayer.setNeedsDisplay()

        // find first parent with cached layer
        var parent: NodeRenderer? = renderer.parentRenderer
        var parentCachedLayer: CALayer? = sceneLayer
        while parent != nil {
            if let parent = parent {
                if let cached = cache[parent] {
                    parentCachedLayer = cached.animationLayer
                    break
                }
            }
            parent = parent?.parentRenderer
        }
        layer.transform = CATransform3DMakeAffineTransform(uncachedParentsPlace(renderer).toCG())
        sublayer.transform = CATransform3DMakeAffineTransform(node.place.toCG())
        parentCachedLayer?.addSublayer(layer)
        parentCachedLayer?.setNeedsDisplay()

        cache[renderer] = CachedLayer(rootLayer: layer, animationLayer: sublayer)
        
        // move children to new layer
        for child in renderer.getAllChildrenRecursive() {
            if let cachedChildLayer = cache[child], let parentCachedLayer = parentCachedLayer {
                parentCachedLayer.sublayers?.forEach { childLayer in
                    if childLayer === cachedChildLayer.rootLayer {

                        childLayer.removeFromSuperlayer()
                        childLayer.transform = CATransform3DMakeAffineTransform(uncachedParentsPlace(child).toCG())
                        sublayer.addSublayer(childLayer)
                        sublayer.setNeedsDisplay()
                    }
                }
            }
        }

        sceneLayer?.setNeedsDisplay()

        return sublayer
    }

    private func calculateAnimationScale(animation: Animation) -> CGFloat {
        guard let defaultScale = MMainScreen()?.mScale else {
            return 1.0
        }

        guard let transformAnimation = animation as? TransformAnimation else {
            return defaultScale
        }

        let animFunc = transformAnimation.getVFunc()
        let origBounds = Rect(x: 0.0, y: 0.0, w: 1.0, h: 1.0)

        let startTransform = animFunc(0.0)
        let startBounds = origBounds.applying(startTransform)
        var startArea = startBounds.w * startBounds.h

        // zero scale protection
        if startArea == 0.0 {
            startArea = 0.1
        }

        var maxArea = startArea
        var t = 0.0
        let step = 0.1
        while t <= 1.0 {
            let currentTransform = animFunc(t)
            let currentBounds = origBounds.applying(currentTransform)
            let currentArea = currentBounds.w * currentBounds.h
            if maxArea < currentArea {
                maxArea = currentArea
            }

            t += step
        }

        return defaultScale * CGFloat(sqrt(maxArea))
    }

    func freeLayerHard(_ renderer: NodeRenderer) {
        freeLayer(renderer)
    }

    func freeLayer(_ renderer: NodeRenderer?) {
        guard let nodeRenderer = renderer, let layer = cache[nodeRenderer] else {
            return
        }

        cache.removeValue(forKey: nodeRenderer)

        // find first parent with cached layer
        var parent: NodeRenderer? = nodeRenderer.parentRenderer
        var parentCachedLayer: CALayer? = sceneLayer
        while parent != nil {
            if let parent = parent, let cached = cache[parent] {
                parentCachedLayer = cached.animationLayer
                break
            }
            parent = parent?.parentRenderer
        }

        // move children to closest parent layer
        for child in nodeRenderer.getAllChildrenRecursive() {
            if let cachedChildLayer = cache[child], let parentCachedLayer = parentCachedLayer {
                layer.animationLayer.sublayers?.forEach { childLayer in
                    if childLayer === cachedChildLayer.rootLayer {
                        CATransaction.setValue(kCFBooleanTrue, forKey:kCATransactionDisableActions)
                        childLayer.removeFromSuperlayer()
                        childLayer.transform = CATransform3DMakeAffineTransform(uncachedParentsPlace(child).toCG())
                        parentCachedLayer.addSublayer(childLayer)
                        childLayer.setNeedsDisplay()
                        CATransaction.commit()
                    }
                }
            }
        }

        layer.animationLayer.removeFromSuperlayer()
        layer.rootLayer.removeFromSuperlayer()
        parentCachedLayer?.setNeedsDisplay()
        sceneLayer?.setNeedsDisplay()
    }

    func isAnimating(_ nodeRenderer: NodeRenderer) -> Bool {
        return cache[nodeRenderer] != nil
    }

    func isAnimating(_ node: Node) -> Bool {
        if let renderer = cache.keys.first(where: { $0.node === node }) {
            return isAnimating(renderer)
        }
        return false
    }

    func uncachedParentsPlace(_ renderer: NodeRenderer) -> Transform {
        var parent: NodeRenderer? = renderer.parentRenderer
        var uncachedParentsPlace = Transform.identity
        while parent != nil {
            if let parent = parent {
                if cache[parent] != nil {
                    break
                }
                uncachedParentsPlace = uncachedParentsPlace.concat(with: parent.node.place)
            }
            parent = parent?.parentRenderer
        }
        return uncachedParentsPlace
    }

}
