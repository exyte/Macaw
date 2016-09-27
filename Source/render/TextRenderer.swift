import Foundation
import UIKit

class TextRenderer: NodeRenderer {
	let text: Text

	init(text: Text, ctx: RenderContext, animationCache: AnimationCache) {
		self.text = text
		super.init(node: text, ctx: ctx, animationCache: animationCache)
	}

	override func node() -> Node {
		return text
	}

	override func doAddObservers() {
		super.doAddObservers()
		observe(text.textVar)
		observe(text.fontVar)
		observe(text.fillVar)
		observe(text.alignVar)
		observe(text.baselineVar)
	}

	override func doRender(_ force: Bool, opacity: Double) {
		let message = text.text
		var font: UIFont
		if let textFont = text.font {
			if let customFont = UIFont(name: textFont.name, size: CGFloat(textFont.size)) {
				font = customFont
			} else {
				font = UIFont.systemFont(ofSize: CGFloat(textFont.size))
			}
		} else {
			font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
		}
		// positive NSBaselineOffsetAttributeName values don't work, couldn't find why
		// for now move the rect itself

		if var color = text.fill as? Color {
			color = RenderUtils.applyOpacity(color, opacity: opacity)
			let textAttributes = [
				NSFontAttributeName: font,
				NSForegroundColorAttributeName: getTextColor(color)] as [String : Any]
			let textSize = NSString(string: text.text).size(attributes: textAttributes)

			guard let cgContext = ctx.cgContext else {
				return
			}

			UIGraphicsPushContext(cgContext)
			message.draw(in: CGRect(x: calculateAlignmentOffset(text, font: font), y: calculateBaselineOffset(text, font: font),
				width: CGFloat(textSize.width), height: CGFloat(textSize.height)), withAttributes: textAttributes)
			UIGraphicsPopContext()
		}
	}

	override func detectTouches(_ location: CGPoint) -> [Shape] {
		return []
	}

	fileprivate func calculateBaselineOffset(_ text: Text, font: UIFont) -> CGFloat {
		var baselineOffset = CGFloat(0)
		switch text.baseline {
		case Baseline.alphabetic:
			baselineOffset = font.ascender
		case Baseline.bottom:
			baselineOffset = font.ascender - font.descender
		case Baseline.mid:
			baselineOffset = (font.ascender - font.descender) / 2
		default:
			break
		}
		return -baselineOffset
	}

	fileprivate func calculateAlignmentOffset(_ text: Text, font: UIFont) -> CGFloat {
		let textAttributes = [
			NSFontAttributeName: font
		]
		let textSize = NSString(string: text.text).size(attributes: textAttributes)
		var alignmentOffset = CGFloat(0)
		switch text.align {
		case Align.mid:
			alignmentOffset = textSize.width / 2
		case Align.max:
			alignmentOffset = textSize.width
		default:
			break
		}
		return -alignmentOffset
	}

	fileprivate func getTextColor(_ fill: Fill) -> UIColor {
		if let color = fill as? Color {
			return UIColor(cgColor: RenderUtils.mapColor(color))
		}
		return UIColor.black
	}
}
