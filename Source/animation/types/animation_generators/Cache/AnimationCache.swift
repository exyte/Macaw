
import UIKit

class AnimationCache {

	class CachedLayer {
		let layer: ShapeLayer
		let animation: Animation
		var linksCounter = 1

		required init(layer: ShapeLayer, animation: Animation) {
			self.layer = layer
			self.animation = animation
		}
	}

	let sceneLayer: CALayer
	var layerCache = [Node: CachedLayer]()

	required init(sceneLayer: CALayer) {
		self.sceneLayer = sceneLayer
	}

    func layerForNode(_ node: Node, animation: Animation, customBounds: Rect? = .none) -> ShapeLayer {
		guard let cachedLayer = layerCache[node] else {
			let layer = ShapeLayer()
			layer.animationCache = self

			// Use to debug animation layers
			// layer.backgroundColor = UIColor.green.cgColor
			// layer.borderWidth = 1.0
			// layer.borderColor = UIColor.blue.cgColor

            let calculatedBounds = customBounds ?? node.bounds()
			if let shapeBounds = calculatedBounds {
				let cgRect = shapeBounds.cgRect()

				let origFrame = CGRect(x: 0.0, y: 0.0,
					width: round(cgRect.width),
					height: round(cgRect.height))

				layer.bounds = origFrame
				layer.anchorPoint = CGPoint(
						x: -1.0 * cgRect.origin.x / cgRect.width,
						y: -1.0 * cgRect.origin.y / cgRect.height
				)

				layer.renderTransform = CGAffineTransform(translationX: -1.0 * cgRect.origin.x, y: -1.0 * cgRect.origin.y)

				let nodeTransform = RenderUtils.mapTransform(AnimationUtils.absolutePosition(node))
				layer.transform = CATransform3DMakeAffineTransform(nodeTransform)
                
                // Clip
                if let clip = AnimationUtils.absoluteClip(node: node) {
                    let maskLayer = CAShapeLayer()
                    let origPath = RenderUtils.toBezierPath(clip).cgPath
                    var offsetTransform = CGAffineTransform(translationX: -1.0 * cgRect.origin.x, y: -1.0 * cgRect.origin.y)
                    let clipPath = origPath.mutableCopy(using: &offsetTransform)
                    maskLayer.path = clipPath
                    layer.mask = maskLayer
                }
			}


            
			layer.opacity = Float(node.opacity)
			layer.node = node
			layer.setNeedsDisplay()
			sceneLayer.addSublayer(layer)

			layerCache[node] = CachedLayer(layer: layer, animation: animation)
			sceneLayer.setNeedsDisplay()

			return layer
		}

		cachedLayer.linksCounter += 1

		return cachedLayer.layer
	}

	func freeLayer(_ node: Node) {
		guard let cachedLayer = layerCache[node] else {
			return
		}

		cachedLayer.linksCounter -= 1

		if cachedLayer.linksCounter != 0 {
			return
		}

		let layer = cachedLayer.layer
		layerCache.removeValue(forKey: node)
		sceneLayer.setNeedsDisplay()
		layer.removeFromSuperlayer()
	}

	func isAnimating(_ node: Node) -> Bool {

		if let _ = layerCache[node] {
			return true
		}

		return false
	}

	func isChildrenAnimating(_ group: Group) -> Bool {

		for child in group.contents {
			if isAnimating(child) {
				return true
			}

			if let childGroup = child as? Group {
				return isChildrenAnimating(childGroup)
			}
		}

		return false
	}

	func containsAnimation(_ node: Node) -> Bool {
		if isAnimating(node) {
			return true
		}

		if let group = node as? Group {
			return isChildrenAnimating(group)
		}

		return false
	}

	func animations() -> [Animation] {

		return layerCache.map ({ $0.1.animation })
	}
}
