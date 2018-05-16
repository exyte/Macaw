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
    fileprivate let SVGClipPathName = "clipPath"

    fileprivate let SVGEpsilon: Double = 0.00001
    fileprivate let SVGDefaultOpacityValueAsAlpha = 1 * 255

    fileprivate func indentTextWithOffset(_ text: String, _ offset: Int) -> String {
        if self.indent != 0 {
            let prefix = String(repeating: indentPrefixSymbol, count: self.indent)
            return "\n\(String(repeating: prefix, count: offset))\(text)"
        }
        return text
    }

    fileprivate func att(_ a: Double) -> String {
        return String(Int(a))
    }

    fileprivate func tag(_ tag: String, _ args: [String: String]=[:], close: Bool = false) -> String {
        let attrs = args.map { "\($0)=\"\($1)\"" }.joined(separator: " ")
        let closeTag = close ? " />" : ""
        return "\(tag) \(attrs) \(closeTag)"
    }

    fileprivate func arcToSVG(_ arc: Arc) -> String {
        if arc.shift == 0.0 && abs(arc.extent - .pi * 2.0) < SVGEpsilon {
            return tag(SVGEllipseOpenTag, ["cx": att(arc.ellipse.cx), "cy": att(arc.ellipse.cy), "rx": att(arc.ellipse.rx), "ry": att(arc.ellipse.ry)])
        } else {
            let rx = arc.ellipse.rx
            let ry = arc.ellipse.ry
            let cx = arc.ellipse.cx
            let cy = arc.ellipse.cy

            let theta1 = arc.shift
            let delta = arc.extent
            let theta2 = theta1 + delta

            let x1 = cx + rx * cos(theta1)
            let y1 = cy + ry * sin(theta1)

            let x2 = cx + rx * cos(theta2)
            let y2 = cy + ry * sin(theta2)

            let largeArcFlag = abs(delta) > .pi ? 1 : 0
            let sweepFlag = delta > 0.0 ? 1 : 0

            var d = "M\(x1),\(y1) "
            d += "A \(rx),\(ry) 0.0 \(largeArcFlag), \(sweepFlag) \(x2),\(y2)"
            return tag(SVGPathOpenTag, ["d": d])
        }
    }

    fileprivate func polygonToSVG(_ polygon: Polygon) -> String {
        let points = polygon.points.compactMap { String($0) }.joined(separator: ",")
        return tag(SVGPolygonOpenTag, ["points": points])
    }

    fileprivate func polylineToSVG(_ polyline: Polyline) -> String {
        let points = polyline.points.compactMap { String($0) }.joined(separator: ",")
        return tag(SVGPolylineOpenTag, ["points": points])
    }

    fileprivate func pathToSVG(_ path: Path) -> String {
        var d = ""
        for segment in path.segments {
            d += "\(segment.type) \(segment.data.compactMap { String(Int($0)) }.joined(separator: " "))"
        }
        return tag(SVGPathOpenTag, ["d": d])
    }

    fileprivate func lineToSVG(_ line: Line) -> String {
        return tag(SVGLineOpenTag, ["x1": String(Int(line.x1)), "y1": att(line.y1), "x2": att(line.x2), "y2": att(line.y2)])
    }

    fileprivate func ellipseToSVG(_ ellipse: Ellipse) -> String {
        return tag(SVGEllipseOpenTag, ["cx": att(ellipse.cx), "cy": att(ellipse.cy), "rx": att(ellipse.rx), "ry": att(ellipse.ry)])
    }

    fileprivate func circleToSVG(_ circle: Circle) -> String {
        return tag(SVGCircleOpenTag, ["cx": att(circle.cx), "cy": att(circle.cy), "r": att(circle.r)])
    }

    fileprivate func roundRectToSVG(_ roundRect: RoundRect) -> String {
        return tag(SVGRectOpenTag, ["rx": att(roundRect.rx), "ry": att(roundRect.ry), "width": att(roundRect.rect.w), "height": att(roundRect.rect.h)])
    }

    fileprivate func rectToSVG(_ rect: Rect) -> String {
        return tag(SVGRectOpenTag, ["x": att(rect.x), "y": att(rect.y), "width": att(rect.w), "height": att(rect.h)])
    }

    fileprivate func imageToSVG(_ image: Image) -> String {
        var result = tag(SVGImageOpenTag, close: false)
        result += clipToSVG(image.clip)
        result += transformToSVG(image)
        if image.src.contains("memory://") {
            if let data = image.base64encoded(type: Image.ImageRepresentationType.PNG) {
                result += " xlink:href=\"data:image/png;base64,\(data)\""
            }
        } else {
            result += " xlink:href=\"\(image.src)\" "
        }
        if let bounds = image.bounds() {
            result += " width=\"\(String(bounds.w))\" height=\"\(String(bounds.h))\" "
        }
        result += SVGGenericCloseTag
        return result
    }

    fileprivate func alignToSVG(_ align: Align) -> String {
        if align === Align.mid {
            return " text-anchor=\"middle\" "
        }
        if align === Align.max {
            return " text-anchor=\"end "
        }
        return ""
    }

    fileprivate func baselineToSVG(_ baseline: Baseline) -> String {
        if baseline == .top {
            return " dominant-baseline=\"text-before-edge\" "
        }
        return ""
    }

    fileprivate func textToSVG(_ text: Text) -> String {
        var result = tag(SVGTextOpenTag)
        if let font = text.font {
            result += " font-family=\"\(font.name)\" font-size=\"\(font.size)\" "
            // TODO: check with enums
            if font.name != "normal" {
                result += " font-weight=\"\(font.weight)\" "
            }
        }

        result += alignToSVG(text.align)
        result += baselineToSVG(text.baseline)
        result += clipToSVG(text.clip)
        result += fillToSVG(text.fillVar.value)
        result += strokeToSVG(text.strokeVar.value)
        result += transformToSVG(text)
        result += SVGGenericEndTag
        result += text.text
        result += "</text>"
        return result
    }

    fileprivate func colorToSVG(_ color: Color) -> String {
        if let c = SVGConstants.valueToColor(color.val) {
            return "\(c)"
        } else {
            let r = color.r()
            let g = color.g()
            let b = color.b()
            return "#\(String(format: "%02X%02X%02X", r, g, b))"
        }
    }

    fileprivate func fillToSVG(_ fill: Fill?) -> String {
        if let fillColor = fill as? Color {
            var result = " fill=\"\(colorToSVG(fillColor))\""
            if let opacity = alphaToSVGOpacity(fillColor.a()) {
                result += " fill-opacity=\"\(opacity)\""
            }
            return result
        }
        return " fill=\"none\""
    }

    fileprivate func alphaToSVGOpacity(_ alpha: Int) -> String? {
        if alpha == SVGDefaultOpacityValueAsAlpha {
            return .none
        }
        return String(Double(alpha) / Double(SVGDefaultOpacityValueAsAlpha))
    }

    fileprivate func strokeToSVG(_ stroke: Stroke?) -> String {
        var result = ""
        if let strokeColor = stroke?.fill as? Color {
            result += " stroke=\"\(colorToSVG(strokeColor))\""
            if let opacity = alphaToSVGOpacity(strokeColor.a()) {
                result += " stroke-opacity=\"\(opacity)\""
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
        if let strokeDashes = stroke?.dashes, !strokeDashes.isEmpty {
            let dashes = strokeDashes.map { String($0) }.joined(separator: ",")
            result += " stroke-dasharray=\"\(dashes)\""
        }
        if let strokeOffset = stroke?.offset {
            if strokeOffset != 0 {
                result += " stroke-dashoffset=\"\(strokeOffset)\""
            }
        }
        return result
    }

    fileprivate func isSignificantMatrixTransform(_ t: Transform) -> Bool {
        for k in [t.m11, t.m12, t.m21, t.m22, t.dx, t.dy] {
            if abs(k) > SVGEpsilon {
                return true
            }
        }
        return false
    }

    fileprivate func transformToSVG(_ shape: Node) -> String {
        if [shape.place.m11, shape.place.m12, shape.place.m21, shape.place.m22] == [1.0, 0.0, 0.0, 1.0] {
            if ([shape.place.dx, shape.place.dy] == [0.0, 0.0]) {
                return ""
            }
            return " transform=\"translate(\(Int(shape.place.dx)),\(Int(shape.place.dy)))\" "
        }
        let matrixArgs = [shape.place.m11, shape.place.m12, shape.place.m21, shape.place.m22, shape.place.dx, shape.place.dy].map { String($0) }.joined(separator: ",")
        return " transform=\"matrix(\(matrixArgs))\" "
    }

    fileprivate func locusToSVG(_ locus: Locus) -> String {
        switch locus {
        case let arc as Arc:
            return arcToSVG(arc)
        case let polygon as Polygon:
            return polygonToSVG(polygon)
        case let polyline as Polyline:
            return polylineToSVG(polyline)
        case let path as Path:
            return pathToSVG(path)
        case let line as Line:
            return lineToSVG(line)
        case let ellipse as Ellipse:
            return ellipseToSVG(ellipse)
        case let circle as Circle:
            return circleToSVG(circle)
        case let roundRect as RoundRect:
            return roundRectToSVG(roundRect)
        case let rect as Rect:
            return rectToSVG(rect)
        default:
            return "\(SVGUndefinedTag) locus:\(locus)"
        }
    }

    fileprivate var defs: String = ""

    fileprivate func getDefs() -> String {
        if defs.isEmpty {
            return ""
        }
        return "<defs>" + defs + "</defs>"
    }

    fileprivate var clipPathCount: Int = 0

    fileprivate func addClipToDefs(_ clip: Locus) {
        clipPathCount += 1
        defs += "<clipPath id=\"\(SVGClipPathName)\(clipPathCount)\">" + locusToSVG(clip) + SVGGenericCloseTag + "</clipPath>"
    }

    fileprivate func clipToSVG(_ clipLocus: Locus?) -> String {
        guard let clip = clipLocus else {
            return ""
        }
        addClipToDefs(clip)
        return " clip-path=\"url(#\(SVGClipPathName)\(clipPathCount))\" "
    }

    fileprivate func macawShapeToSvgShape (macawShape: Shape) -> String {
        let locus = macawShape.formVar.value
        var result = locusToSVG(locus)
        result += clipToSVG(macawShape.clip)
        result += fillToSVG(macawShape.fillVar.value)
        result += strokeToSVG(macawShape.strokeVar.value)
        result += transformToSVG(macawShape)
        result += SVGGenericCloseTag
        return result
    }

    fileprivate func serialize(node: Node, offset: Int) -> String {
        if let shape = node as? Shape {
            return indentTextWithOffset(macawShapeToSvgShape(macawShape: shape), offset)
        }
        if let group = node as? Group {
            var result = indentTextWithOffset(SVGGroupOpenTag, offset)
            result += clipToSVG(group.clip)
            result += transformToSVG(group)
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

    fileprivate func serialize(node: Node) -> String {
        var optionalSection = ""
        if let w = width {
            optionalSection += "width=\"\(w)\""
        }
        if let h = height {
            optionalSection += " height=\"\(h)\""
        }
        if let i = id {
            optionalSection += " id=\"\(i)\""
        }
        var result = [SVGDefaultHeader, optionalSection, SVGGenericEndTag].joined(separator: " ")
        let body = serialize(node: node, offset: 1)
        result += getDefs() + body
        result += indentTextWithOffset(SVGFooter, 0)
        return result
    }

    open class func serialize(node: Node, width: Int? = nil, height: Int? = nil, id: String? = nil) -> String {
        return SVGSerializer(width: width, height: height, id: id).serialize(node: node)
    }

}
