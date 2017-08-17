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
    
    fileprivate let width: Int
    fileprivate let height: Int
    fileprivate let id: String
    fileprivate let indent: Int
    
    fileprivate init(width: Int, height: Int, id: String, indent: Int) {
        self.width = width
        self.height = height
        self.id = id
        self.indent = indent
    }
    
    fileprivate init(indent:Int) {
        self.width = SVGDefaultWidth
        self.height = SVGDefaultHeight
        self.id = SVGDefaultId
        self.indent = indent
    }

    fileprivate init() {
        self.width = SVGDefaultWidth
        self.height = SVGDefaultHeight
        self.id = SVGDefaultId
        self.indent = 1
    }

    // header and footer
    fileprivate let SVGDefaultHeader = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\""
    fileprivate let SVGDefaultId = ""
    fileprivate let SVGDefaultWidth=400
    fileprivate let SVGDefaultHeight=210
    fileprivate let SVGFooter = "</svg>"
    
    // groups
    fileprivate let SVGGroupOpenTag = "<g>"
    fileprivate let SVGGroupCloseTag = "</g>"
    
    // shapes
    fileprivate let SVGRectOpenTag = "<rect "
    fileprivate let SVGCircleOpenTag = "<circle "
    fileprivate let SVGEllipseOpenTag = "<ellipse "
    fileprivate let SVGLineOpenTag = "<line "
    fileprivate let SVGPolylineOpenTag = "<polyline "
    fileprivate let SVGPolygonOpenTag = "<polygon "
    fileprivate let SVGPathOpenTag = "<path "
    fileprivate let SVGGenericEndTag = ">"
    fileprivate let SVGGenericCloseTag = "/>"
    
    fileprivate let SVGUndefinedTag = "<UNDEFINED "
    fileprivate let indentPrefixSymbol = " "
    
    
    fileprivate func indentTextWithOffset(text: String, offset: Int) -> String {
        if self.indent != 0 {
            let prefix = String(repeating: indentPrefixSymbol, count:self.indent)
            return "\n\(String(repeating: prefix, count:offset))\(text)"
        }
        return text
    }
    
    fileprivate func att(_ a: Double) -> String {
        return String(Int(a))
    }
    
    fileprivate func tag(_ tag: String, _ args: [String:String]) -> String {
        let attrs = args.map { "\($0)=\"\($1)\"" }.joined(separator: " ")
        return "\(tag) \(attrs)"
    }
    
    fileprivate func arcToSVG(_ arc: Macaw.Arc) -> String {
        if (arc.shift == 0.0) {
            return tag(SVGEllipseOpenTag, ["cx":att(arc.ellipse.cx), "cy":att(arc.ellipse.cy), "rx":att(arc.ellipse.rx), "ry":att(arc.ellipse.ry)])
        } else {
            // Convert arc to SVG format with x axis rotation, arc flag, and sweep flag
            return SVGUndefinedTag
        }
    }
    
    
    fileprivate func polygonToSVG(_ polygon: Macaw.Polygon) -> String {
        let points = polygon.points.flatMap { String($0) }.joined(separator: ",")
        return tag(SVGPolygonOpenTag, ["points":points])
    }
    
    fileprivate func polylineToSVG(_ polyline: Macaw.Polyline) -> String {
        let points = polyline.points.flatMap { String($0) }.joined(separator: ",")
        return tag(SVGPolylineOpenTag, ["points":points])
    }
    
    fileprivate func pathToSVG(_ path: Macaw.Path) -> String {
        var d = ""
        for segment in path.segments {
            d += "\(segment.type) \(segment.data.flatMap { String(Int($0)) }.joined(separator: " "))"
        }
        return tag(SVGPathOpenTag, ["d":d])
    }
    
    fileprivate func lineToSVG(_ line: Macaw.Line) -> String {
        return tag(SVGLineOpenTag, ["x1":String(Int(line.x1)), "y1":att(line.y1), "x2":att(line.x2), "y2":att(line.y2)])
    }
    
    fileprivate func ellipseToSVG(_ ellipse: Macaw.Ellipse) -> String {
        return tag(SVGEllipseOpenTag, ["cx":att(ellipse.cx), "cy":att(ellipse.cy), "rx":att(ellipse.rx), "ry":att(ellipse.ry)])
    }
    
    fileprivate func circleToSVG(_ circle: Macaw.Circle) -> String {
        return tag(SVGCircleOpenTag, ["cx":att(circle.cx), "cy":att(circle.cy), "r":att(circle.r)])
    }
    
    fileprivate func roundRectToSVG(_ roundRect: Macaw.RoundRect) -> String {
        return tag(SVGRectOpenTag, ["rx":att(roundRect.rx), "ry":att(roundRect.ry), "width":att(roundRect.rect.w), "height":att(roundRect.rect.h)])
    }
    
    fileprivate func rectToSVG(_ rect: Macaw.Rect) -> String {
        return tag(SVGRectOpenTag, ["x":att(rect.x), "y":att(rect.y), "width":att(rect.w), "height":att(rect.h)])
    }
    
    fileprivate func fillToSVG(_ shape: Shape) -> String {
        if let fillColor = shape.fillVar.value as? Color {
            if let fill = SVGConstants.valueToColor(fillColor.val) {
                return " fill=\"\(fill)\""
            } else {
                return " fill=\"#\(String(format:"%6X", fillColor.val))\""
            }
        }
        return " fill=\"none\""
    }
    
    fileprivate func strokeToSVG(_ shape: Shape) -> String {
        var result = ""
        if let strokeColor = shape.strokeVar.value?.fill as? Color {
            if let stroke = SVGConstants.valueToColor(strokeColor.val) {
                result += " stroke=\"\(stroke)\""
            } else {
                result += " stroke=\"#\(String(format:"%6X", strokeColor.val))\""
            }
        }
        if let strokeWidth = shape.strokeVar.value?.width {
            result += " stroke-width=\"\(Int(strokeWidth))\""
        }
        if let strokeCap = shape.strokeVar.value?.cap {
            if strokeCap != SVGConstants.defaultStrokeLineCap {
                result += " stroke-linecap=\"\(strokeCap)\""
            }
        }
        if let strokeJoin = shape.strokeVar.value?.join {
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
        case let arc as Macaw.Arc:
            result += arcToSVG(arc)
        case let polygon as Macaw.Polygon:
            result += polygonToSVG(polygon)
        case let polyline as Macaw.Polyline:
            result += polylineToSVG(polyline)
        case let path as Macaw.Path:
            result += pathToSVG(path)
        case let line as Macaw.Line:
            result += lineToSVG(line)
        case let ellipse as Macaw.Ellipse:
            result += ellipseToSVG(ellipse)
        case let circle as Macaw.Circle:
            result += circleToSVG(circle)
        case let roundRect as Macaw.RoundRect:
            result += roundRectToSVG(roundRect)
        case let rect as Macaw.Rect:
            result += rectToSVG(rect)
        default:
            result += SVGUndefinedTag
        }
        result += fillToSVG(macawShape)
        result += strokeToSVG(macawShape)
        
        result += SVGGenericCloseTag
        return result
    }
    
    
    fileprivate func serialize(node: Node, offset: Int) -> String {
        if let shape = node as? Shape {
            return indentTextWithOffset(text: macawShapeToSvgShape(macawShape: shape), offset: offset)
        }
        if let group = node as? Group {
            var result = indentTextWithOffset(text: SVGGroupOpenTag, offset: offset)
            for child in group.contentsVar.value {
                result += serialize(node: child, offset: offset + 1)
            }
            result += indentTextWithOffset(text: SVGGroupCloseTag, offset: offset)
            return result
        }
        return SVGUndefinedTag
    }
    
    fileprivate func serialize(node:Node) -> String {
        var result = [SVGDefaultHeader, "id=\"\(self.id)\"", "width=\"\(self.width)\"", "height=\"\(self.height)\"", SVGGenericEndTag].joined(separator: " ")
        result += serialize(node: node, offset: 1)
        result += indentTextWithOffset(text: SVGFooter, offset: 0)
        return result
    }
    
    open class func serialize(node: Node, indent: Int = 1) -> String {
        return SVGSerializer(indent:indent).serialize(node: node)
    }
    
}
