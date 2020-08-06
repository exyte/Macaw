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

    fileprivate init(width: Int?, height: Int?, id: String?) {
        self.width = width
        self.height = height
        self.id = id
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
    fileprivate let SVGClipPathName = "clipPath"
    fileprivate let SVGMaskName = "mask"

    fileprivate let SVGEpsilon: Double = 0.00001
    fileprivate let SVGDefaultOpacityValueAsAlpha = 1 * 255

    fileprivate func tag(_ tag: String, _ args: [String: String]=[:], close: Bool = false) -> String {
        let attrs = args.sorted { a1, a2 -> Bool in a1.key < a2.key }
            .map { "\($0)=\"\($1)\"" }.joined(separator: " ")
        let closeTag = close ? " />" : ""
        return "\(tag) \(attrs) \(closeTag)"
    }

    fileprivate func arcToSVG(_ arc: Arc) -> String {
        if arc.shift == 0.0 && abs(arc.extent - .pi * 2.0) < SVGEpsilon {
            return tag(SVGEllipseOpenTag, ["cx": arc.ellipse.cx.serialize(), "cy": arc.ellipse.cy.serialize(), "rx": arc.ellipse.rx.serialize(), "ry": arc.ellipse.ry.serialize()])
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
            d += "\(segment.type) \(segment.data.compactMap { $0.serialize() }.joined(separator: " "))"
        }
        return tag(SVGPathOpenTag, ["d": d])
    }

    fileprivate func lineToSVG(_ line: Line) -> String {
        return tag(SVGLineOpenTag, ["x1": line.x1.serialize(), "y1": line.y1.serialize(), "x2": line.x2.serialize(), "y2": line.y2.serialize()])
    }

    fileprivate func ellipseToSVG(_ ellipse: Ellipse) -> String {
        return tag(SVGEllipseOpenTag, ["cx": ellipse.cx.serialize(), "cy": ellipse.cy.serialize(), "rx": ellipse.rx.serialize(), "ry": ellipse.ry.serialize()])
    }

    fileprivate func circleToSVG(_ circle: Circle) -> String {
        return tag(SVGCircleOpenTag, ["cx": circle.cx.serialize(), "cy": circle.cy.serialize(), "r": circle.r.serialize()])
    }

    fileprivate func roundRectToSVG(_ roundRect: RoundRect) -> String {
        return tag(SVGRectOpenTag, ["x": roundRect.rect.x.serialize(), "y": roundRect.rect.y.serialize(), "width": roundRect.rect.w.serialize(), "height": roundRect.rect.h.serialize(), "rx": roundRect.rx.serialize(), "ry": roundRect.ry.serialize()])
    }

    fileprivate func rectToSVG(_ rect: Rect) -> String {
        return tag(SVGRectOpenTag, ["x": rect.x.serialize(), "y": rect.y.serialize(), "width": rect.w.serialize(), "height": rect.h.serialize()])
    }

    fileprivate func imageToSVG(_ image: Image) -> String {
        var result = tag(SVGImageOpenTag, close: false)
        result += idToSVG(image.tag)
        result += clipToSVG(image.clip)
        result += transformToSVG(image.place)
        if image.src.contains("memory://") {
            if let data = image.base64encoded(type: Image.ImageRepresentationType.PNG) {
                result += " xlink:href=\"data:image/png;base64,\(data)\""
            }
        } else {
            result += " xlink:href=\"\(image.src)\" "
        }
        if let bounds = image.bounds {
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
        result += idToSVG(text.tag)
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
        result += transformToSVG(text.place)
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

    fileprivate func transformToSVG(_ place: Transform) -> String {
        if [place.m11, place.m12, place.m21, place.m22] == [1.0, 0.0, 0.0, 1.0] {
            if [place.dx, place.dy] == [0.0, 0.0] {
                return ""
            }
            return " transform=\"translate(\(place.dx.serialize()),\(place.dy.serialize()))\" "
        }
        let matrixArgs = [place.m11, place.m12, place.m21, place.m22, place.dx, place.dy].map { $0.serialize() }.joined(separator: ",")
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
        case let transformedLocus as TransformedLocus:
            return locusToSVG(transformedLocus.locus) + transformToSVG(transformedLocus.transform)
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
        defs += "<\(SVGClipPathName) id=\"\(SVGClipPathName)\(clipPathCount)\">" + locusToSVG(clip) + SVGGenericCloseTag + "</\(SVGClipPathName)>"
    }

    fileprivate var maskCount: Int = 0

    fileprivate func addMaskToDefs(_ mask: Node) {
        maskCount += 1
        defs += "<\(SVGMaskName) id=\"\(SVGMaskName)\(maskCount)\">" + serialize(node: mask) + SVGGenericCloseTag + "</\(SVGMaskName)>"
    }

    fileprivate func idToSVG(_ tag: [String]) -> String {
        guard !tag.isEmpty, let id = tag.first else {
            return ""
        }
        return " id=\"\(id)\""
    }

    fileprivate func clipToSVG(_ clipLocus: Locus?) -> String {
        guard let clip = clipLocus else {
            return ""
        }
        addClipToDefs(clip)
        return " clip-path=\"url(#\(SVGClipPathName)\(clipPathCount))\" "
    }

    fileprivate func maskToSVG(_ mask: Node?) -> String {
        guard let mask = mask else {
            return ""
        }
        addMaskToDefs(mask)
        return " mask=\"url(#\(SVGMaskName)\(maskCount))\" "
    }

    fileprivate func macawShapeToSvgShape (macawShape: Shape) -> String {
        let locus = macawShape.formVar.value
        var result = locusToSVG(locus)
        result += idToSVG(macawShape.tag)
        result += clipToSVG(macawShape.clip)
        result += maskToSVG(macawShape.mask)
        result += fillToSVG(macawShape.fillVar.value)
        result += strokeToSVG(macawShape.strokeVar.value)
        result += transformToSVG(macawShape.place)
        result += SVGGenericCloseTag
        return result
    }

    fileprivate func serialize(node: Node) -> String {
        if let shape = node as? Shape {
            return macawShapeToSvgShape(macawShape: shape)
        }
        if let group = node as? Group {
            var result = SVGGroupOpenTag
            result += idToSVG(group.tag)
            result += clipToSVG(group.clip)
            result += transformToSVG(group.place)
            result += SVGGenericEndTag
            for child in group.contentsVar.value {
                result += serialize(node: child)
            }
            result += SVGGroupCloseTag
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

    fileprivate func serializeRootNode(node: Node) -> String {
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
        let body = serialize(node: node)
        result += getDefs() + body
        result += SVGFooter
        return result
    }

    open class func serialize(node: Node, width: Int? = nil, height: Int? = nil, id: String? = nil) -> String {
        return SVGSerializer(width: width, height: height, id: id).serializeRootNode(node: node)
    }

}

extension Double {
    func serialize() -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 6
        formatter.decimalSeparator = "."
        return abs(self.remainder(dividingBy: 1)) > 0.00001 ? formatter.string(from: NSNumber(value: self))! : String(Int(self.rounded()))
    }
}
