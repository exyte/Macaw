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
        let font = getUIFont()
        // positive NSBaselineOffsetAttributeName values don't work, couldn't find why
        // for now move the rect itself
        if var color = text.fill as? Color {
            color = RenderUtils.applyOpacity(color, opacity: opacity)
            UIGraphicsPushContext(ctx.cgContext!)
            message.draw(in: getBounds(font), withAttributes: [NSFontAttributeName: font,
                                                               NSForegroundColorAttributeName: getTextColor(color)])
            UIGraphicsPopContext()
        }
    }
    
    fileprivate func getUIFont() -> UIFont {
        if let textFont = text.font {
            if let customFont = RenderUtils.loadFont(name: textFont.name, size: textFont.size) {
                return customFont
            } else {
                return UIFont.systemFont(ofSize: CGFloat(textFont.size))
            }
        }
        return UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }
    
    fileprivate func getBounds(_ font: UIFont) -> CGRect {
        let textAttributes = [NSFontAttributeName: font]
        let textSize = NSString(string: text.text).size(attributes: textAttributes)
        return CGRect(x: calculateAlignmentOffset(text, font: font),
                      y: calculateBaselineOffset(text, font: font),
                      width: CGFloat(textSize.width), height: CGFloat(textSize.height))
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
