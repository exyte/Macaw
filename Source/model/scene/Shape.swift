import Foundation

open class Shape: Node {

    open let formVar: AnimatableVariable<Locus>
    open var form: Locus {
        get { return formVar.value }
        set(val) { formVar.value = val }
    }

    open let fillVar: AnimatableVariable<Fill?>
    open var fill: Fill? {
        get { return fillVar.value }
        set(val) { fillVar.value = val }
    }

    open let strokeVar: AnimatableVariable<Stroke?>
    open var stroke: Stroke? {
        get { return strokeVar.value }
        set(val) { strokeVar.value = val }
    }

    public init(form: Locus, fill: Fill? = nil, stroke: Stroke? = nil, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
        self.formVar = AnimatableVariable<Locus>(form)
        self.fillVar = AnimatableVariable<Fill?>(fill)
        self.strokeVar = AnimatableVariable<Stroke?>(stroke)
        super.init(
            place: place,
            opaque: opaque,
            opacity: opacity,
            clip: clip,
            effect: effect,
            visible: visible,
            tag: tag
        )

        self.formVar.node = self
        self.strokeVar.node = self
        self.fillVar.node = self
    }

    // GENERATED NOT
    override internal func bounds() -> Rect? {
        var bounds = form.bounds()

        if let shapeStroke = self.stroke {
            let r = shapeStroke.width / 2.0
            bounds = Rect(
                x: bounds.x - r,
                y: bounds.y - r,
                w: bounds.w + r * 2.0,
                h: bounds.h + r * 2.0)
        }

        return bounds
    }
    
    internal override func toDictionary() -> [String:Any] {
        var result = super.toDictionary()
        result["node"] = "Shape"
        result["form"] = form.toDictionary()
        if let fillColor = fill as? Color {
            result["fill"] = fillColor.toDictionary()
        }
        if let stroke = stroke {
            result["stroke"] = stroke.toDictionary()
        }
        return result
    }
    
    internal convenience init?(dictionary: [String:Any]) {
        
        guard let locusDict = dictionary["form"] as? [String:Any], let locus = Locus.instantiate(dictionary: locusDict) else {
            return nil
        }
        self.init(form: locus)
        
        if let fillDict = dictionary["fill"] as? [String:Any], let fillType = fillDict["type"] as? String, fillType == "Color" {
            fill = Color(dictionary: fillDict)
        }
        if let strokeDict = dictionary["stroke"] as? [String:Any] {
            stroke = Stroke(dictionary: strokeDict)
        }
        
        fromDictionary(dictionary: dictionary) // fill in the fields inherited from Node
    }
    
}
