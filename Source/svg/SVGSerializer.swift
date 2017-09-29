//
//  SVGSerializer.swift
//  Macaw
//
//  Created by Yuriy Kashnikov on 8/17/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

///
/// This class serializes Macaw Scene into an SVG String
///
open class SVGSerializer {
    
    fileprivate let width: Int?
    fileprivate let height: Int?
    fileprivate let id: String?
    fileprivate let indent: Int
    
    fileprivate init(width: Int?, height: Int?, id: String?) {
        self.width = width
        self.height = height
        self.id = id
        self.indent = 0
    }
    
    // header and footer
    fileprivate let SVGDefaultHeader = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\""
    fileprivate static let SVGDefaultId = ""
    fileprivate static let SVGUndefinedSize = -1
    fileprivate let SVGFooter = "</svg>"
    
    // groups
    fileprivate let SVGGroupOpenTag = "<g"
    fileprivate let SVGGroupCloseTag = "</g>"
    
    // shapes
    fileprivate let SVGRectOpenTag = "<rect "
    fileprivate let SVGCircleOpenTag = "<circle "
    fileprivate let SVGEllipseOpenTag = "<ellipse "
    fileprivate let SVGLineOpenTag = "<line "
    fileprivate let SVGPolylineOpenTag = "<polyline "
    fileprivate let SVGPolygonOpenTag = "<polygon "
    fileprivate let SVGPathOpenTag = "<path "
    fileprivate let SVGImageOpenTag = "<image "
    fileprivate let SVGTextOpenTag = "<text "

    fileprivate let SVGGenericEndTag = ">"
    fileprivate let SVGGenericCloseTag = "/>"
    
    fileprivate let SVGUndefinedTag = "<UNDEFINED "
    fileprivate let indentPrefixSymbol = " "
    
    
    fileprivate func indentTextWithOffset(_ text: String, _ offset: Int) -> String {
        if self.indent != 0 {
            let prefix = String(repeating: indentPrefixSymbol, count:self.indent)
            return "\n\(String(repeating: prefix, count:offset))\(text)"
        }
        return text
    }
    
    fileprivate func att(_ a: Double) -> String {
        return String(Int(a))
    }
    
    fileprivate func tag(_ tag: String, _ args: [String:String], close: Bool=false) -> String {
        let attrs = args.map { "\($0)=\"\($1)\"" }.joined(separator: " ")
        let closeTag = close ? " />" : ""
        return "\(tag) \(attrs) \(closeTag)"
    }
    
    fileprivate func arcToSVG(_ arc: Arc) -> String {
        if (arc.shift == 0.0) {
            return tag(SVGEllipseOpenTag, ["cx":att(arc.ellipse.cx), "cy":att(arc.ellipse.cy), "rx":att(arc.ellipse.rx), "ry":att(arc.ellipse.ry)])
        } else {
            // Convert arc to SVG format with x axis rotation, arc flag, and sweep flag
            return "\(SVGUndefinedTag) arc is not implemented yet"
        }
    }
    
    
    fileprivate func polygonToSVG(_ polygon: Polygon) -> String {
        let points = polygon.points.flatMap { String($0) }.joined(separator: ",")
        return tag(SVGPolygonOpenTag, ["points":points])
    }
    
    fileprivate func polylineToSVG(_ polyline: Polyline) -> String {
        let points = polyline.points.flatMap { String($0) }.joined(separator: ",")
        return tag(SVGPolylineOpenTag, ["points":points])
    }
    
    fileprivate func pathToSVG(_ path: Path) -> String {
        var d = ""
        for segment in path.segments {
            d += "\(segment.type) \(segment.data.flatMap { String(Int($0)) }.joined(separator: " "))"
        }
        return tag(SVGPathOpenTag, ["d":d])
    }
    
    fileprivate func lineToSVG(_ line: Line) -> String {
        return tag(SVGLineOpenTag, ["x1":String(Int(line.x1)), "y1":att(line.y1), "x2":att(line.x2), "y2":att(line.y2)])
    }
    
    fileprivate func ellipseToSVG(_ ellipse: Ellipse) -> String {
        return tag(SVGEllipseOpenTag, ["cx":att(ellipse.cx), "cy":att(ellipse.cy), "rx":att(ellipse.rx), "ry":att(ellipse.ry)])
    }
    
    fileprivate func circleToSVG(_ circle: Circle) -> String {
        return tag(SVGCircleOpenTag, ["cx":att(circle.cx), "cy":att(circle.cy), "r":att(circle.r)])
    }
    
    fileprivate func roundRectToSVG(_ roundRect: RoundRect) -> String {
        return tag(SVGRectOpenTag, ["rx":att(roundRect.rx), "ry":att(roundRect.ry), "width":att(roundRect.rect.w), "height":att(roundRect.rect.h)])
    }
    
    fileprivate func rectToSVG(_ rect: Rect) -> String {
        return tag(SVGRectOpenTag, ["x":att(rect.x), "y":att(rect.y), "width":att(rect.w), "height":att(rect.h)])
    }
    
    fileprivate func imageToSVG(_ image: Image) -> String {
        return tag(SVGImageOpenTag, ["xlink:href":image.src, "x":att(image.place.dx), "y":att(image.place.dy), "width":String(image.w), "height":String(image.h)], close: true)
    }

