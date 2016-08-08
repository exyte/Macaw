
import UIKit
import Macaw

let animationCache = AnimationCache()
class AnimationCache {

	class CachedLayer {
		let layer: ShapeLayer
		var linksCounter = 1

		required init(layer: ShapeLayer) {
			self.layer = layer
		}
	}

	var sceneLayer: CALayer?
	var layerCache = [Node: CachedLayer]()

	func layerForNode(node: Node) -> ShapeLayer {
		guard let cachedLayer = layerCache[node] else {
			let layer = ShapeLayer()

//			layer.backgroundColor = UIColor.greenColor().CGColor
//			layer.borderWidth = 1.0
//			layer.borderColor = UIColor.blueColor().CGColor

			if let shapeBounds = node.bounds() {
				let cgRect = shapeBounds.cgRect()

				layer.bounds = cgRect
				layer.anchorPoint = CGPointMake(0.0, 0.0)
			}

			layer.node = node
			layer.setNeedsDisplay()

			sceneLayer?.addSublayer(layer)

			layerCache[node] = CachedLayer(layer: layer)

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
		sceneLayer?.setNeedsDisplay()
		layer.removeFromSuperlayer()
		layerCache.removeValueForKey(node)
	}

	func isAnimating(node: Node) -> Bool {
		if let _ = layerCache[node] {
			return true
		}

		return false
	}
}
