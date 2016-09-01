import Foundation
import SWXMLHash
import CoreGraphics

///
/// This class used to parse SVG file and build corresponding Macaw scene
///
public class SVGParser {

    /// Parse an SVG file identified by the specified name and file extension.
    /// - returns: Root node of the corresponding Macaw scene.
    public class func parse(path path: String, ofType: String = "svg") -> Node {
        let path = NSBundle.mainBundle().pathForResource(path, ofType: ofType)
        let text = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        return SVGParser.parse(text: text)
    }

    /// Parse the specified content of an SVG file.
    /// - returns: Root node of the corresponding Macaw scene.
    public class func parse(text text: String) -> Node {
        return SVGParser(text).parse()
    }

    let moveToAbsolute = Character("M")
    let moveToRelative = Character("m")
    let lineToAbsolute = Character("L")
    let lineToRelative = Character("l")
    let lineHorizontalAbsolute = Character("H")
    let lineHorizontalRelative = Character("h")
    let lineVerticalAbsolute = Character("V")
    let lineVerticalRelative = Character("v")
    let curveToAbsolute = Character("C")
    let curveToRelative = Character("c")
    let smoothCurveToAbsolute = Character("S")
    let smoothCurveToRelative = Character("s")
    let closePathAbsolute = Character("Z")
    let closePathRelative = Character("z")
    let availableStyleAttributes = ["stroke", "stroke-width", "stroke-opacity", "stroke-dasharray", "stroke-linecap", "stroke-linejoin",
                                    "fill", "fill-opacity", "stop-color",
                                    "font-family", "font-size",
                                    "opacity"]

    private let xmlString: String
    private let initialPosition: Transform

    private var nodes = [Node]()
    private var defNodes = [String : Node]()
    private var defFills = [String: Fill]()

    private enum PathCommandType {
        case MoveTo
        case LineTo
        case LineV
        case LineH
        case CurveTo
        case SmoothCurveTo
        case ClosePath
        case None
    }

    private typealias PathCommand = (type: PathCommandType, expression: String, absolute: Bool)

    private init(_ string: String, pos: Transform = Transform()) {
        self.xmlString = string
        self.initialPosition = pos
    }

    private func parse() -> Group {
        let parsedXml = SWXMLHash.parse(xmlString)
        iterateThroughXmlTree(parsedXml.children)

        let group = Group(contents: self.nodes, place: initialPosition)
        return group
    }

    private func iterateThroughXmlTree(children: [XMLIndexer]) {
        children.forEach { child in
            if let element = child.element {
                if element.name == "svg" {
                    iterateThroughXmlTree(child.children)
                } else if let node = parseNode(child) {
                    self.nodes.append(node)
                }
            }
        }
    }

    private func parseNode(node: XMLIndexer, groupStyle: [String: String] = [:]) -> Node? {
        if let element = node.element {
            if element.name == "g" {
                return parseGroup(node, groupStyle: groupStyle)
            } else if element.name == "defs" {
                parseDefinitions(node)
            } else {
                return parseElement(node, groupStyle: groupStyle)
            }
        }
        return .None
    }
    
    private func parseDefinitions(defs: XMLIndexer) {
        for child in defs.children {
            guard let id = child.element?.attributes["id"] else {
                continue
            }
            if let node = parseNode(child) {
                self.defNodes[id] = node
                continue
            }
            if let fill = parseFill(child) {
                self.defFills[id] = fill
            }
        }
    }

