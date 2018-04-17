import Foundation

open class Stroke {

    open let fill: Fill
    open let width: Double
    open let cap: LineCap
    open let join: LineJoin
    open let dashes: [Double]

    public init(fill: Fill = Color.black, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = []) {
        self.fill = fill
        self.width = width
        self.cap = cap
        self.join = join
        self.dashes = dashes
    }
    
    internal func toDictionary() -> [String:Any] {
        var result = ["width": width, "cap": "\(cap)", "join": "\(join)", "dashes": dashes] as [String : Any]
        if let fillColor = fill as? Color {
            result["fill"] = fillColor.toDictionary()
        }
        return result
    }
    
    internal convenience init?(dictionary: [String:Any]) {
        
        guard let fillDict = dictionary["fill"] as? [String:Any], let fillType = fillDict["type"] as? String, fillType == "Color", let fill = Color(dictionary: fillDict) else {
            return nil
        }
        
        var cap = LineCap.butt
        if let lineCapString = dictionary["cap"] as? String {
            cap = lineCapForString(lineCapString)
        }
        
        var join = LineJoin.miter
        if let lineJoinString = dictionary["join"] as? String {
            join = lineJoinForString(lineJoinString)
        }
        
        let dashes = dictionary["dashes"] as? [Double] ?? []
                  
        self.init(fill: fill, width: parse(dictionary["width"]), cap: cap, join: join, dashes: dashes)
    }
}

fileprivate func lineCapForString(_ string: String) -> LineCap {
    switch(string) {
    case "butt": return .butt
    case "round": return .round
    case "square": return .square
    default: return .butt
    }
}

fileprivate func lineJoinForString(_ string: String) -> LineJoin {
    switch(string) {
    case "miter": return .miter
    case "round": return .round
    case "bevel": return .bevel
    default: return .miter
    }
}
