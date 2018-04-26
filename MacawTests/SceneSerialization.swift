//
//  SceneSerialization.swift
//  MacawTests
//
//  Created by Alisa Mylnikova on 23/04/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import UIKit
import Macaw

protocol Initializable {
    init()
}

extension Double : Initializable {}
extension Bool : Initializable {}
extension Int : Initializable {}

func parse<T: Initializable>(_ from: Any?) -> T {
    return from as? T ?? T()
}


internal protocol Serializable {
    func toDictionary() -> [String:Any]
}



class NodeSerializer {
    
    var factories = [String:([String:Any]) -> Node]()
    
    static var shared = NodeSerializer()
    
    init() {
        factories["Shape"] = { dictionary in
            let locusDict = dictionary["form"] as! [String:Any]
            let locus = LocusSerializer.shared.instance(dictionary: locusDict)
            
            let shape = Shape(form: locus)
            shape.fromDictionary(dictionary: dictionary) // fill in the fields inherited from Node
            
            if let fillDict = dictionary["fill"] as? [String:Any], let fillType = fillDict["type"] as? String, fillType == "Color" {
                shape.fill = Color(dictionary: fillDict)
            }
            if let strokeDict = dictionary["stroke"] as? [String:Any] {
                shape.stroke = Stroke(dictionary: strokeDict)
            }
            
            return shape
        }
        factories["Text"] = { dictionary in
            let textString = dictionary["text"] as! String
            let text = Text(text: textString)
            text.fromDictionary(dictionary: dictionary) // fill in the fields inherited from Node
            
            if let fontDict = dictionary["font"] as? [String:Any] {
                text.font = Font(dictionary: fontDict)
            }
            if let fillDict = dictionary["fill"] as? [String:Any],
                let fillType = fillDict["type"] as? String,
                fillType == "Color",
                let color = Color(dictionary: fillDict) {
                text.fill = color
            }
            if let strokeDict = dictionary["stroke"] as? [String:Any] {
                text.stroke = Stroke(dictionary: strokeDict)
            }
            if let alignString = dictionary["align"] as? String {
                text.align = Align.instantiate(string: alignString)
            }
            if let baselineString = dictionary["baseline"] as? String {
                text.baseline = baselineForString(baselineString)
            }
            
            return text
        }
        factories["Group"] = { dictionary in
            let contents = dictionary["contents"] as! [[String:Any]]
            var nodes = [Node]()
            for dict in contents {
                nodes.append(NodeSerializer.shared.instance(dictionary: dict))
            }
            let group = Group()
            group.fromDictionary(dictionary: dictionary) // fill in the fields inherited from Node
            group.contents = nodes
            return group
        }
    }
    
    func instance(dictionary: [String:Any]) -> Node {
        let type = dictionary["node"] as! String
        return factories[type]!(dictionary)
    }
}

extension Node {
    
    func baseToDictionary() -> [String:Any] {
        var result = ["place": place.toString(), "opaque": String(describing: opaque), "opacity": String(describing: opacity)] as [String : Any]
        if let clip = clip as? Serializable {
            result["clip"] = clip.toDictionary()
        }
        return result
    }
    
    func fromDictionary(dictionary: [String:Any]) {
        place = Transform(string: dictionary["place"] as? String)
        opaque = Bool(dictionary["opaque"] as? String ?? "") ?? true
        opacity = Double(dictionary["opacity"] as? String ?? "") ?? 0
        if let locusDict = dictionary["clip"] as? [String:Any] {
            clip = LocusSerializer.shared.instance(dictionary: locusDict)
        }
    }
}

extension Shape: Serializable {
    
    func toDictionary() -> [String:Any] {
        var result = super.baseToDictionary()
        result["node"] = "Shape"
        if let form = form as? Serializable {
            result["form"] = form.toDictionary()
        }
        if let fillColor = fill as? Color {
            result["fill"] = fillColor.toDictionary()
        }
        if let stroke = stroke {
            result["stroke"] = stroke.toDictionary()
        }
        return result
    }
}

extension Text: Serializable {
    
    func toDictionary() -> [String:Any] {
        var result = super.baseToDictionary()
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
}

extension Group: Serializable {
    
    func toDictionary() -> [String:Any] {
        var nodes = [[String:Any]]()
        for node in contents {
            if let node = node as? Serializable {
                nodes.append(node.toDictionary())
            }
        }
        var result = super.baseToDictionary()
        result["node"] = "Group"
        result["contents"] = nodes
        return result
    }
}



class LocusSerializer {
    
    var factories = [String:([String:Any]) -> Locus]()
    
    static var shared = LocusSerializer()
    
    init() {
        factories["Arc"] = { dictionary in
            Arc(ellipse: self.instance(dictionary: dictionary["Ellipse"] as! [String:Any]) as! Ellipse,
                shift: parse(dictionary["shift"]),
                extent: parse(dictionary["extent"]))
        }
        factories["Circle"] = { dictionary in
            Circle(cx: parse(dictionary["cx"]),
                   cy: parse(dictionary["cy"]),
                   r: parse(dictionary["r"]))
        }
        factories["Ellipse"] = { dictionary in
            Ellipse(cx: parse(dictionary["cx"]),
                    cy: parse(dictionary["cy"]),
                    rx: parse(dictionary["rx"]),
                    ry: parse(dictionary["rx"]))
        }
        factories["Line"] = { dictionary in
            Line(x1: parse(dictionary["x1"]),
                 y1: parse(dictionary["y1"]),
                 x2: parse(dictionary["x2"]),
                 y2: parse(dictionary["y2"]))
        }
        factories["Path"] = { dictionary in
            let array = dictionary["segments"] as! [[String:Any]]
            var pathSegments = [PathSegment]()
            for dict in array {
                pathSegments.append(PathSegment(dictionary: dict))
            }
            return Path(segments: pathSegments)
        }
        factories["Polygon"] = { dictionary in
            Polygon.init(points: dictionary["points"] as! [Double])
        }
        factories["Polyline"] = { dictionary in
            Polyline.init(points: dictionary["points"] as! [Double])
        }
        factories["Rect"] = { dictionary in
            Rect(x: parse(dictionary["x"]),
                 y: parse(dictionary["y"]),
                 w: parse(dictionary["w"]),
                 h: parse(dictionary["h"]))
        }
        factories["RoundRect"] = { dictionary in
            RoundRect(rect: self.instance(dictionary: dictionary["Rect"] as! [String:Any]) as! Rect,
                      rx: parse(dictionary["rx"]),
                      ry: parse(dictionary["ry"]))
        }
    }
    