    private func parseElement(node: XMLIndexer, groupStyle: [String: String] = [:]) -> Node? {
        if let element = node.element {
            let styleAttributes = getStyleAttributes(groupStyle, element: element)
            let position = getPosition(element)
            switch element.name {
            case "path":
                if let path = parsePath(node) {
                    return Shape(form: path, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes))
                }
            case "line":
                if let line = parseLine(node) {
                    return Shape(form: line, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position,opacity: getOpacity(styleAttributes))
                }
            case "rect":
                if let rect = parseRect(node) {
                    return Shape(form: rect, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position,opacity: getOpacity(styleAttributes))
                }
            case "circle":
                if let circle = parseCircle(node) {
                    return Shape(form: circle, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position,opacity: getOpacity(styleAttributes))
                }
            case "ellipse":
                if let ellipse = parseEllipse(node) {
                    return Shape(form: ellipse, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes))
                }
            case "polygon":
                if let polygon = parsePolygon(node) {
                    return Shape(form: polygon, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes))
                }
            case "polyline":
                if let polyline = parsePolyline(node) {
                    return Shape(form: polyline, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes))
                }
            case "image":
                return parseImage(node, opacity: getOpacity(styleAttributes), pos: position)
            case "text":
                return parseText(node, fill: getFillColor(styleAttributes), opacity: getOpacity(styleAttributes), fontName: getFontName(styleAttributes), fontSize: getFontSize(styleAttributes), pos: position)
            case "use":
                return parseUse(node, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), pos: position)
            default:
                print("SVG parsing error. Shape \(element.name) not supported")
                return .None
            }
        }
        return .None
    }
    
    private func parseFill(fill: XMLIndexer) -> Fill? {
        guard let element = fill.element else {
            return .None
        }
        switch element.name {
        case "linearGradient":
            return parseLinearGradient(fill)
        case "radialGradient":
            return parseRadialGradient(fill)
        default:
            return .None
        }
    }

    private func parseGroup(group: XMLIndexer, groupStyle: [String: String] = [:]) -> Group? {
        guard let element = group.element else {
            return .None
        }
        var groupNodes: [Node] = []
        let style = getStyleAttributes(groupStyle, element: element)
        let position = getPosition(element)
        group.children.forEach { child in
            if let node = parseNode(child, groupStyle: style) {
                groupNodes.append(node)
            }
        }
        return Group(contents: groupNodes, place: position)
    }
    
    private func getPosition(element: XMLElement) -> Transform {
        guard let transformAttribute = element.attributes["transform"] else {
            return Transform()
        }
        return parseTransformationAttribute(transformAttribute)
    }
    
    private func parseTransformationAttribute(attributes: String, transform: Transform = Transform()) -> Transform {
        guard let matcher = SVGParserRegexHelper.getTransformAttributeMatcher() else {
            return transform
        }
        var finalTransform = transform
        let fullRange = NSRange(location: 0, length: attributes.characters.count)
        if let matchedAttribute = matcher.firstMatchInString(attributes, options: .ReportCompletion, range: fullRange) {
            let attributeName = (attributes as NSString).substringWithRange(matchedAttribute.rangeAtIndex(1))
            let values = parseTransformValues((attributes as NSString).substringWithRange(matchedAttribute.rangeAtIndex(2)))
            if values.isEmpty {
                return transform
            }
            switch attributeName {
            case "translate":
                if let x = Double(values[0]) {
                    var y: Double = 0
                    if values.indices.contains(1) {
                        y = Double(values[1]) ?? 0
                    }
                    finalTransform = transform.move(dx: x, dy: y)
                }
            case "scale":
                if let x = Double(values[0]) {
                    var y: Double = x
                    if values.indices.contains(1) {
                        y = Double(values[1]) ?? x
                    }
                    finalTransform = transform.scale(sx: x, sy: y)
                }
            case "rotate":
                if let angle = Double(values[0]) {
                    if values.count == 1 {
                        finalTransform = transform.rotate(angle: angle)
                    } else if values.count == 3 {
                        if let x = Double(values[1]), y = Double(values[2]) {
                            finalTransform = transform.move(dx: x, dy: y).rotate(angle: angle).move(dx: -x, dy: -y)
                        }
                    }
                }
            case "skewX":
                if let x = Double(values[0]) {
                    finalTransform = transform.shear(shx: x, shy: 0)
                }
            case "skewY":
                if let y = Double(values[0]) {
                    finalTransform = transform.shear(shx: 0, shy: y)
                }
            case "matrix":
                if values.count != 6 {
                    return transform
                }
                if let m11 = Double(values[0]), m12 = Double(values[1]),
                    m21 = Double(values[2]), m22 = Double(values[3]),
                    dx = Double(values[4]), dy = Double(values[5]) {
                    
                    let transformMatrix = Transform(m11: m11, m12: m12, m21: m21, m22: m22, dx: dx, dy: dy)
                    finalTransform = GeomUtils.concat(t1: transform, t2: transformMatrix)
                }
            default: break
            }
            let rangeToRemove = NSRange(location: 0, length: matchedAttribute.range.location + matchedAttribute.range.length)
            let newAttributeString = (attributes as NSString).stringByReplacingCharactersInRange(rangeToRemove, withString: "")
            return parseTransformationAttribute(newAttributeString, transform: finalTransform)
        } else {
            return transform
        }
    }
    
    private func parseTransformValues(values: String, collectedValues: [String] = []) -> [String] {
        guard let matcher = SVGParserRegexHelper.getTransformMatcher() else {
            return collectedValues
        }
        var updatedValues: [String] = collectedValues
        let fullRange = NSRange(location: 0, length: values.characters.count)
        if let matchedValue = matcher.firstMatchInString(values, options: .ReportCompletion, range: fullRange) {
            let value = (values as NSString).substringWithRange(matchedValue.range)
            updatedValues.append(value)
            let rangeToRemove = NSRange(location: 0, length: matchedValue.range.location + matchedValue.range.length)
            let newValues = (values as NSString).stringByReplacingCharactersInRange(rangeToRemove, withString: "")
            return parseTransformValues(newValues, collectedValues: updatedValues)
        }
        return updatedValues
    }

    private func getStyleAttributes(groupAttributes: [String: String], element: XMLElement) -> [String: String] {
        var styleAttributes: [String: String] = groupAttributes
        if let style = element.attributes["style"] {
            let styleParts = style.stringByReplacingOccurrencesOfString(" ", withString: "").componentsSeparatedByString(";")
            styleParts.forEach { styleAttribute in
                let currentStyle = styleAttribute.componentsSeparatedByString(":")
                if currentStyle.count == 2 {
                    styleAttributes.updateValue(currentStyle[1], forKey: currentStyle[0])
                }
            }
        } else {
            self.availableStyleAttributes.forEach { availableAttribute in
                if let styleAttribute = element.attributes[availableAttribute] {
                    styleAttributes.updateValue(styleAttribute, forKey: availableAttribute)
                }
            }
        }
        return styleAttributes
    }

    private func createColor(hexString: String, opacity: Double = 1) -> Color {
        var cleanedHexString = hexString
        if hexString.hasPrefix("#") {
            cleanedHexString = hexString.stringByReplacingOccurrencesOfString("#", withString: "")
        }

        var rgbValue: UInt32 = 0
        NSScanner(string: cleanedHexString).scanHexInt(&rgbValue)

        let red = CGFloat((rgbValue >> 16) & 0xff)
        let green = CGFloat((rgbValue >> 08) & 0xff)
        let blue = CGFloat((rgbValue >> 00) & 0xff)
        
        return Color.rgba(r: Int(red), g: Int(green), b: Int(blue), a: opacity)
    }

    private func getFillColor(styleParts: [String: String]) -> Fill? {
        guard let fillColor = styleParts["fill"] else {
            return .None
        }
        var opacity: Double = 1
        if let fillOpacity = styleParts["fill-opacity"] {
            opacity = Double(fillOpacity.stringByReplacingOccurrencesOfString(" ", withString: "")) ?? 1
        }
        if fillColor.hasPrefix("url") {
            let index = fillColor.startIndex.advancedBy(4)
            let id = fillColor.substringFromIndex(index)
                .stringByReplacingOccurrencesOfString("(", withString: "")
                .stringByReplacingOccurrencesOfString(")", withString: "")
                .stringByReplacingOccurrencesOfString("#", withString: "")
            return defFills[id]
        } else {
            return createColor(fillColor.stringByReplacingOccurrencesOfString(" ", withString: ""), opacity: opacity)
        }
    }

    private func getStroke(styleParts: [String: String]) -> Stroke? {
        guard let strokeColor = styleParts["stroke"] else {
            return .None
        }
        if strokeColor == "none" {
            return .None
        }
        var opacity: Double = 1
        if let strokeOpacity = styleParts["stroke-opacity"] {
            opacity = Double(strokeOpacity.stringByReplacingOccurrencesOfString(" ", withString: "")) ?? 1
        }
        var fill: Fill?
        if strokeColor.hasPrefix("url") {
            let index = strokeColor.startIndex.advancedBy(4)
            let id = strokeColor.substringFromIndex(index)
                .stringByReplacingOccurrencesOfString("(", withString: "")
                .stringByReplacingOccurrencesOfString(")", withString: "")
                .stringByReplacingOccurrencesOfString("#", withString: "")
            fill = defFills[id]
        } else {
            fill = createColor(strokeColor.stringByReplacingOccurrencesOfString(" ", withString: ""), opacity: opacity)
        }
        
        if let strokeFill = fill {
            return Stroke(fill: strokeFill,
                width: getStrokeWidth(styleParts),
                cap: getStrokeCap(styleParts),
                join: getStrokeJoin(styleParts),
                dashes: getStrokeDashes(styleParts))
        }

        return .None
    }

    private func getStrokeWidth(styleParts: [String: String]) -> Double {
        var width: Double = 1
        if let strokeWidth = styleParts["stroke-width"] {
            let strokeWidth = strokeWidth.stringByReplacingOccurrencesOfString(" ", withString: "")
            width = Double(strokeWidth)!
        }
        return width
    }
    
    private func getStrokeCap(styleParts: [String: String]) -> LineCap {
        var cap = LineCap.round
        if let strokeCap = styleParts["stroke-linecap"] {
            switch strokeCap {
            case "butt":
                cap = .butt
            case "square":
                cap = .square
            default:
                break
            }
        }
        return cap
    }
    
    private func getStrokeJoin(styleParts: [String: String]) -> LineJoin {
        var join = LineJoin.round
        if let strokeJoin = styleParts["stroke-linejoin"] {
            switch strokeJoin {
            case "miter":
                join = .miter
            case "bevel":
                join = .bevel
            default:
                break
            }
        }
        return join
    }
    
    private func getStrokeDashes(styleParts: [String: String]) -> [Double] {
        var dashes = [Double]()
        if let strokeDashes = styleParts["stroke-dasharray"] {
            let characterSet = NSMutableCharacterSet()
            characterSet.addCharactersInString(" ")
            characterSet.addCharactersInString(",")
            let separatedValues = strokeDashes.componentsSeparatedByCharactersInSet(characterSet)
            separatedValues.forEach { value in
                if let doubleValue = Double(value) {
                    dashes.append(doubleValue)
                }
            }
        }
        return dashes
    }
    
    private func getOpacity(styleParts: [String: String]) -> Double {
        if let opacityAttr = styleParts["opacity"] {
            return Double(opacityAttr.stringByReplacingOccurrencesOfString(" ", withString: "")) ?? 1
        }
        return 1
    }

    private func parseLine(line: XMLIndexer) -> Line? {
        guard let element = line.element else {
            return .None
        }
        
        return Line(x1: getDoubleValue(element, attribute: "x1") ?? 0,
                    y1: getDoubleValue(element, attribute: "y1") ?? 0,
                    x2: getDoubleValue(element, attribute: "x2") ?? 0,
                    y2: getDoubleValue(element, attribute: "y2") ?? 0)
    }

    private func parseRect(rect: XMLIndexer) -> Locus? {
        guard let element = rect.element,
            width = getDoubleValue(element, attribute: "width"),
            height = getDoubleValue(element, attribute: "height")
            where width > 0 && height > 0  else {
                
                return .None
        }
        
        let resultRect = Rect(x: getDoubleValue(element, attribute: "x") ?? 0, y: getDoubleValue(element, attribute: "y") ?? 0, w: width, h: height)
        
        let rxOpt = getDoubleValue(element, attribute: "rx")
        let ryOpt = getDoubleValue(element, attribute: "ry")
        if let rx = rxOpt, ry = ryOpt {
            return RoundRect(rect: resultRect, rx: rx, ry: ry)
        }
        let rOpt = rxOpt ?? ryOpt
        if let r = rOpt where r >= 0 {
            return RoundRect(rect: resultRect, rx: r, ry: r)
        }
        return resultRect
    }

    private func parseCircle(circle: XMLIndexer) -> Circle? {
        guard let element = circle.element, r = getDoubleValue(element, attribute: "r") where r > 0 else {
            return .None
        }
        
        return Circle(cx: getDoubleValue(element, attribute: "cx") ?? 0, cy: getDoubleValue(element, attribute: "cy") ?? 0, r: r)
    }

    private func parseEllipse(ellipse: XMLIndexer) -> Ellipse? {
        guard let element = ellipse.element,
            rx = getDoubleValue(element, attribute: "rx"),
            ry = getDoubleValue(element, attribute: "ry")
            where rx > 0 && ry > 0 else {
                
                return .None
        }
        
        return Ellipse(cx: getDoubleValue(element, attribute: "cx") ?? 0, cy: getDoubleValue(element, attribute: "cy") ?? 0, rx: rx, ry: ry)
    }

    private func parsePolygon(polygon: XMLIndexer) -> Polygon? {
        guard let element = polygon.element else {
            return .None
        }

        if let points = element.attributes["points"] {
            return Polygon(points: parsePoints(points))
        }

        return .None
    }

    private func parsePolyline(polyline: XMLIndexer) -> Polyline? {
        guard let element = polyline.element else {
            return .None
        }

        if let points = element.attributes["points"] {
            return Polyline(points: parsePoints(points))
        }

        return .None
    }

    private func parsePoints(pointsString: String) -> [Double] {
        var resultPoints: [Double] = []
        let pointPairs = pointsString.componentsSeparatedByString(" ")

        pointPairs.forEach { pointPair in
            let points = pointPair.componentsSeparatedByString(",")
            points.forEach { point in
                if let resultPoint = Double(point) {
                    resultPoints.append(resultPoint)
                }
            }
        }

        return resultPoints
    }
    
    private func parseImage(image: XMLIndexer, opacity: Double, pos: Transform = Transform()) -> Image? {
        guard let element = image.element, link = element.attributes["xlink:href"] else {
            return .None
        }
        let position = pos.move(dx: getDoubleValue(element, attribute: "x") ?? 0, dy: getDoubleValue(element, attribute: "y") ?? 0)
        return Image(src: link, w: getIntValue(element, attribute: "width") ?? 0, h: getIntValue(element, attribute: "height") ?? 0, place: position)
    }
    
    
    private func parseText(text: XMLIndexer, fill: Fill?, opacity: Double, fontName: String?, fontSize: Int?,
                           pos: Transform = Transform()) -> Node? {
        guard let element = text.element else {
            return .None
        }
        if text.children.isEmpty {
            return parseSimpleText(element, fill: fill, opacity: opacity, fontName: fontName, fontSize: fontSize)
        } else {
            guard let matcher = SVGParserRegexHelper.getTextElementMatcher() else {
                return .None
            }
            let elementString = element.description
            let fullRange = NSMakeRange(0, elementString.characters.count)
            if let match = matcher.firstMatchInString(elementString, options: .ReportCompletion, range: fullRange) {
                let tspans = (elementString as NSString).substringWithRange(match.rangeAtIndex(1))
                return Group(contents: collectTspans(tspans, fill: fill, opacity: opacity, fontName: fontName, fontSize: fontSize,
                    bounds: Rect(x: getDoubleValue(element, attribute: "x") ?? 0, y: getDoubleValue(element, attribute: "y") ?? 0)),
                    place: pos)
            }
        }
        return .None
    }
    
    private func parseSimpleText(text: XMLElement, fill: Fill?, opacity: Double, fontName: String?, fontSize: Int?, pos: Transform = Transform()) -> Text? {
        guard let string = text.text else {
            return .None
        }
        let position = pos.move(dx: getDoubleValue(text, attribute: "x") ?? 0, dy: getDoubleValue(text, attribute: "y") ?? 0)
        return Text(text: string, font: getFont(fontName: fontName, fontSize: fontSize), fill: fill ?? Color.black, opacity: opacity, place: position)
    }
    
    //REFACTOR
    
    private func collectTspans(tspan: String, collectedTspans: [Node] = [], withWhitespace: Bool = false, fill: Fill?, opacity: Double, fontName: String?, fontSize: Int?, bounds: Rect) -> [Node] {
        let fullString = tspan.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as NSString
        //exit recursion
        if fullString.isEqualToString("") {
            return collectedTspans
        }
        var collection = collectedTspans
        let tagRange = fullString.rangeOfString("<tspan".lowercaseString)
        if tagRange.location == 0 {
            //parse as <tspan> element
            let closingTagRange = fullString.rangeOfString("</tspan>".lowercaseString)
            let tspanString = fullString.substringToIndex(closingTagRange.location + closingTagRange.length)
            let tspanXml = SWXMLHash.parse(tspanString)
            guard let indexer = tspanXml.children.first,
                text = parseTspan(indexer, withWhitespace: withWhitespace, fill: fill, opacity: opacity, fontName: fontName, fontSize: fontSize, bounds: bounds) else {
                                    
                                    //skip this element if it can't be parsed
                                    return collectTspans(fullString.substringFromIndex(closingTagRange.location + closingTagRange.length), collectedTspans: collectedTspans, fill: fill, opacity: opacity,
                                                         fontName: fontName, fontSize: fontSize, bounds: bounds)
            }
            collection.append(text)
            let nextString = fullString.substringFromIndex(closingTagRange.location + closingTagRange.length) as NSString
            var withWhitespace = false
            if nextString.rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).location == 0 {
                withWhitespace = true
            }
            return collectTspans(fullString.substringFromIndex(closingTagRange.location + closingTagRange.length), collectedTspans: collection, withWhitespace: withWhitespace, fill: fill, opacity: opacity, fontName: fontName, fontSize: fontSize, bounds: text.bounds())
        }
        //parse as regular text element
        var textString: NSString
        if tagRange.location >= fullString.length {
            textString = fullString
        } else {
            textString = fullString.substringToIndex(tagRange.location)
        }
        var nextStringWhitespace = false
        var trimmedString = textString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if trimmedString.characters.count != textString.length {
            nextStringWhitespace = true
        }
        trimmedString = withWhitespace ? " \(trimmedString)" : trimmedString
        let text = Text(text: trimmedString, font: getFont(fontName: fontName, fontSize: fontSize),
                        fill: fill ?? Color.black, baseline: .alphabetic,
                        place: Transform().move(dx: bounds.x + bounds.w, dy: bounds.y), opacity: opacity)
        collection.append(text)
        return collectTspans(fullString.substringFromIndex(tagRange.location), collectedTspans: collection, withWhitespace: nextStringWhitespace, fill: fill, opacity: opacity,
                             fontName: fontName, fontSize: fontSize, bounds: text.bounds())
    }
    
    private func parseTspan(tspan: XMLIndexer, withWhitespace: Bool = false, fill: Fill?, opacity: Double, fontName: String?,
                            fontSize: Int?, bounds: Rect) -> Text? {
        
        guard let element = tspan.element, string = element.text else {
            return .None
        }
        var shouldAddWhitespace = withWhitespace
        let pos = getTspanPosition(element, bounds: bounds, withWhitespace: &shouldAddWhitespace)
        let text = shouldAddWhitespace ? " \(string)" : string
        let attributes = getStyleAttributes([:], element: element)
        
        return Text(text: text, font: getFont(attributes, fontName: fontName, fontSize: fontSize),
                    fill: getFillColor(attributes) ?? fill ?? Color.black, baseline: .alphabetic,
                    opacity: getOpacity(attributes) ?? opacity, place: pos)
    }
    
    private func getFont(attributes: [String: String] = [:], fontName: String?, fontSize: Int?) -> Font {
        return Font(
            name: getFontName(attributes) ?? fontName ?? "Serif",
            size: getFontSize(attributes) ?? fontSize ?? 12)
    }
    
    private func getTspanPosition(element: XMLElement, bounds: Rect, inout withWhitespace: Bool) -> Transform {
        var xPos: Double
        var yPos: Double
        
        if let absX = getDoubleValue(element, attribute: "x") {
            xPos = absX
            withWhitespace = false
        } else if let relX = getDoubleValue(element, attribute: "dx") {
            xPos = bounds.x + bounds.w + relX
        } else {
            xPos = bounds.x + bounds.w
        }
        
        if let absY = getDoubleValue(element, attribute: "y") {
            yPos = absY
        } else if let relY = getDoubleValue(element, attribute: "dy") {
            yPos = bounds.y + relY
        } else {
            yPos = bounds.y
        }
        return Transform().move(dx: xPos, dy: yPos)
    }
    
    private func parseUse(use: XMLIndexer, fill: Fill?, stroke: Stroke?, pos: Transform) -> Node? {
        guard let element = use.element, link = element.attributes["xlink:href"] else {
            return .None
        }
        var id = link
        if id.hasPrefix("#") {
            id = id.stringByReplacingOccurrencesOfString("#", withString: "")
        }
        guard let referenceNode = self.defNodes[id], node = copyNode(referenceNode) else {
            return .None
        }
        node.place = pos.move(dx: getDoubleValue(element, attribute: "x") ?? 0, dy: getDoubleValue(element, attribute: "y") ?? 0)
        if let shape = node as? Shape {
            if let color = fill {
                shape.fill = color
            }
            if let line = stroke {
                shape.stroke = line
            }
            return shape
        }
        if let text = node as? Text {
            if let color = fill {
                text.fill = color
            }
            return text
        }
        return node
    }
    
    private func parseLinearGradient(gradient: XMLIndexer) -> Fill? {
        guard let element = gradient.element else {
            return .None
        }
        var parentGradient: LinearGradient?
        if let link = element.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString(" ", withString: "")
            where link.hasPrefix("#") {
            
            let id = link.stringByReplacingOccurrencesOfString("#", withString: "")
            parentGradient = defFills[id] as? LinearGradient
        }
        
        var stopsArray: [Stop]?
        if gradient.children.isEmpty {
            stopsArray = parentGradient?.stops
        } else {
            stopsArray = parseStops(gradient.children)
        }
        
        guard let stops = stopsArray else {
            return .None
        }
        
        switch stops.count {
        case 0:
            return .None
        case 1:
            return stops.first?.color
        default:
            break
        }
        
        let x1 = getDoubleValueFromPercentage(element, attribute: "x1") ?? parentGradient?.x1 ?? 0
        let y1 = getDoubleValueFromPercentage(element, attribute: "y1") ?? parentGradient?.y1 ?? 0
        let x2 = getDoubleValueFromPercentage(element, attribute: "x2") ?? parentGradient?.x2 ?? 1
        let y2 = getDoubleValueFromPercentage(element, attribute: "y2") ?? parentGradient?.y2 ?? 0
        var userSpace = true
        if let gradientUnits = element.attributes["gradientUnits"] where gradientUnits == "userSpaceOnUse" {
            userSpace = false
        } else if let parent = parentGradient {
            userSpace = parent.userSpace
        }
        return LinearGradient(x1: x1, y1: y1, x2: x2, y2: y2, userSpace: userSpace, stops: stops)
    }
    
    private func parseRadialGradient(gradient: XMLIndexer) -> Fill? {
        guard let element = gradient.element else {
            return .None
        }
        var parentGradient: RadialGradient?
        if let link = element.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString(" ", withString: "")
            where link.hasPrefix("#") {
            
            let id = link.stringByReplacingOccurrencesOfString("#", withString: "")
            parentGradient = defFills[id] as? RadialGradient
        }
        
        var stopsArray: [Stop]?
        if gradient.children.isEmpty {
            stopsArray = parentGradient?.stops
        } else {
            stopsArray = parseStops(gradient.children)
        }
        
        guard let stops = stopsArray else {
            return .None
        }
        
        switch stops.count {
        case 0:
            return .None
        case 1:
            return stops.first?.color
        default:
            break
        }
        
        let cx = getDoubleValue(element, attribute: "cx") ?? parentGradient?.cx ?? 0.5
        let cy = getDoubleValue(element, attribute: "cy") ?? parentGradient?.cy ?? 0.5
        let fx = getDoubleValue(element, attribute: "fx") ?? parentGradient?.fx ?? cx
        let fy = getDoubleValue(element, attribute: "fy") ?? parentGradient?.fy ?? cy
        let r = getDoubleValue(element, attribute: "r") ?? parentGradient?.r ?? 0.5
        var userSpace = true
        if let gradientUnits = element.attributes["gradientUnits"] where gradientUnits == "userSpaceOnUse" {
            userSpace = false
        } else if let parent = parentGradient {
            userSpace = parent.userSpace
        }
        return RadialGradient(cx: cx, cy: cy, fx: fx, fy: fy, r: r, userSpace: userSpace, stops: stops)
    }
    
    private func parseStops(stops: [XMLIndexer]) -> [Stop] {
        var result = [Stop]()
        stops.forEach { stopXML in
            if let stop = parseStop(stopXML) {
                result.append(stop)
            }
        }
        return result
    }
    
    private func parseStop(stop: XMLIndexer) -> Stop? {
        guard let element = stop.element else {
            return .None
        }
        
        var offset = getDoubleValueFromPercentage(element, attribute: "offset")
        guard let _ = offset else {
            return .None
        }
        if offset < 0 {
            offset = 0
        } else if offset > 1 {
            offset = 1
        }
        var color = Color.black
        if let stopColor = getStyleAttributes([:], element: element)["stop-color"] {
            color = createColor(stopColor
                .stringByReplacingOccurrencesOfString(" ", withString: ""))
        }
        
        return Stop(offset: offset!, color: color)
    }

    private func parsePath(path: XMLIndexer) -> Path? {
        if let dAttr = path.element!.attributes["d"] {
            let pathSegments = parseCommands(dAttr)
            return Path(segments: pathSegments)
        }
        return .None
    }

    private func parseCommands(d: String) -> [PathSegment] {
        var pathCommands = [PathCommand]()
        var commandChar = Character(" ")
        var commandString = ""

        d.characters.forEach { character in
            if isCommandCharacter(character) {
                if !commandString.isEmpty {
                    pathCommands.append(
                        PathCommand(
                            type: getCommandType(commandChar),
                            expression: commandString,
                            absolute: isAbsolute(commandChar)
                        )
                    )
                }
                if character == closePathAbsolute || character == closePathRelative {
                    pathCommands.append(
                        PathCommand(
                            type: getCommandType(character),
                            expression: commandString,
                            absolute: true
                        )
                    )
                }
                commandString = ""
                commandChar = character
            } else {
                commandString.append(character)
            }
        }
        
        if !commandString.isEmpty && !(commandChar == " ") {
            pathCommands.append(
                PathCommand(type: getCommandType(commandChar),
                    expression: commandString,
                    absolute: isAbsolute(commandChar)
                )
            )
        }

        var commands = [PathSegment]()

        pathCommands.forEach { command in
            if let parsedCommand = parseCommand(command) {
                commands.append(parsedCommand)
            }
        }

        return commands
    }

    private func parseCommand(command: PathCommand) -> PathSegment? {
        let characterSet = NSMutableCharacterSet()
        characterSet.addCharactersInString(" ")
        characterSet.addCharactersInString(",")
        let commandParams = command.expression.componentsSeparatedByCharactersInSet(characterSet)
        var separatedValues = [String]()
        commandParams.forEach { param in
            separatedValues.appendContentsOf(separateNegativeValuesIfNeeded(param))
        }
        
        switch command.type {
        case .MoveTo:
            if separatedValues.count < 2 {
                return .None
            }

            guard let x = Double(separatedValues[0]), y = Double(separatedValues[1]) else {
                return .None
            }

            return PathSegment(type: command.absolute ? .M : .m, data: [x, y])

        case .LineTo:
            if separatedValues.count < 2 {
                return .None
            }

            guard let x = Double(separatedValues[0]), y = Double(separatedValues[1]) else {
                return .None
            }

            return PathSegment(type: command.absolute ? .L : .l, data: [x, y])

        case .LineH:
            if separatedValues.count < 1 {
                return .None
            }

            guard let x = Double(separatedValues[0]) else {
                return .None
            }

            return PathSegment(type: command.absolute ? .H : .h, data: [x])

        case .LineV:
            if separatedValues.count < 1 {
                return .None
            }

            guard let y = Double(separatedValues[0]) else {
                return .None
            }

            return PathSegment(type: command.absolute ? .V : .v, data: [y])

        case .CurveTo:
            if separatedValues.count < 6 {
                return .None
            }

            guard let x1 = Double(separatedValues[0]),
                y1 = Double(separatedValues[1]),
                x2 = Double(separatedValues[2]),
                y2 = Double(separatedValues[3]),
                x = Double(separatedValues[4]),
                y = Double(separatedValues[5]) else {
                    return .None
            }

            return PathSegment(type: command.absolute ? .C : .c, data: [x1, y1, x2, y2, x, y])
            
        case .SmoothCurveTo:
            if separatedValues.count < 4 {
                return .None
            }
            
            guard let x2 = Double(separatedValues[0]),
                y2 = Double(separatedValues[1]),
                x = Double(separatedValues[2]),
                y = Double(separatedValues[3]) else {
                    return .None
            }
            
            return PathSegment(type: command.absolute ? .S : .s, data: [x2, y2, x, y])
            
        case .ClosePath:
            return PathSegment(type: .Z)
        default:
            return .None
        }
    }
    
    private func separateNegativeValuesIfNeeded(expression: String) -> [String] {
        var values = [String]()
        var value = String()
        var e = false

        expression.characters.forEach { c in
            if c == "e" {
                e = true
            }
            if c == "-" && !e {
                if value.characters.count != 0 {
                    values.append(value)
                    value = String()
                }
                e = false
            }

            value.append(c)
        }

        if value.characters.count != 0 {
            values.append(value)
        }

        return values
    }

    private func isCommandCharacter(character: Character) -> Bool {
        switch character {
        case moveToAbsolute:
            return true
        case moveToRelative:
            return true
        case lineToAbsolute:
            return true
        case lineToRelative:
            return true
        case lineHorizontalAbsolute:
            return true
        case lineHorizontalRelative:
            return true
        case lineVerticalAbsolute:
            return true
        case lineVerticalRelative:
            return true
        case curveToAbsolute:
            return true
        case curveToRelative:
            return true
        case smoothCurveToAbsolute:
            return true
        case smoothCurveToRelative:
            return true
        case closePathAbsolute:
            return true
        case closePathRelative:
            return true
        default:
            return false
        }
    }

    private func isAbsolute(character: Character) -> Bool {
        switch character {
        case moveToAbsolute:
            return true
        case moveToRelative:
            return false
        case lineToAbsolute:
            return true
        case lineToRelative:
            return false
        case lineHorizontalAbsolute:
            return true
        case lineHorizontalRelative:
            return false
        case lineVerticalAbsolute:
            return true
        case lineVerticalRelative:
            return false
        case curveToAbsolute:
            return true
        case curveToRelative:
            return false
        case smoothCurveToAbsolute:
            return true
        case smoothCurveToRelative:
            return false
        case closePathAbsolute:
            return true
        case closePathRelative:
            return false
        default:
            return true
        }
    }

    private func getCommandType(character: Character) -> PathCommandType {
        switch character {
        case moveToAbsolute:
            return .MoveTo
        case moveToRelative:
            return .MoveTo
        case lineToAbsolute:
            return .LineTo
        case lineToRelative:
            return .LineTo
        case lineVerticalAbsolute:
            return .LineV
        case lineVerticalRelative:
            return .LineV
        case lineHorizontalAbsolute:
            return .LineH
        case lineHorizontalRelative:
            return .LineH
        case curveToAbsolute:
            return .CurveTo
        case curveToRelative:
            return .CurveTo
        case smoothCurveToAbsolute:
            return .SmoothCurveTo
        case smoothCurveToRelative:
            return .SmoothCurveTo
        case closePathAbsolute:
            return .ClosePath
        case closePathRelative:
            return .ClosePath
        default:
            return .None
        }
    }
    
    private func getDoubleValue(element: XMLElement, attribute: String) -> Double? {
        guard let attributeValue = element.attributes[attribute], doubleValue = Double(attributeValue) else {
            return .None
        }
        return doubleValue
    }
    
    private func getDoubleValueFromPercentage(element: XMLElement, attribute: String) -> Double? {
        guard let attributeValue = element.attributes[attribute] else {
            return .None
        }
        if !attributeValue.containsString("%") {
            return self.getDoubleValue(element, attribute: attribute)
        } else {
            let value = attributeValue.stringByReplacingOccurrencesOfString("%", withString: "")
            if let doubleValue = Double(value) {
                return doubleValue / 100
            }
        }
        return .None
    }
    
    private func getIntValue(element: XMLElement, attribute: String) -> Int? {
        guard let attributeValue = element.attributes[attribute], intValue = Int(attributeValue) else {
            return .None
        }
        return intValue
    }
    
    private func getFontName(attributes: [String: String]) -> String? {
        return attributes["font-family"]
    }
    
    private func getFontSize(attributes: [String: String]) -> Int? {
        guard let fontSize = attributes["font-size"] else {
            return .None
        }
        if let size = Double(fontSize) {
            return (Int(round(size)))
        }
        return .None
    }
    
    private func getFontStyle(attributes: [String: String], style: String) -> Bool? {
        guard let fontStyle = attributes["font-style"] else {
            return .None
        }
        if fontStyle.lowercaseString == style {
            return true
        }
        return false
    }
    
    private func getFontWeight(attributes: [String: String], style: String) -> Bool? {
        guard let fontWeight = attributes["font-weight"] else {
            return .None
        }
        if fontWeight.lowercaseString == style {
            return true
        }
        return false
    }
    
    private func getTextDecoration(attributes: [String: String], decoration: String) -> Bool? {
        guard let textDecoration = attributes["text-decoration"] else {
            return .None
        }
        if textDecoration.containsString(decoration) {
            return true
        }
        return false
    }
    
    private func copyNode(referenceNode: Node) -> Node? {
        
        let pos = referenceNode.place
        let opaque = referenceNode.opaque
        let visible = referenceNode.visible
        let clip = referenceNode.clip
        let tag = referenceNode.tag
        
        if let shape = referenceNode as? Shape {
            return Shape(form: shape.form, fill: shape.fill, stroke: shape.stroke, place: pos, opaque: opaque, visible: visible, clip: clip, tag: tag)
        }
        if let text = referenceNode as? Text {
            return Text(text: text.text, font: text.font, fill: text.fill, align: text.align, baseline: text.baseline, place: pos, opaque: opaque, visible: visible, clip: clip, tag: tag)
        }
        if let image = referenceNode as? Image {
            return Image(src: image.src, xAlign: image.xAlign, yAlign: image.yAlign, aspectRatio: image.aspectRatio, w: image.w, h: image.h, place: pos, opaque: opaque, visible: visible, clip: clip, tag: tag)
        }
        if let group = referenceNode as? Group {
            var contents = [Node]()
            group.contents.forEach { node in
                if let copy = copyNode(node) {
                    contents.append(copy)
                }
            }
            return Group(contents: contents, place: pos, opaque: opaque, visible: visible, clip: clip, tag: tag)
        }
        return .None
    }
}
