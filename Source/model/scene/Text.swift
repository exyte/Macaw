import UIKit

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
    
    public init(text: String, font: Font? = nil, fill: Fill = Color.black, align: Align = .min, baseline: Baseline = .top, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
        self.textVar = Variable<String>(text)
        self.fontVar = Variable<Font?>(font)
        self.fillVar = Variable<Fill>(fill)
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
        let font: UIFont
        if let f = self.font {
            
            if let customFont = RenderUtils.loadFont(name: f.name, size:f.size) {
                font = customFont
            } else {
                font = UIFont.systemFont(ofSize: CGFloat(f.size))
            }
        } else {
            font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
        var stringAttributes: [String: AnyObject] = [:]
        stringAttributes[NSFontAttributeName] = font
        let size = (text as NSString).size(attributes: stringAttributes)
        return Rect(
            x: calculateAlignmentOffset(font: font),
            y: calculateBaselineOffset(font: font),
            w: size.width.doubleValue,
            h: size.height.doubleValue
        )
    }
    
    fileprivate func calculateBaselineOffset(font: UIFont) -> Double {
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
    
    fileprivate func calculateAlignmentOffset(font: UIFont) -> Double {
        let textAttributes = [
            NSFontAttributeName: font
        ]
        let textSize = NSString(string: text).size(attributes: textAttributes)
        var alignmentOffset = 0.0
        switch align {
        case .mid:
            alignmentOffset = (textSize.width / 2).doubleValue
        case .max:
            alignmentOffset = textSize.width.doubleValue
        default:
            break
        }
        return -alignmentOffset
    }

}
