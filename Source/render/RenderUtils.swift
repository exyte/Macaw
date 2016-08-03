import Foundation
import UIKit

class RenderUtils {
	class func mapColor(color: Color) -> CGColor {
		let red = CGFloat(Double(color.r()) / 255.0)
		let green = CGFloat(Double(color.g()) / 255.0)
		let blue = CGFloat(Double(color.b()) / 255.0)
		let alpha = CGFloat(Double(color.a()) / 255.0)
		return UIColor(red: red, green: green, blue: blue, alpha: alpha).CGColor
	}

	class func mapTransform(t: Transform) -> CGAffineTransform {
		return CGAffineTransform(a: CGFloat(t.m11), b: CGFloat(t.m12), c: CGFloat(t.m21),
			d: CGFloat(t.m22), tx: CGFloat(t.dx), ty: CGFloat(t.dy))
	}

	class func mapLineJoin(join: LineJoin?) -> CGLineJoin {
		switch join {
		case LineJoin.round?: return CGLineJoin.Round
		case LineJoin.bevel?: return CGLineJoin.Bevel
		default: return CGLineJoin.Miter
		}
	}

	class func mapLineCap(cap: LineCap?) -> CGLineCap {
		switch cap {
		case LineCap.round?: return CGLineCap.Round
		case LineCap.square?: return CGLineCap.Square
		default: return CGLineCap.Butt
		}
	}

	class func mapDash(dashes: [Double]) -> UnsafeMutablePointer<CGFloat> {
		let p = UnsafeMutablePointer<CGFloat>(calloc(dashes.count, sizeof(CGFloat)))
		for (index, item) in dashes.enumerate() {
			p[index] = CGFloat(item)
		}
		return p
	}

	class func createNodeRenderer(node: Node, context: RenderContext) -> NodeRenderer? {
		if let group = node as? Group {
			return GroupRenderer(group: group, ctx: context)
		} else if let shape = node as? Shape {
			return ShapeRenderer(shape: shape, ctx: context)
		} else if let text = node as? Text {
			return TextRenderer(text: text, ctx: context)
		} else if let image = node as? Image {
			return ImageRenderer(image: image, ctx: context)
		}
		print("Unsupported node: \(node)")
		return nil
	}

	class func  applyOpacity(color: Color, opacity: Double) -> Color {
		return Color.rgba(color.r(), g: color.g(), b: color.b(), a: Double(color.a()) / 255.0 * opacity)
	}
}