    func instance(dictionary: [String:Any]) -> Locus {
        let type = dictionary["type"] as! String
        return factories[type]!(dictionary)
    }
}

extension Arc: Serializable {
    
    func toDictionary() -> [String:Any] {
        return ["type": "Arc", "ellipse": ellipse.toDictionary(), "shift": shift, "extent": extent]
    }
}

extension Circle: Serializable {
    
    func toDictionary() -> [String:Any] {
        return ["type": "Circle", "cx": cx, "cy": cy, "r": r]
    }
}

extension Ellipse: Serializable {
    
    func toDictionary() -> [String:Any] {
        return ["type": "Ellipse", "cx": cx, "cy": cy, "rx": rx, "ry": ry]
    }
}

extension Line: Serializable {
    
    func toDictionary() -> [String:Any] {
        return ["type": "Line", "x1": x1, "y1": y1, "x2": x2, "y2": y2]
    }
}

extension Path: Serializable {
    
    func toDictionary() -> [String:Any] {
        var pathSegments = [[String:Any]]()
        for segment in segments {
            pathSegments.append(segment.toDictionary())
        }
        return ["type": "Path", "segments": pathSegments]
    }
}

extension Polygon: Serializable {
    
    func toDictionary() -> [String:Any] {
        return ["type": "Polygon", "points": points]
    }
}

extension Polyline: Serializable {
    
    func toDictionary() -> [String:Any] {
        return ["type": "Polyline", "points": points]
    }
}

extension Rect: Serializable {
    
    func toDictionary() -> [String:Any] {
        return ["type": "Rect", "x": x, "y": y, "w": w, "h": h]
    }
}

extension RoundRect: Serializable {
    
    func toDictionary() -> [String:Any] {
        return ["type": "RoundRect", "rect": rect.toDictionary(), "rx": rx, "ry": ry]
    }
}



extension PathSegment: Serializable {
    
    internal func toDictionary() -> [String:Any] {
        return ["type": "\(type)", "data": data]
    }
    
    convenience init(dictionary: [String:Any]) {
        guard let typeString = dictionary["type"] as? String, let array = dictionary["data"] as? [Double] else { self.init(); return }
        
        self.init(type: typeForString(typeString),
                  data: array)
    }
}

extension Color: Serializable {
    
    func toDictionary() -> [String:Any] {
        return ["type": "Color", "val": val]
    }
    
    convenience init?(dictionary: [String:Any]) {
        self.init(val: dictionary["val"] as! Int)
    }
}

extension Stroke: Serializable {
    
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

extension Font: Serializable {
    
    internal func toDictionary() -> [String:Any] {
        return ["name": name, "size": size, "weight": weight]
    }
    
    convenience init(dictionary: [String:Any]) {
        self.init(name: dictionary["name"] as? String ?? "Serif",
                  size: parse(dictionary["size"]),
                  weight: dictionary["weight"] as? String ?? "normal")
    }
}

extension Transform {
    
    func toString() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        
        let nums = [m11, m12, m21, m22, dx, dy]
        
        var result = ""
        for num in nums {
            result += formatter.string(from: num as NSNumber) ?? "n/a"
            result += ", "
        }
        return result.dropLast(2) + ""
    }
    
    convenience init(string: String?) {
        guard let string = string else {
            self.init()
            return
        }
        let vals = string.components(separatedBy: ", ").map{ Double($0) ?? 0 }
        if vals.count == 6 {
            self.init(m11: vals[0], m12: vals[1], m21: vals[2], m22: vals[3], dx: vals[4], dy: vals[5])
        } else {
            self.init()
        }
    }
}

extension Align {
    
    internal func toString() -> String {
        if self === Align.mid {
            return "mid"
        }
        if self === Align.max {
            return "max"
        }
        return "min"
    }
    
    internal static func instantiate(string: String) -> Align {
        switch string {
        case "mid":
            return .mid
        case "max":
            return .max
        default:
            return .min
        }
    }
}



fileprivate func typeForString(_ string: String) -> PathSegmentType {
    switch(string) {
    case "M": return .M
    case "m": return .m
    case "L": return .L
    case "l": return .l
    case "C": return .C
    case "c": return .c
    case "Q": return .Q
    case "q": return .q
    case "A": return .A
    case "a": return .a
    case "z", "Z": return .z
    case "H": return .H
    case "h": return .h
    case "V": return .V
    case "v": return .v
    case "S": return .S
    case "s": return .s
    case "T": return .T
    case "t": return .t
    default: return .M
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

fileprivate func baselineForString(_ string: String) -> Baseline {
    switch(string) {
    case "top": return .top
    case "alphabetic": return .alphabetic
    case "bottom": return .bottom
    case "mid": return .mid
    default: return .top
    }
}
