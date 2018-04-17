import Foundation

open class Locus {

    public init() {
    }

    // GENERATED NOT
    open func bounds() -> Rect {
        return Rect()
    }

    // GENERATED NOT
    open func stroke(with: Stroke) -> Shape {
        return Shape(form: self, stroke: with)
    }

    // GENERATED NOT
    open func fill(with: Fill) -> Shape {
        return Shape(form: self, fill: with)
    }

    // GENERATED NOT
    open func stroke(fill: Fill = Color.black, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = []) -> Shape {
        return Shape(form: self, stroke: Stroke(fill: fill, width: width, cap: cap, join: join, dashes: dashes))
    }
    
    internal func toDictionary() -> [String:Any] {
        fatalError("Please implement in subclass")
    }
    
    internal convenience init(_ dictionary: [String:Any], rara: Int) {
        fatalError("Please implement in subclass")
    }
    
    internal static func instantiate(dictionary: [String:Any]) -> Locus? {
        guard let type = dictionary["type"] as? String else {
            fatalError("No type specified")
        }
        if type == "Arc" {
            return Arc(dictionary: dictionary)
        }
        if type == "Circle" {
            return Circle(dictionary: dictionary)
        }
        if type == "Ellipse" {
            return Ellipse(dictionary: dictionary)
        }
        if type == "Line" {
            return Line(dictionary: dictionary)
        }
        if type == "Path" {
            return Path(dictionary: dictionary)
        }
        if type == "Polygon" {
            return Polygon(dictionary: dictionary)
        }
        if type == "Polyline" {
            return Polyline(dictionary: dictionary)
        }
        if type == "Rect" {
            return Rect(dictionary: dictionary)
        }
        if type == "RoundRect" {
            return RoundRect(dictionary: dictionary)
        }
        
        print("Locus from dictionary error. Locus \(type) not supported")
        return nil
    }
}
