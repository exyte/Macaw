
import UIKit
import Macaw

class AnimationCache {

	class CachedLayer {
		let layer: ShapeLayer
		let animation: Animatable
		var linksCounter = 1

		required init(layer: ShapeLayer, animation: Animatable) {
			self.layer = layer
			self.animation = animation
		}
	}

	let sceneLayer: CALayer
	var layerCache = [Node: CachedLayer]()

	required init(sceneLayer: CALayer) {
		self.sceneLayer = sceneLayer
	}

	func layerForNode(node: Node, animation: Animatable) -> ShapeLayer {
		guard let cachedLayer = layerCache[node] else {
			let layer = ShapeLayer()
			layer.animationCache = self

			// layer.backgroundColor = UIColor.greenColor().CGColor
			layer.borderWidth = 1.0
			layer.borderColor = UIColor.blueColor().CGColor

			if let shapeBounds = node.bounds() {
				let cgRect = shapeBounds.cgRect()

				let origFrame = CGRectMake(0.0, 0.0,
					round(cgRect.width),
					round(cgRect.height))

				layer.bounds = origFrame
				layer.anchorPoint = CGPointMake(0.0, 0.0)

				layer.renderTransform = CGAffineTransformMakeTranslation(-1.0 * cgRect.origin.x, -1.0 * cgRect.origin.y)

				let nodeTransform = RenderUtils.mapTransform(AnimationUtils.absolutePosition(node))
				let layerTransform = CGAffineTransformMakeTranslation(cgRect.origin.x, cgRect.origin.y)

				layer.transform = CATransform3DMakeAffineTransform(CGAffineTransformConcat(nodeTransform, layerTransform))
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

	func freeLayer(node: Node) {
		guard let cachedLayer = layerCache[node] else {
			return
		}

		cachedLayer.linksCounter -= 1

		if cachedLayer.linksCounter != 0 {
			return
		}

		let layer = cachedLayer.layer
		layerCache.removeValueForKey(node)
		sceneLayer.setNeedsDisplay()
		layer.removeFromSuperlayer()
	}

	func isAnimating(node: Node) -> Bool {

		if let _ = layerCache[node] {
			return true
		}

		return false
	}

	func animations() -> [Animatable] {

		return layerCache.map ({ $0.1.animation })
	}
}
