#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

open class Text: Node {

    public let textVar: Variable<String>
    open var text: String {
        get { return textVar.value }
        set(val) { textVar.value = val }
    }

    public let fontVar: Variable<Font?>
    open var font: Font? {
        get { return fontVar.value }
        set(val) { fontVar.value = val }
    }

    public let fillVar: Variable<Fill?>
    open var fill: Fill? {
        get { return fillVar.value }
        set(val) { fillVar.value = val }
    }

    public let strokeVar: Variable<Stroke?>
    open var stroke: Stroke? {
        get { return strokeVar.value }
        set(val) { strokeVar.value = val }
    }

    public let alignVar: Variable<Align>
    open var align: Align {
        get { return alignVar.value }
        set(val) { alignVar.value = val }
    }

    public let baselineVar: Variable<Baseline>
    open var baseline: Baseline {
        get { return baselineVar.value }
        set(val) { baselineVar.value = val }
    }

    public init(text: String, font: Font? = nil, fill: Fill? = Color.black, stroke: Stroke? = nil, align: Align = .min, baseline: Baseline = .top, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, mask: Node? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
        self.textVar = Variable<String>(text)
        self.fontVar = Variable<Font?>(font)
        self.fillVar = Variable<Fill?>(fill)
        self.strokeVar = Variable<Stroke?>(stroke)
        self.alignVar = Variable<Align>(align)
        self.baselineVar = Variable<Baseline>(baseline)
        super.init(
            place: place,
            opaque: opaque,
            opacity: opacity,
            clip: clip,
            mask: mask,
            effect: effect,
            visible: visible,
            tag: tag
        )
    }

    override open var bounds: Rect {
        let font: MFont
        if let f = self.font {

            if let customFont = RenderUtils.loadFont(name: f.name, size: f.size, weight: f.weight) {
                font = customFont
            } else {
                font = MFont.systemFont(ofSize: CGFloat(f.size), weight: getWeight(f.weight))
            }
        } else {
            font = MFont.systemFont(ofSize: MFont.mSystemFontSize)
        }
        var stringAttributes: [NSAttributedString.Key: AnyObject] = [:]
        stringAttributes[NSAttributedString.Key.font] = font
        let size = (text as NSString).size(withAttributes: stringAttributes)
        return Rect(
            x: calculateAlignmentOffset(font: font),
            y: calculateBaselineOffset(font: font),
            w: size.width.doubleValue,
            h: size.height.doubleValue
        )
    }

    fileprivate func getWeight(_ weight: String) -> MFont.Weight {
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
            return MFont.Weight.regular
        }
    }

    fileprivate func calculateBaselineOffset(font: MFont) -> Double {
        var baselineOffset = 0.0
        switch baseline {
        case .alphabetic:
            baselineOffset = font.ascender.doubleValue
        case .bottom:
            baselineOffset = (font.ascender - font.descender).doubleValue
        case .mid:
            baselineOffset = ((font.ascender - font.descender) / 2).doubleValue
        default:
            break
        }
        return -baselineOffset
    }

    fileprivate func calculateAlignmentOffset(font: MFont) -> Double {
        let textAttributes = [
            NSAttributedString.Key.font: font
        ]
        let textSize = NSString(string: text).size(withAttributes: textAttributes)
        return -align.align(size: textSize.width.doubleValue)
    }

}
