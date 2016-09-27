import Foundation
import UIKit

class RenderUtils {
	class func mapColor(_ color: Color) -> CGColor {
		let red = CGFloat(Double(color.r()) / 255.0)
		let green = CGFloat(Double(color.g()) / 255.0)
		let blue = CGFloat(Double(color.b()) / 255.0)
		let alpha = CGFloat(Double(color.a()) / 255.0)
		return UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
	}

	class func mapTransform(_ t: Transform) -> CGAffineTransform {
		return CGAffineTransform(a: CGFloat(t.m11), b: CGFloat(t.m12), c: CGFloat(t.m21),
			d: CGFloat(t.m22), tx: CGFloat(t.dx), ty: CGFloat(t.dy))
	}

	class func mapLineJoin(_ join: LineJoin?) -> CGLineJoin {
		switch join {
		case LineJoin.round?: return CGLineJoin.round
		case LineJoin.bevel?: return CGLineJoin.bevel
		default: return CGLineJoin.miter
		}
	}

	class func mapLineCap(_ cap: LineCap?) -> CGLineCap {
		switch cap {
		case LineCap.round?: return CGLineCap.round
		case LineCap.square?: return CGLineCap.square
		default: return CGLineCap.butt
		}
	}

	class func mapDash(_ dashes: [Double]) -> UnsafeMutablePointer<CGFloat> {
		let p = UnsafeMutablePointer<CGFloat>(calloc(dashes.count, sizeof(CGFloat)))
		for (index, item) in dashes.enumerated() {
			p[index] = CGFloat(item)
		}
		return p
	}

	class func createNodeRenderer(_ node: Node, context: RenderContext, animationCache: AnimationCache) -> NodeRenderer {
		if let group = node as? Group {
			return GroupRenderer(group: group, ctx: context, animationCache: animationCache)
		} else if let shape = node as? Shape {
			return ShapeRenderer(shape: shape, ctx: context, animationCache: animationCache)
		} else if let text = node as? Text {
			return TextRenderer(text: text, ctx: context, animationCache: animationCache)
		} else if let image = node as? Image {
			return ImageRenderer(image: image, ctx: context, animationCache: animationCache)
		}
		fatalError("Unsupported node: \(node)");
	}

	class func applyOpacity(_ color: Color, opacity: Double) -> Color {
		return Color.rgba(r: color.r(), g: color.g(), b: color.b(), a: Double(color.a()) / 255.0 * opacity)
	}
}