    fileprivate func textToSVG(_ text: Text) -> String {
        var result = tag(SVGTextOpenTag, ["x":att(text.place.dx), "y":att(text.place.dy)])
        if let font = text.font {
            result += " font-family=\"\(font.name)\" font-size=\"\(font.size)\" "
            // TODO: check with enums
            if font.name != "normal" {
                result += " font-weight=\"\(font.weight)\" "
            }
        }
        if (text.align == .mid) {
            result += " text-anchor=\"middle\" "
        } else if (text.align == .max) {
            result += " text-anchor=\"end"
        }
        result += fillToSVG(text.fillVar.value)
        result += strokeToSVG(text.strokeVar.value)
        result += SVGGenericEndTag
        result += text.text
        result += "</text>"
        return result
    }

    fileprivate func fillToSVG(_ fill: Fill?) -> String {
        if let fillColor = fill as? Color {
            if let fill = SVGConstants.valueToColor(fillColor.val) {
                return " fill=\"\(fill)\""
            } else {
                return " fill=\"#\(String(format:"%06X", fillColor.val))\""
            }
        }
        return " fill=\"none\""
    }
    
    fileprivate func strokeToSVG(_ stroke: Stroke?) -> String {
        var result = ""
        if let strokeColor = stroke?.fill as? Color {
            if let stroke = SVGConstants.valueToColor(strokeColor.val) {
                result += " stroke=\"\(stroke)\""
            } else {
                result += " stroke=\"#\(String(format:"%06X", strokeColor.val))\""
            }
        }
        if let strokeWidth = stroke?.width {
            result += " stroke-width=\"\(strokeWidth)\""
        }
        if let strokeCap = stroke?.cap {
            if strokeCap != SVGConstants.defaultStrokeLineCap {
                result += " stroke-linecap=\"\(strokeCap)\""
            }
        }
        if let strokeJoin = stroke?.join {
            if strokeJoin != SVGConstants.defaultStrokeLineJoin {
                result += " stroke-linejoin=\"\(strokeJoin)\""
            }
        }
        return result
    }
    
    fileprivate func macawShapeToSvgShape (macawShape: Shape) -> String {
        var result = ""
        let locus = macawShape.formVar.value
        switch locus {
        case let arc as Arc:
            result += arcToSVG(arc)
        case let polygon as Polygon:
            result += polygonToSVG(polygon)
        case let polyline as Polyline:
            result += polylineToSVG(polyline)
        case let path as Path:
            result += pathToSVG(path)
        case let line as Line:
            result += lineToSVG(line)
        case let ellipse as Ellipse:
            result += ellipseToSVG(ellipse)
        case let circle as Circle:
            result += circleToSVG(circle)
        case let roundRect as RoundRect:
            result += roundRectToSVG(roundRect)
        case let rect as Rect:
            result += rectToSVG(rect)
        default:
            result += "\(SVGUndefinedTag) locus:\(locus)"
        }
        result += fillToSVG(macawShape.fillVar.value)
        result += strokeToSVG(macawShape.strokeVar.value)
        
        result += SVGGenericCloseTag
        return result
    }
    
    
    fileprivate func serialize(node: Node, offset: Int) -> String {
        if let shape = node as? Shape {
            return indentTextWithOffset(macawShapeToSvgShape(macawShape: shape), offset)
        }
        if let group = node as? Group {
            var result = indentTextWithOffset(SVGGroupOpenTag, offset)
            if ([group.place.dx, group.place.dy].map{ Int($0) } != [0, 0]) {
                if ([group.place.m11, group.place.m12, group.place.m21, group.place.m22].map { Int($0) } == [1, 0, 0, 1]) {
                    result += " transform=\"translate(\(Int(group.place.dx)),\(Int(group.place.dy)))\""
                } else {
                    let matrixArgs = [group.place.m11, group.place.m12, group.place.m21, group.place.m22, group.place.dx, group.place.dy].map{ String($0) }.joined(separator: ",")
                    result += " transform=\"matrix(\(matrixArgs))\""
                }
            }
            result += SVGGenericEndTag
            for child in group.contentsVar.value {
                result += serialize(node: child, offset: offset + 1)
            }
            result += indentTextWithOffset(SVGGroupCloseTag, offset)
            return result
        }
        if let image = node as? Image {
            return imageToSVG(image)
        }
        if let text = node as? Text {
            return textToSVG(text)
        }
        return "SVGUndefinedTag \(node)"
    }
    
    fileprivate func serialize(node:Node) -> String {
        var optionalSection = ""
        if let w = width {
            optionalSection += "width=\"\(w)\""
        }
        if let h = height {
            optionalSection += "height=\"\(h)\""
        }
        if let i = id {
            optionalSection += "id=\"\(i)\""
        }
        var result = [SVGDefaultHeader, optionalSection, SVGGenericEndTag].joined(separator: " ")
        result += serialize(node: node, offset: 1)
        result += indentTextWithOffset(SVGFooter, 0)
        return result
    }
    
    open class func serialize(node: Node, width: Int? = nil, height: Int? = nil, id: String? = nil) -> String {
        return SVGSerializer(width: width, height:height, id: id).serialize(node: node)
    }

}
