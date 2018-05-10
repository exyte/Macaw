import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

class TextRenderer: NodeRenderer {
    weak var text: Text?

    init(text: Text, ctx: RenderContext, animationCache: AnimationCache?) {
        self.text = text
        super.init(node: text, ctx: ctx, animationCache: animationCache)
    }

    override func node() -> Node? {
        return text
    }

    override func doAddObservers() {
        super.doAddObservers()

        guard let text = text else {
            return
        }

        observe(text.textVar)
        observe(text.fontVar)
        observe(text.fillVar)
        observe(text.strokeVar)
        observe(text.alignVar)
        observe(text.baselineVar)
    }

    override func doRender(_ force: Bool, opacity: Double) {
        guard let text = text else {
            return
        }

        let message = text.text
        let font = getMFont()
        // positive NSBaselineOffsetAttributeName values don't work, couldn't find why
        // for now move the rect itself
        if var color = text.fill as? Color {
            color = RenderUtils.applyOpacity(color, opacity: opacity)
            var attributes = [NSAttributedStringKey.font: font,
                              NSAttributedStringKey.foregroundColor: getTextColor(color)]
            if let stroke = text.stroke {
                if let c = stroke.fill as? Color {
                    attributes[NSAttributedStringKey.strokeColor] = getTextColor(c)
                }
                attributes[NSAttributedStringKey.strokeWidth] = stroke.width as NSObject?
            }
            MGraphicsPushContext(ctx.cgContext!)
            message.draw(in: getBounds(font), withAttributes: attributes)
            MGraphicsPopContext()
        }
    }

    override func doFindNodeAt(location: CGPoint, ctx: CGContext) -> Node? {
        guard let contains = node()?.bounds()?.cgRect().contains(location) else {
            return .none
        }

        if contains {
            return node()
        }

        return .none
    }

    fileprivate func getMFont() -> MFont {
        guard #available(iOS 9.0, macOS 10.11, *) else {
            // This case should never happen, since the deployment target is set to iOS 9.0/macOS 10.11.
            // However it is needed for the Swift Package Manager to work accordingly.
            return MFont()
        }
        guard let text = text, let textFont = text.font else {
            return MFont.systemFont(ofSize: MFont.mSystemFontSize)
        }
        
        if let customFont = RenderUtils.loadFont(name: textFont.name, size: textFont.size, weight: textFont.weight) {
            return customFont
        } else {
            if let weight = getWeight(textFont.weight) {
                return MFont.systemFont(ofSize: CGFloat(textFont.size), weight: weight)
            }
            return MFont.systemFont(ofSize: CGFloat(textFont.size))
        }
    }

    fileprivate func getWeight(_ weight: String) -> MFont.Weight? {
        guard #available(iOS 9.0, macOS 10.11, *) else {
            // This case should never happen, since the deployment target is set to iOS 9.0/macOS 10.11.
            // However it is needed for the Swift Package Manager to work accordingly.
            return .none
        }
        switch weight {
        case "normal":
            return MFont.Weight.regular
        case "bold":
            return MFont.Weight.bold
        case "bolder":
            return MFont.Weight.semibold
        case "lighter":
            return MFont.Weight.light
        default:
            return .none
        }
    }

    fileprivate func getBounds(_ font: MFont) -> CGRect {
        guard let text = text else {
            return .zero
        }

        let textAttributes = [NSAttributedStringKey.font: font]
        let textSize = NSString(string: text.text).size(withAttributes: textAttributes)
        return CGRect(x: calculateAlignmentOffset(text, font: font),
                      y: calculateBaselineOffset(text, font: font),
                      width: CGFloat(textSize.width), height: CGFloat(textSize.height))
    }

    fileprivate func calculateBaselineOffset(_ text: Text, font: MFont) -> CGFloat {
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

    fileprivate func calculateAlignmentOffset(_ text: Text, font: MFont) -> CGFloat {
        let textAttributes = [
            NSAttributedStringKey.font: font
        ]
        let textSize = NSString(string: text.text).size(withAttributes: textAttributes)
        return -CGFloat(text.align.align(size: textSize.width.doubleValue))
    }

    fileprivate func getTextColor(_ fill: Fill) -> MColor {
        if let color = fill as? Color {

            #if os(iOS)
            return MColor(cgColor: RenderUtils.mapColor(color))
            #elseif os(OSX)
            return MColor(cgColor: RenderUtils.mapColor(color)) ?? .black
            #endif

        }
        return MColor.black
    }
}
