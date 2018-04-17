import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

open class Text: Node {

    open let textVar: Variable<String>
    open var text: String {
        get { return textVar.value }
        set(val) { textVar.value = val }
    }

    open let fontVar: Variable<Font?>
    open var font: Font? {
        get { return fontVar.value }
        set(val) { fontVar.value = val }
    }

    open let fillVar: Variable<Fill>
    open var fill: Fill {
        get { return fillVar.value }
        set(val) { fillVar.value = val }
    }

    open let strokeVar: Variable<Stroke?>
    open var stroke: Stroke? {
        get { return strokeVar.value }
        set(val) { strokeVar.value = val }
    }

    open let alignVar: Variable<Align>
    open var align: Align {
        get { return alignVar.value }
        set(val) { alignVar.value = val }
    }

    open let baselineVar: Variable<Baseline>
    open var baseline: Baseline {
        get { return baselineVar.value }
        set(val) { baselineVar.value = val }
    }

    public init(text: String, font: Font? = nil, fill: Fill = Color.black, stroke: Stroke? = nil, align: Align = .min, baseline: Baseline = .top, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
        self.textVar = Variable<String>(text)
        self.fontVar = Variable<Font?>(font)
        self.fillVar = Variable<Fill>(fill)
        self.strokeVar = Variable<Stroke?>(stroke)
        self.alignVar = Variable<Align>(align)
        self.baselineVar = Variable<Baseline>(baseline)
        super.init(
            place: place,
            opaque: opaque,
            opacity: opacity,
            clip: clip,
            effect: effect,
            visible: visible,
            tag: tag
        )
    }

    // GENERATED NOT
    override internal func bounds() -> Rect {
        let font: MFont
        if let f = self.font {

            if let customFont = RenderUtils.loadFont(name: f.name, size: f.size) {
                font = customFont
            } else {
                font = MFont.systemFont(ofSize: CGFloat(f.size), weight: getWeight(f.weight))
            }
        } else {
            font = MFont.systemFont(ofSize: MFont.mSystemFontSize)
        }
        var stringAttributes: [NSAttributedStringKey: AnyObject] = [:]
        stringAttributes[NSAttributedStringKey.font] = font
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
            NSAttributedStringKey.font: font
        ]
        let textSize = NSString(string: text).size(withAttributes: textAttributes)
        return -align.align(size: textSize.width.doubleValue)
    }
    
    internal override func toDictionary() -> [String:Any] {
        var result = super.toDictionary()
        result["node"] = "Text"
        result["text"] = text
        if let font = font {
            result["font"] = font.toDictionary()
        }
        if let fillColor = fill as? Color {
            result["fill"] = fillColor.toDictionary()
        }
        if let stroke = stroke {
            result["stroke"] = stroke.toDictionary()
        }
        result["align"] = align.toString()
        result["baseline"] = "\(baseline)"
        return result
    }
    
    internal convenience init?(dictionary: [String:Any]) {
        guard let text = dictionary["text"] as? String else {
            return nil
        }
        self.init(text: text)
        
        if let fontDict = dictionary["font"] as? [String:Any] {
            font = Font(dictionary: fontDict)
        }
        if let fillDict = dictionary["fill"] as? [String:Any],
            let fillType = fillDict["type"] as? String,
            fillType == "Color",
            let color = Color(dictionary: fillDict) {
            fill = color
        }
        if let strokeDict = dictionary["stroke"] as? [String:Any] {
            stroke = Stroke(dictionary: strokeDict)
        }
        if let alignString = dictionary["align"] as? String {
            align = Align.instantiate(string: alignString)
        }
        if let baselineString = dictionary["baseline"] as? String {
            baseline = baselineForString(baselineString)
        }
        
        fromDictionary(dictionary: dictionary) // fill in the fields inherited from Node
    }

}

fileprivate func baselineForString(_ string: String) -> Baseline {
    switch(string) {
    case "top": return .top
    case "alphabetic": return .alphabetic
    case "bottom": return .bottom
    case "mid": return .mid
    default: return .top
    }
}
