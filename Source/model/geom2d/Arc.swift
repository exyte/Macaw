import Foundation

open class Arc: Locus {

    open let ellipse: Ellipse
    open let shift: Double
    open let extent: Double

    public init(ellipse: Ellipse, shift: Double = 0, extent: Double = 0) {
        self.ellipse = ellipse
        self.shift = shift
        self.extent = extent
    }

    override open func bounds() -> Rect {
        return Rect(
            x: ellipse.cx - ellipse.rx,
            y: ellipse.cy - ellipse.ry,
            w: ellipse.rx * 2.0,
            h: ellipse.ry * 2.0)
    }
    
    internal override func toDictionary() -> [String:Any] {
        return ["type": "Arc", "ellipse": ellipse.toDictionary(), "shift": shift, "extent": extent]
    }
    
    internal convenience init(dictionary: [String:Any]) {
        self.init(ellipse: Ellipse(dictionary: dictionary["ellipse"] as? [String : Any] ?? [:]),
                  shift: parse(dictionary["shift"]),
                  extent: parse(dictionary["extent"]))
    }
}
