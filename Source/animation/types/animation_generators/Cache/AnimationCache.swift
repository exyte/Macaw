import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

class AnimationUtils {

    class func layerForNodeRenderer(_ renderer: NodeRenderer, animation: Animation, customBounds: Rect? = .none, shouldRenderContent: Bool = true) -> ShapeLayer {

        let node = renderer.node
        if let cachedLayer = renderer.layer {
            cachedLayer.rootLayer.transform = CATransform3DMakeAffineTransform(uncachedParentsPlace(renderer).toCG())
            cachedLayer.animationLayer.opacity = Float(node.opacity)
            return cachedLayer.animationLayer
        }

        // 'sublayer' is for actual CAAnimations, and 'layer' is for manual transforming and hierarchy changes
        let sublayer = ShapeLayer()
        sublayer.shouldRenderContent = shouldRenderContent

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
            if let clip = AbsoluteUtils.absoluteClip(renderer) {
                let maskLayer = CAShapeLayer()
                maskLayer.path = clip.toCGPath()
                layer.mask = maskLayer
            }
        }

        sublayer.opacity = Float(node.opacity)
        sublayer.renderer = renderer
        sublayer.contentsScale = calculateAnimationScale(animation: animation)
        sublayer.setNeedsDisplay()

        // find first parent with cached layer
        var parent: NodeRenderer? = renderer.parentRenderer
        var parentCachedLayer: CALayer? = renderer.sceneLayer
        while parent != nil {
            if let parent = parent {
                if let cached = parent.layer {
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

        renderer.layer = CachedLayer(rootLayer: layer, animationLayer: sublayer)

        // move children to new layer
        for child in renderer.getAllChildrenRecursive() {
            if let cachedChildLayer = child.layer, let parentCachedLayer = parentCachedLayer {
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

        renderer.sceneLayer?.setNeedsDisplay()

        return sublayer
    }

    class private func calculateAnimationScale(animation: Animation) -> CGFloat {
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

    class func uncachedParentsPlace(_ renderer: NodeRenderer) -> Transform {
        var parent: NodeRenderer? = renderer.parentRenderer
        var uncachedParentsPlace = Transform.identity
        while parent != nil {
            if let parent = parent {
                if parent.layer != nil {
                    break
                }
                uncachedParentsPlace = uncachedParentsPlace.concat(with: parent.node.place)
            }
            parent = parent?.parentRenderer
        }
        if let viewPlace = renderer.view?.place {
            uncachedParentsPlace = uncachedParentsPlace.concat(with: viewPlace)
        }
        return uncachedParentsPlace
    }
}

extension Node {

    func isAnimating() -> Bool {
        return !animations.filter { $0.state() == AnimationState.running }.isEmpty
    }

    func needsLayer() -> Bool {
        return !animations.filter { $0.state() == AnimationState.running || $0.state() == AnimationState.initial }.isEmpty
    }
}

extension NodeRenderer {

    func isAnimating() -> Bool {
        return layer != nil
    }

    func freeLayer() {

        let nodeRenderer = self
        guard let layer = nodeRenderer.layer, !node.needsLayer() else {
            return
        }
        nodeRenderer.layer = nil

        // find first parent with cached layer
        var parent: NodeRenderer? = nodeRenderer.parentRenderer
        var parentCachedLayer: CALayer? = nodeRenderer.sceneLayer
        while parent != nil {
            if let parent = parent, let cached = parent.layer {
                parentCachedLayer = cached.animationLayer
                break
            }
            parent = parent?.parentRenderer
        }

        // move children to closest parent layer
        for child in nodeRenderer.getAllChildrenRecursive() {
            if let cachedChildLayer = child.layer, let parentCachedLayer = parentCachedLayer {
                layer.animationLayer.sublayers?.forEach { childLayer in
                    if childLayer === cachedChildLayer.rootLayer {
                        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                        childLayer.removeFromSuperlayer()
                        childLayer.transform = CATransform3DMakeAffineTransform(AnimationUtils.uncachedParentsPlace(child).toCG())
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
}
