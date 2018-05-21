//
//  SceneSerialization.swift
//  MacawTests
//
//  Created by Alisa Mylnikova on 23/04/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import UIKit
@testable import Macaw

protocol Initializable {
    init()
}

extension Double : Initializable {}
extension Bool : Initializable {}
extension Int : Initializable {}

func parse<T: Initializable>(_ from: Any?) -> T {
    return from as? T ?? T()
}

protocol Serializable {
    func toDictionary() -> [String:Any]
}

class NodeSerializer {
    
    var factories = [String:([String:Any]) -> Node]()
    
    let locusSerializer = LocusSerializer()
    
    init() {
        factories["Shape"] = { dictionary in
            let locusDict = dictionary["form"] as! [String:Any]
            let locus = self.locusSerializer.instance(dictionary: locusDict)
            
            let shape = Shape(form: locus)
            
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
                nodes.append(self.instance(dictionary: dict))
            }
            return Group(contents: nodes)
        }
        factories["Canvas"] = { dictionary in
            let layoutDict = dictionary["layout"] as! [String : Any]
            let viewBoxDict = layoutDict["viewBox"] as! [String:Any]
            let layout = SVGNodeLayout(
                svgSize: SVGSize(dictionary: layoutDict["svgSize"] as! [String : Any]),
                viewBox: self.locusSerializer.instance(dictionary: viewBoxDict) as? Rect,
                scaling: AspectRatio.instantiate(string: layoutDict["scalingMode"] as! String),
                xAlign: Align.instantiate(string: layoutDict["xAligningMode"] as! String),
                yAlign: Align.instantiate(string: layoutDict["yAligningMode"] as! String))
            let contents = dictionary["contents"] as! [[String:Any]]
            var nodes = [Node]()
            for dict in contents {
                nodes.append(self.instance(dictionary: dict))
            }
            return SVGCanvas(layout: layout, contents: nodes)
        }
    }
    
    func instance(dictionary: [String:Any]) -> Node {
        let type = dictionary["node"] as! String
        let node = factories[type]!(dictionary)
        node.place = Transform(string: dictionary["place"] as? String)
        node.opaque = Bool(dictionary["opaque"] as? String ?? "") ?? true
        node.opacity = Double(dictionary["opacity"] as? String ?? "") ?? 0
        if let locusDict = dictionary["clip"] as? [String:Any] {
            node.clip = locusSerializer.instance(dictionary: locusDict)
        }
        return node
    }
}

extension Node {
    
    func baseToDictionary() -> [String:Any] {
        var result = [String : Any]()
        if place != .identity {
            result["place"] = place.toString()
        }
        if !opaque {
            result["opaque"] = String(describing: opaque)
            result["opacity"] = String(describing: opacity)
        }
        if let clip = clip as? Serializable {
            result["clip"] = clip.toDictionary()
        }
        return result
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
        if let canvas = self as? SVGCanvas {
            return canvas.canvasDictionary()
        }
        
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

extension SVGCanvas {
    
    func canvasDictionary() -> [String:Any] {
        var nodes = [[String:Any]]()
        for node in contents {
            if let node = node as? Serializable {
                nodes.append(node.toDictionary())
            }
        }
        var result = super.baseToDictionary()
        result["node"] = "Canvas"
        result["layout"] = (layout as! SVGNodeLayout).toDictionary()
        result["contents"] = nodes
        return result
    }
}

extension SVGNodeLayout: Serializable {
    
    func toDictionary() -> [String:Any] {
        return ["svgSize" : svgSize.toDictionary() as Any,
                "viewBox" : viewBox?.toDictionary() as Any,
                "scalingMode" : scaling.toString(),
                "xAligningMode" : xAlign.toString(),
                "yAligningMode" : yAlign.toString()]
    }
}

extension SVGSize: Serializable {
    
    func toDictionary() -> [String:Any] {
        return ["width" : width.toString(), "height": height.toString()]
    }
    
    convenience init(dictionary: [String:Any]) {
        self.init(width: SVGLength(string: dictionary["width"] as? String), height: SVGLength(string: dictionary["height"] as? String))
    }
}

extension SVGLength {
    
    func toString() -> String {
        switch(self) {
        case let .percent(percent):
            return "\(percent)%"
        case let .pixels(pixels):
            return String(describing: pixels)
        }
    }
    
    init(string: String?) {
        self.init(pixels: 0)
        guard let string = string else {
            return
        }
        if string.hasSuffix("%") {
            self = SVGLength.percent(Double(string.dropLast())!)
        } else {
            self = SVGLength.pixels(Double(string)!)
        }
    }
}


class LocusSerializer {
    
    var factories = [String:([String:Any]) -> Locus]()
    
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
                pathSegments.append(PathSegment(
                    type: typeForString(dict["type"] as! String),
                    data: dict["data"] as! [Double]))
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
    
    func toDictionary() -> [String:Any] {
        return ["type": "\(type)", "data": data]
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
    
    func toDictionary() -> [String:Any] {
        var result = ["width": width, "cap": "\(cap)", "join": "\(join)", "dashes": dashes] as [String : Any]
        if let fillColor = fill as? Color {
            result["fill"] = fillColor.toDictionary()
        }
        return result
    }
    
    convenience init?(dictionary: [String:Any]) {
        
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
    
    func toDictionary() -> [String:Any] {
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
    
    func toString() -> String {
        if self === Align.mid {
            return "mid"
        }
        if self === Align.max {
            return "max"
        }
        return "min"
    }
    
    static func instantiate(string: String) -> Align {
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

extension AspectRatio {
    
    func toString() -> String {
        if self === AspectRatio.meet {
            return "meet"
        }
        if self === AspectRatio.slice {
            return "slice"
        }
        return "none"
    }
    
    static func instantiate(string: String) -> AspectRatio {
        switch string {
        case "meet":
            return .meet
        case "slice":
            return .slice
        default:
            return .none
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
