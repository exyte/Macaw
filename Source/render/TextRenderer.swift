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

	override func addObservers() {
		super.addObservers()
		observe(text.textVar)
		observe(text.fontVar)
		observe(text.fillVar)
		observe(text.alignVar)
		observe(text.baselineVar)
	}

	override func render(force: Bool, opacity: Double) {

		super.render(force, opacity: opacity)

		if !force {
			// Cutting animated content
			if animationCache.isAnimating(text) {
				return
			}
		}

		let message = text.text
		var font: UIFont
		if let textFont = text.font {
			if let customFont = UIFont(name: textFont.name, size: CGFloat(textFont.size)) {
				font = customFont
			} else {
				font = UIFont.systemFontOfSize(CGFloat(textFont.size))
			}
		} else {
			font = UIFont.systemFontOfSize(UIFont.systemFontSize())
		}
		// positive NSBaselineOffsetAttributeName values don't work, couldn't find why
		// for now move the rect itself

		if var color = text.fill as? Color {
			color = RenderUtils.applyOpacity(color, opacity: opacity)
			let textAttributes = [
				NSFontAttributeName: font,
				NSForegroundColorAttributeName: getTextColor(color)]
			let textSize = NSString(string: text.text).sizeWithAttributes(textAttributes)

			guard let cgContext = ctx.cgContext else {
				return
			}

			UIGraphicsPushContext(cgContext)
			message.drawInRect(CGRectMake(calculateAlignmentOffset(text, font: font), calculateBaselineOffset(text, font: font),
				CGFloat(textSize.width), CGFloat(textSize.height)), withAttributes: textAttributes)
			UIGraphicsPopContext()
		}
	}

	override func detectTouches(location: CGPoint) -> [Shape] {
		return []
	}

	private func calculateBaselineOffset(text: Text, font: UIFont) -> CGFloat {
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

	private func calculateAlignmentOffset(text: Text, font: UIFont) -> CGFloat {
		let textAttributes = [
			NSFontAttributeName: font
		]
		let textSize = NSString(string: text.text).sizeWithAttributes(textAttributes)
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

	private func getTextColor(fill: Fill) -> UIColor {
		if let color = fill as? Color {
			return UIColor(CGColor: RenderUtils.mapColor(color))
		}
		return UIColor.blackColor()
	}
}