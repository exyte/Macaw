import Foundation
import CoreGraphics

#if !CARTHAGE
    import SWXMLHash
#endif

///
/// This class used to parse SVG file and build corresponding Macaw scene
///
open class SVGParser {

    /// Parse an SVG file identified by the specified bundle, name and file extension.
    /// - returns: Root node of the corresponding Macaw scene.
    open class func parse(bundle: Bundle, path: String, ofType: String = "svg") throws -> Node {
        guard let fullPath = bundle.path(forResource: path, ofType: ofType) else {
            throw SVGParserError.noSuchFile(path: "\(path).\(ofType)")
        }
        let text = try String(contentsOfFile: fullPath, encoding: String.Encoding.utf8)
        return try SVGParser.parse(text: text)
    }

    /// Parse an SVG file identified by the specified name and file extension.
    /// - returns: Root node of the corresponding Macaw scene.
    open class func parse(path: String, ofType: String = "svg") throws -> Node {
        return try SVGParser.parse(bundle: Bundle.main, path: path, ofType: ofType)
    }

    /// Parse the specified content of an SVG file.
    /// - returns: Root node of the corresponding Macaw scene.
    open class func parse(text: String) throws -> Node {
        return SVGParser(text).parse()
    }
    
    
    /// Parse the specified content of an SVG file on device (not part of the bundle
    /// - returns: Root node of the corresponding Macaw scene.
    open class func parse(file: URL) throws -> Node {
        guard let text = try? String(contentsOfFile: file.path, encoding: String.Encoding.utf8) else {
            throw SVGParserError.noSuchFile(path: "\(file.absoluteString)")
        }
        return try SVGParser.parse(text: text)
    }
    let availableStyleAttributes = ["stroke", "stroke-width", "stroke-opacity", "stroke-dasharray", "stroke-linecap", "stroke-linejoin",
                                    "fill", "text-anchor", "clip-path", "fill-opacity",
                                    "stop-color", "stop-opacity",
                                    "font-family", "font-size",
                                    "font-weight", "opacity"]

    fileprivate let xmlString: String
    fileprivate let initialPosition: Transform

    fileprivate var nodes = [Node]()
    fileprivate var defNodes = [String: XMLIndexer]()
    fileprivate var defFills = [String: Fill]()
    fileprivate var defMasks = [String: Shape]()
    fileprivate var defClip = [String: Locus]()

    fileprivate enum PathCommandType {
        case moveTo
        case lineTo
        case lineV
        case lineH
        case curveTo
        case smoothCurveTo
        case closePath
        case none
    }

    fileprivate typealias PathCommand = (type: PathCommandType, expression: String, absolute: Bool)

    fileprivate init(_ string: String, pos: Transform = Transform()) {
        self.xmlString = string
        self.initialPosition = pos
    }

    fileprivate func parse() -> Group {
        let parsedXml = SWXMLHash.parse(xmlString)
        iterateThroughXmlTree(parsedXml.children)

        let group = Group(contents: self.nodes, place: initialPosition)
        return group
    }

    fileprivate func iterateThroughXmlTree(_ children: [XMLIndexer]) {
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

    fileprivate func parseNode(_ node: XMLIndexer, groupStyle: [String: String] = [:]) -> Node? {
        if let element = node.element {
            if element.name == "g" {
                return parseGroup(node, groupStyle: groupStyle)
            } else if element.name == "clipPath" {
                if let id = element.allAttributes["id"]?.text, let clip = parseClip(node) {
                    self.defClip[id] = clip
                }
            } else if element.name == "style" {
                parseStyle(node)
            } else if element.name == "defs" {
                parseDefinitions(node)
            } else {
                return parseElement(node, groupStyle: groupStyle)
            }
        }
        return .none
    }

    fileprivate var styleTable: [String: [String: String]] = [:]

    fileprivate func parseStyle(_ styleNode: XMLIndexer) {
        if let rawStyle = styleNode.element?.text {
            var styleAttributes: [String: String] = [:]
            let parts = rawStyle.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "{")
            if parts.count == 2 {
                let className = String(parts[0].dropFirst())
                if !className.isEmpty {
                    let style = String(parts[1].dropLast())
                    let styleParts = style.replacingOccurrences(of: " ", with: "").components(separatedBy: ";")
                    styleParts.forEach { styleAttribute in
                        let currentStyle = styleAttribute.components(separatedBy: ":")
                        if currentStyle.count == 2 {
                            styleAttributes.updateValue(currentStyle[1], forKey: currentStyle[0])
                        }
                    }
                    styleTable[className] = styleAttributes
                }
            }
        }
    }

    fileprivate func parseDefinitions(_ defs: XMLIndexer) {
        for child in defs.children {
            guard let id = child.element?.allAttributes["id"]?.text else {
                continue
            }
            if let fill = parseFill(child) {
                self.defFills[id] = fill
                continue
            }

            if let _ = parseNode(child) {
                // TODO we don't really need to parse node
                self.defNodes[id] = child
                continue
            }

            if let mask = parseMask(child) {
                self.defMasks[id] = mask
                continue
            }

            if let clip = parseClip(child) {
                self.defClip[id] = clip
            }
        }
    }

    fileprivate func parseElement(_ node: XMLIndexer, groupStyle: [String: String] = [:]) -> Node? {
        if let element = node.element {
            let styleAttributes = getStyleAttributes(groupStyle, element: element)
            let position = getPosition(element)
            switch element.name {
            case "path":
                if let path = parsePath(node) {
                    return Shape(form: path, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
                }
            case "line":
                if let line = parseLine(node) {
                    return Shape(form: line, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
                }
            case "rect":
                if let rect = parseRect(node) {
                    return Shape(form: rect, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
                }
            case "circle":
                if let circle = parseCircle(node) {
                    return Shape(form: circle, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
                }
            case "ellipse":
                if let ellipse = parseEllipse(node) {
                    return Shape(form: ellipse, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
                }
            case "polygon":
                if let polygon = parsePolygon(node) {
                    return Shape(form: polygon, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
                }
            case "polyline":
                if let polyline = parsePolyline(node) {
                    return Shape(form: polyline, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
                }
            case "image":
                return parseImage(node, opacity: getOpacity(styleAttributes), pos: position, clip: getClipPath(styleAttributes))
            case "text":
                return parseText(node, textAnchor: getTextAnchor(styleAttributes), fill: getFillColor(styleAttributes),
                                 stroke: getStroke(styleAttributes), opacity: getOpacity(styleAttributes), fontName: getFontName(styleAttributes), fontSize: getFontSize(styleAttributes), fontWeight: getFontWeight(styleAttributes), pos: position)
            case "use":
                return parseUse(node, groupStyle: styleAttributes, place: position)
            case "mask":
                break
            default:
                print("SVG parsing error. Shape \(element.name) not supported")
                return .none
            }
        }
        return .none
    }

    fileprivate func parseFill(_ fill: XMLIndexer) -> Fill? {
        guard let element = fill.element else {
            return .none
        }
        switch element.name {
        case "linearGradient":
            return parseLinearGradient(fill)
        case "radialGradient":
            return parseRadialGradient(fill)
        default:
            return .none
        }
    }

    fileprivate func parseGroup(_ group: XMLIndexer, groupStyle: [String: String] = [:]) -> Group? {
        guard let element = group.element else {
            return .none
        }
        var groupNodes: [Node] = []
        let style = getStyleAttributes(groupStyle, element: element)
        let position = getPosition(element)
        group.children.forEach { child in
            if let node = parseNode(child, groupStyle: style) {
                groupNodes.append(node)
            }
        }
        return Group(contents: groupNodes, place: position, tag: getTag(element))
    }

    fileprivate func getMask(mask: String) -> Locus? {
        if let maskIdenitifierMatcher = SVGParserRegexHelper.getMaskIdenitifierMatcher() {
            let fullRange = NSRange(location: 0, length: mask.count)
            if let match = maskIdenitifierMatcher.firstMatch(in: mask, options: .reportCompletion, range: fullRange), let maskReferenceNode = self.defMasks[(mask as NSString).substring(with: match.range(at: 1))] {
                return maskReferenceNode.form
            }
        }
        return .none
    }

    fileprivate func getPosition(_ element: SWXMLHash.XMLElement) -> Transform {
        guard let transformAttribute = element.allAttributes["transform"]?.text else {
            return Transform.identity
        }
        return parseTransformationAttribute(transformAttribute)
    }

    var count = 0

    fileprivate func parseTransformationAttribute(_ attributes: String, transform: Transform = Transform()) -> Transform {
        guard let matcher = SVGParserRegexHelper.getTransformAttributeMatcher() else {
            return transform
        }
        var finalTransform = transform
        let fullRange = NSRange(location: 0, length: attributes.count)

        if let matchedAttribute = matcher.firstMatch(in: attributes, options: .reportCompletion, range: fullRange) {

            let attributeName = (attributes as NSString).substring(with: matchedAttribute.range(at: 1))
            let values = parseTransformValues((attributes as NSString).substring(with: matchedAttribute.range(at: 2)))
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
                        finalTransform = transform.rotate(angle: degreesToRadians(angle))
                    } else if values.count == 3 {
                        if let x = Double(values[1]), let y = Double(values[2]) {
                            finalTransform = transform.move(dx: x, dy: y).rotate(angle: degreesToRadians(angle)).move(dx: -x, dy: -y)
                        }
                    }
                }
            case "skewX":
                if let x = Double(values[0]) {
                    let v = tan((x * Double.pi) / 180.0)
                    finalTransform = transform.shear(shx: v, shy: 0)
                }
            case "skewY":
                if let y = Double(values[0]) {
                    let y = tan((y * Double.pi) / 180.0)
                    finalTransform = transform.shear(shx: 0, shy: y)
                }
            case "matrix":
                if values.count != 6 {
                    return transform
                }
                if let m11 = Double(values[0]), let m12 = Double(values[1]),
                    let m21 = Double(values[2]), let m22 = Double(values[3]),
                    let dx = Double(values[4]), let dy = Double(values[5]) {

                    let transformMatrix = Transform(m11: m11, m12: m12, m21: m21, m22: m22, dx: dx, dy: dy)
                    finalTransform = GeomUtils.concat(t1: transform, t2: transformMatrix)
                }
            default:
                break
            }
            let rangeToRemove = NSRange(location: 0, length: matchedAttribute.range.location + matchedAttribute.range.length)
            let newAttributeString = (attributes as NSString).replacingCharacters(in: rangeToRemove, with: "")
            return parseTransformationAttribute(newAttributeString, transform: finalTransform)
        } else {
            return transform
        }
    }

    /// Parse an RGB
    /// - returns: Color for the corresponding SVG color string in RGB notation.
    fileprivate func parseRGBNotation(colorString: String) -> Color {
        let from = colorString.index(colorString.startIndex, offsetBy: 4)
        let inPercentage = colorString.contains("%")
        let sp = String(colorString.suffix(from: from))
            .replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: " ", with: "")
        let x = sp.components(separatedBy: ",")
        var red = 0.0
        var green = 0.0
        var blue = 0.0
        if x.count == 3 {
            if let r = Double(x[0]), let g = Double(x[1]), let b = Double(x[2]) {
                blue = b
                green = g
                red = r
            }
        }
        if inPercentage {
            red *= 2.55
            green *= 2.55
            blue *= 2.55
        }
        return Color.rgb(r: Int(red.rounded(.up)),
                         g: Int(green.rounded(.up)),
                         b: Int(blue.rounded(.up)))
    }

    fileprivate func parseTransformValues(_ values: String, collectedValues: [String] = []) -> [String] {
        guard let matcher = SVGParserRegexHelper.getTransformMatcher() else {
            return collectedValues
        }
        var updatedValues: [String] = collectedValues
        let fullRange = NSRange(location: 0, length: values.count)
        if let matchedValue = matcher.firstMatch(in: values, options: .reportCompletion, range: fullRange) {
            let value = (values as NSString).substring(with: matchedValue.range)
            updatedValues.append(value)
            let rangeToRemove = NSRange(location: 0, length: matchedValue.range.location + matchedValue.range.length)
            let newValues = (values as NSString).replacingCharacters(in: rangeToRemove, with: "")
            return parseTransformValues(newValues, collectedValues: updatedValues)
        }
        return updatedValues
    }

    fileprivate func getStyleAttributes(_ groupAttributes: [String: String], element: SWXMLHash.XMLElement) -> [String: String] {
        var styleAttributes: [String: String] = groupAttributes

        if let className = element.allAttributes["class"]?.text, let styleAttributesFromTable = styleTable[className] {
            for (att, val) in styleAttributesFromTable {
                if styleAttributes.index(forKey: att) == nil {
                    styleAttributes.updateValue(val, forKey: att)
                }
            }
        }

        if let style = element.allAttributes["style"]?.text {
            let styleParts = style.replacingOccurrences(of: " ", with: "").components(separatedBy: ";")
            styleParts.forEach { styleAttribute in
                let currentStyle = styleAttribute.components(separatedBy: ":")
                if currentStyle.count == 2 {
                    styleAttributes.updateValue(currentStyle[1], forKey: currentStyle[0])
                }
            }
        }

        self.availableStyleAttributes.forEach { availableAttribute in
            if let styleAttribute = element.allAttributes[availableAttribute]?.text {
                styleAttributes.updateValue(styleAttribute, forKey: availableAttribute)
            }
        }

        return styleAttributes
    }

    fileprivate func createColor(_ hexString: String, opacity: Double = 1) -> Color {
        var cleanedHexString = hexString
        if hexString.hasPrefix("#") {
            cleanedHexString = hexString.replacingOccurrences(of: "#", with: "")
        }
        if cleanedHexString.count == 3 {
            let x = Array(cleanedHexString)
            cleanedHexString = "\(x[0])\(x[0])\(x[1])\(x[1])\(x[2])\(x[2])"
        }
        var rgbValue: UInt32 = 0
        Scanner(string: cleanedHexString).scanHexInt32(&rgbValue)

        let red = CGFloat((rgbValue >> 16) & 0xff)
        let green = CGFloat((rgbValue >> 08) & 0xff)
        let blue = CGFloat((rgbValue >> 00) & 0xff)

        return Color.rgba(r: Int(red), g: Int(green), b: Int(blue), a: opacity)
    }

    fileprivate func getFillColor(_ styleParts: [String: String]) -> Fill? {
        guard let fillColor = styleParts["fill"] else {
            return Color.black
        }
        if fillColor == "none" || fillColor == "transparent" {
            return .none
        }
        var opacity: Double = 1
        var hasFillOpacity = false
        if let fillOpacity = styleParts["fill-opacity"] {
            opacity = Double(fillOpacity.replacingOccurrences(of: " ", with: "")) ?? 1
            hasFillOpacity = true
        }
        if let defaultColor = SVGConstants.colorList[fillColor] {
            let color = Color(val: defaultColor)
            return hasFillOpacity ? color.with(a: opacity) : color
        }
        if fillColor.hasPrefix("rgb") {
            let color = parseRGBNotation(colorString: fillColor)
            return hasFillOpacity ? color.with(a: opacity) : color
        } else if fillColor.hasPrefix("url") {
            let index = fillColor.index(fillColor.startIndex, offsetBy: 4)
            let id = String(fillColor.suffix(from: index))
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .replacingOccurrences(of: "#", with: "")
            return defFills[id]
        } else {
            return createColor(fillColor.replacingOccurrences(of: " ", with: ""), opacity: opacity)
        }
    }

    fileprivate func getStroke(_ styleParts: [String: String]) -> Stroke? {
        guard let strokeColor = styleParts["stroke"] else {
            return .none
        }
        if strokeColor == "none" {
            return .none
        }
        var opacity: Double = 1
        if let strokeOpacity = styleParts["stroke-opacity"] {
            opacity = Double(strokeOpacity.replacingOccurrences(of: " ", with: "")) ?? 1
        }
        var fill: Fill?
        if let defaultColor = SVGConstants.colorList[strokeColor] {
            let color = Color(val: defaultColor)
            fill = color.with(a: opacity)
        } else if strokeColor.hasPrefix("rgb") {
            fill = parseRGBNotation(colorString: strokeColor)
        } else if strokeColor.hasPrefix("url") {
            let index = strokeColor.index(strokeColor.startIndex, offsetBy: 4)
            let id = String(strokeColor.suffix(from: index))
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .replacingOccurrences(of: "#", with: "")
            fill = defFills[id]
        } else {
            fill = createColor(strokeColor.replacingOccurrences(of: " ", with: ""), opacity: opacity)
        }

        if let strokeFill = fill {
            return Stroke(fill: strokeFill,
                          width: getStrokeWidth(styleParts),
                          cap: getStrokeCap(styleParts),
                          join: getStrokeJoin(styleParts),
                          dashes: getStrokeDashes(styleParts))
        }

        return .none
    }

    fileprivate func getStrokeWidth(_ styleParts: [String: String]) -> Double {
        if let strokeWidth = styleParts["stroke-width"] {
            let characterSet = NSCharacterSet.decimalDigits.union(NSCharacterSet.punctuationCharacters).inverted
            let digitsArray = strokeWidth.components(separatedBy: characterSet)
            let digits = digitsArray.joined()
            if let value = NumberFormatter().number(from: digits) {
                return value.doubleValue
            }
        }
        return 1
    }

    fileprivate func getStrokeCap(_ styleParts: [String: String]) -> LineCap {
        var cap = LineCap.butt
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

    fileprivate func getStrokeJoin(_ styleParts: [String: String]) -> LineJoin {
        var join = LineJoin.miter
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

    fileprivate func getStrokeDashes(_ styleParts: [String: String]) -> [Double] {
        var dashes = [Double]()
        if let strokeDashes = styleParts["stroke-dasharray"] {
            var characterSet = CharacterSet()
            characterSet.insert(" ")
            characterSet.insert(",")
            let separatedValues = strokeDashes.components(separatedBy: characterSet)
            separatedValues.forEach { value in
                if let doubleValue = Double(value) {
                    dashes.append(doubleValue)
                }
            }
        }
        return dashes
    }

    fileprivate func getTag(_ element: SWXMLHash.XMLElement) -> [String] {
        let id = element.allAttributes["id"]?.text
        return id != nil ? [id!] : []
    }

    fileprivate func getOpacity(_ styleParts: [String: String]) -> Double {
        if let opacityAttr = styleParts["opacity"] {
            return Double(opacityAttr.replacingOccurrences(of: " ", with: "")) ?? 1
        }
        return 1
    }

    fileprivate func parseLine(_ line: XMLIndexer) -> Line? {
        guard let element = line.element else {
            return .none
        }

        return Line(x1: getDoubleValue(element, attribute: "x1") ?? 0,
                    y1: getDoubleValue(element, attribute: "y1") ?? 0,
                    x2: getDoubleValue(element, attribute: "x2") ?? 0,
                    y2: getDoubleValue(element, attribute: "y2") ?? 0)
    }

    fileprivate func parseRect(_ rect: XMLIndexer) -> Locus? {
        guard let element = rect.element,
            let width = getDoubleValue(element, attribute: "width"),
            let height = getDoubleValue(element, attribute: "height"), width > 0 && height > 0 else {

                return .none
        }

        let resultRect = Rect(x: getDoubleValue(element, attribute: "x") ?? 0, y: getDoubleValue(element, attribute: "y") ?? 0, w: width, h: height)

        let rxOpt = getDoubleValue(element, attribute: "rx")
        let ryOpt = getDoubleValue(element, attribute: "ry")
        if let rx = rxOpt, let ry = ryOpt {
            return RoundRect(rect: resultRect, rx: rx, ry: ry)
        }
        let rOpt = rxOpt ?? ryOpt
        if let r = rOpt, r >= 0 {
            return RoundRect(rect: resultRect, rx: r, ry: r)
        }
        return resultRect
    }

    fileprivate func parseCircle(_ circle: XMLIndexer) -> Circle? {
        guard let element = circle.element, let r = getDoubleValue(element, attribute: "r"), r > 0 else {
            return .none
        }

        return Circle(cx: getDoubleValue(element, attribute: "cx") ?? 0, cy: getDoubleValue(element, attribute: "cy") ?? 0, r: r)
    }

    fileprivate func parseEllipse(_ ellipse: XMLIndexer) -> Arc? {
        guard let element = ellipse.element,
            let rx = getDoubleValue(element, attribute: "rx"),
            let ry = getDoubleValue(element, attribute: "ry"), rx > 0 && ry > 0 else {
                return .none
        }
        return Arc(
            ellipse: Ellipse(cx: getDoubleValue(element, attribute: "cx") ?? 0, cy: getDoubleValue(element, attribute: "cy") ?? 0, rx: rx, ry: ry),
            shift: 0,
            extent: degreesToRadians(360)
        )
    }

    fileprivate func parsePolygon(_ polygon: XMLIndexer) -> Polygon? {
        guard let element = polygon.element else {
            return .none
        }

        if let points = element.allAttributes["points"]?.text {
            return Polygon(points: parsePoints(points))
        }

        return .none
    }

    fileprivate func parsePolyline(_ polyline: XMLIndexer) -> Polyline? {
        guard let element = polyline.element else {
            return .none
        }

        if let points = element.allAttributes["points"]?.text {
            return Polyline(points: parsePoints(points))
        }

        return .none
    }

    fileprivate func parsePoints(_ pointsString: String) -> [Double] {
        var resultPoints: [Double] = []
        let pointPairs = pointsString.components(separatedBy: " ")

        pointPairs.forEach { pointPair in
            let points = pointPair.components(separatedBy: ",")
            points.forEach { point in
                if let resultPoint = Double(point) {
                    resultPoints.append(resultPoint)
                }
            }
        }

        return resultPoints
    }

    fileprivate func parseImage(_ image: XMLIndexer, opacity: Double, pos: Transform = Transform(), clip: Locus?) -> Image? {
        guard let element = image.element, let link = element.allAttributes["xlink:href"]?.text else {
            return .none
        }
        let position = pos.move(dx: getDoubleValue(element, attribute: "x") ?? 0, dy: getDoubleValue(element, attribute: "y") ?? 0)
        return Image(src: link, w: getIntValue(element, attribute: "width") ?? 0, h: getIntValue(element, attribute: "height") ?? 0, place: position, clip: clip, tag: getTag(element))
    }

    fileprivate func parseText(_ text: XMLIndexer, textAnchor: String?, fill: Fill?, stroke: Stroke?, opacity: Double, fontName: String?, fontSize: Int?, fontWeight: String?, pos: Transform = Transform()) -> Node? {
        guard let element = text.element else {
            return .none
        }
        if text.children.isEmpty {
            return parseSimpleText(element, textAnchor: textAnchor, fill: fill, stroke: stroke, opacity: opacity, fontName: fontName, fontSize: fontSize, fontWeight: fontWeight)
        } else {
            guard let matcher = SVGParserRegexHelper.getTextElementMatcher() else {
                return .none
            }
            let elementString = element.description
            let fullRange = NSRange(location: 0, length: elementString.count)
            if let match = matcher.firstMatch(in: elementString, options: .reportCompletion, range: fullRange) {
                let tspans = (elementString as NSString).substring(with: match.range(at: 1))
                return Group(contents: collectTspans(tspans, textAnchor: textAnchor, fill: fill, stroke: stroke, opacity: opacity, fontName: fontName, fontSize: fontSize, fontWeight: fontWeight, bounds: Rect(x: getDoubleValue(element, attribute: "x") ?? 0, y: getDoubleValue(element, attribute: "y") ?? 0)),
                             place: pos, tag: getTag(element))
            }
        }
        return .none
    }

    fileprivate func anchorToAlign(_ textAnchor: String?) -> Align {
        if let anchor = textAnchor {
            if anchor == "middle" {
                return .mid
            } else if anchor == "right" {
                return .max
            }
        }
        return Align.min
    }

    fileprivate func parseSimpleText(_ text: SWXMLHash.XMLElement, textAnchor: String?, fill: Fill?, stroke: Stroke?, opacity: Double, fontName: String?, fontSize: Int?, fontWeight: String?, pos: Transform = Transform()) -> Text? {
        let string = text.text
        let position = pos.move(dx: getDoubleValue(text, attribute: "x") ?? 0, dy: getDoubleValue(text, attribute: "y") ?? 0)

        return Text(text: string, font: getFont(fontName: fontName, fontWeight: fontWeight, fontSize: fontSize), fill: fill ?? Color.black, stroke: stroke, align: anchorToAlign(textAnchor), baseline: .bottom, place: position, opacity: opacity, tag: getTag(text))
    }

    // REFACTOR

    fileprivate func collectTspans(_ tspan: String, collectedTspans: [Node] = [], withWhitespace: Bool = false, textAnchor: String?, fill: Fill?, stroke: Stroke?, opacity: Double, fontName: String?, fontSize: Int?, fontWeight: String?, bounds: Rect) -> [Node] {
        let fullString = tspan.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        // exit recursion
        if fullString.isEqual(to: "") {
            return collectedTspans
        }
        var collection = collectedTspans
        let tagRange = fullString.range(of: "<tspan".lowercased())
        if tagRange.location == 0 {
            // parse as <tspan> element
            let closingTagRange = fullString.range(of: "</tspan>".lowercased())
            let tspanString = fullString.substring(to: closingTagRange.location + closingTagRange.length)
            let tspanXml = SWXMLHash.parse(tspanString)
            guard let indexer = tspanXml.children.first,
                let text = parseTspan(indexer, withWhitespace: withWhitespace, textAnchor: textAnchor, fill: fill, stroke: stroke, opacity: opacity, fontName: fontName, fontSize: fontSize, fontWeight: fontWeight, bounds: bounds) else {

                    // skip this element if it can't be parsed
                    return collectTspans(fullString.substring(from: closingTagRange.location + closingTagRange.length), collectedTspans: collectedTspans, textAnchor: textAnchor, fill: fill, stroke: stroke, opacity: opacity,
                                         fontName: fontName, fontSize: fontSize, fontWeight: fontWeight, bounds: bounds)
            }
            collection.append(text)
            let nextString = fullString.substring(from: closingTagRange.location + closingTagRange.length) as NSString
            var withWhitespace = false
            if nextString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location == 0 {
                withWhitespace = true
            }
            return collectTspans(fullString.substring(from: closingTagRange.location + closingTagRange.length), collectedTspans: collection, withWhitespace: withWhitespace, textAnchor: textAnchor, fill: fill, stroke: stroke, opacity: opacity, fontName: fontName, fontSize: fontSize, fontWeight: fontWeight, bounds: text.bounds())
        }
        // parse as regular text element
        var textString: NSString
        if tagRange.location >= fullString.length {
            textString = fullString
        } else {
            textString = fullString.substring(to: tagRange.location) as NSString
        }
        var nextStringWhitespace = false
        var trimmedString = textString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedString.count != textString.length {
            nextStringWhitespace = true
        }
        trimmedString = withWhitespace ? " \(trimmedString)" : trimmedString
        let text = Text(text: trimmedString, font: getFont(fontName: fontName, fontWeight: fontWeight, fontSize: fontSize),
                        fill: fill ?? Color.black, stroke: stroke, align: anchorToAlign(textAnchor), baseline: .alphabetic,
                        place: Transform().move(dx: bounds.x + bounds.w, dy: bounds.y), opacity: opacity)
        collection.append(text)
        return collectTspans(fullString.substring(from: tagRange.location), collectedTspans: collection,
                             withWhitespace: nextStringWhitespace, textAnchor: textAnchor, fill: fill, stroke: stroke,
                             opacity: opacity, fontName: fontName, fontSize: fontSize, fontWeight: fontWeight, bounds: text.bounds())
    }

    fileprivate func parseTspan(_ tspan: XMLIndexer, withWhitespace: Bool = false, textAnchor: String?, fill: Fill?, stroke: Stroke?, opacity: Double, fontName: String?, fontSize: Int?, fontWeight: String?, bounds: Rect) -> Text? {

        guard let element = tspan.element else {
            return .none
        }

        let string = element.text
        var shouldAddWhitespace = withWhitespace
        let pos = getTspanPosition(element, bounds: bounds, withWhitespace: &shouldAddWhitespace)
        let text = shouldAddWhitespace ? " \(string)" : string
        let attributes = getStyleAttributes([:], element: element)

        return Text(text: text, font: getFont(attributes, fontName: fontName, fontWeight: fontWeight, fontSize: fontSize),
                    fill: fill ?? getFillColor(attributes) ?? Color.black, stroke: stroke ?? getStroke(attributes),
                    align: anchorToAlign(textAnchor ?? getTextAnchor(attributes)), baseline: .alphabetic,
                    place: pos, opacity: getOpacity(attributes), tag: getTag(element))
    }

    fileprivate func getFont(_ attributes: [String: String] = [:], fontName: String?, fontWeight: String?, fontSize: Int?) -> Font {
        return Font(
            name: getFontName(attributes) ?? fontName ?? "Serif",
            size: getFontSize(attributes) ?? fontSize ?? 12,
            weight: getFontWeight(attributes) ?? fontWeight ?? "normal")
    }

    fileprivate func getTspanPosition(_ element: SWXMLHash.XMLElement, bounds: Rect, withWhitespace: inout Bool) -> Transform {
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
        return Transform.move(dx: xPos, dy: yPos)
    }

    fileprivate func parseUse(_ use: XMLIndexer, groupStyle: [String: String] = [:], place: Transform = .identity) -> Node? {
        guard let element = use.element, let link = element.allAttributes["xlink:href"]?.text else {
            return .none
        }
        var id = link
        if id.hasPrefix("#") {
            id = id.replacingOccurrences(of: "#", with: "")
        }
        if let referenceNode = self.defNodes[id] {
            if let node = parseNode(referenceNode, groupStyle: groupStyle) {
                let place = place.move(dx: getDoubleValue(element, attribute: "x") ?? 0, dy: getDoubleValue(element, attribute: "y") ?? 0)
                return Group(contents: [node], place: place)
            }
        }
        return .none
    }

    fileprivate func parseUseNode(node: Node, fill: Fill?, stroke: Stroke?, mask: String) -> Node {
        if let shape = node as? Shape {
            if let color = fill {
                shape.fill = color
            }
            if let line = stroke {
                shape.stroke = line
            }
            if let maskIdenitifierMatcher = SVGParserRegexHelper.getMaskIdenitifierMatcher() {
                let fullRange = NSRange(location: 0, length: mask.count)
                if let match = maskIdenitifierMatcher.firstMatch(in: mask, options: .reportCompletion, range: fullRange), let maskReferenceNode = self.defMasks[(mask as NSString).substring(with: match.range(at: 1))] {
                    shape.clip = maskReferenceNode.form
                    shape.fill = .none
                }
            }
            return shape
        }
        if let text = node as? Text {
            if let color = fill {
                text.fill = color
            }
            return text
        }
        if let group = node as? Group {
            group.contents.forEach { node in
                _ = parseUseNode(node: node, fill: fill, stroke: stroke, mask: mask)
            }
            return group
        }
        return node
    }

    fileprivate func parseClip(_ clip: XMLIndexer) -> Locus? {
        var path: Path? = .none
        clip.children.forEach { indexer in
            if let shape = parseNode(indexer) as? Shape {
                if let p = path {
                    path = Path(segments: p.segments + shape.form.toPath() .segments)
                } else {
                    path = shape.form.toPath()
                }
            }
        }
        return path
    }

    fileprivate func parseMask(_ mask: XMLIndexer) -> Shape? {
        guard let element = mask.element else {
            return .none
        }
        var node: Node?
        mask.children.forEach { indexer in
            if let useNode = parseUse(indexer) {
                node = useNode
            } else if let contentNode = parseNode(indexer) {
                node = contentNode
            }
        }
        guard let shape = node as? Shape else {
            return .none
        }
        let maskShape: Shape
        if let circle = shape.form as? Circle {
            maskShape = Shape(form: circle.arc(shift: 0, extent: degreesToRadians(360)), tag: getTag(element))
        } else {
            maskShape = Shape(form: shape.form, tag: getTag(element))
        }
        let maskStyleAttributes = getStyleAttributes([:], element: element)
        maskShape.fill = getFillColor(maskStyleAttributes)
        return maskShape
    }

    fileprivate func parseLinearGradient(_ gradient: XMLIndexer) -> Fill? {
        guard let element = gradient.element else {
            return .none
        }

        var parentGradient: Gradient?
        if let link = element.allAttributes["xlink:href"]?.text.replacingOccurrences(of: " ", with: ""), link.hasPrefix("#") {

            let id = link.replacingOccurrences(of: "#", with: "")
            parentGradient = defFills[id] as? Gradient
        }

        var stopsArray: [Stop]?
        if gradient.children.isEmpty {
            stopsArray = parentGradient?.stops
        } else {
            stopsArray = parseStops(gradient.children)
        }

        guard let stops = stopsArray else {
            return .none
        }

        switch stops.count {
        case 0:
            return .none
        case 1:
            return stops.first?.color
        default:
            break
        }

        let parentLinearGradient = parentGradient as? LinearGradient
        var x1 = getDoubleValueFromPercentage(element, attribute: "x1") ?? parentLinearGradient?.x1 ?? 0
        var y1 = getDoubleValueFromPercentage(element, attribute: "y1") ?? parentLinearGradient?.y1 ?? 0
        var x2 = getDoubleValueFromPercentage(element, attribute: "x2") ?? parentLinearGradient?.x2 ?? 1
        var y2 = getDoubleValueFromPercentage(element, attribute: "y2") ?? parentLinearGradient?.y2 ?? 0

        var userSpace = false
        if let gradientUnits = element.allAttributes["gradientUnits"]?.text, gradientUnits == "userSpaceOnUse" {
            userSpace = true
        } else if let parent = parentGradient {
            userSpace = parent.userSpace
        }

        if let gradientTransform = element.allAttributes["gradientTransform"]?.text {
            let transform = parseTransformationAttribute(gradientTransform)
            let cgTransform = RenderUtils.mapTransform(transform)
            
            let point1 = CGPoint(x: x1, y: y1).applying(cgTransform)
            x1 = point1.x.doubleValue
            y1 = point1.y.doubleValue
            
            let point2 = CGPoint(x: x2, y: y2).applying(cgTransform)
            x2 = point2.x.doubleValue
            y2 = point2.y.doubleValue
        }

        return LinearGradient(x1: x1, y1: y1, x2: x2, y2: y2, userSpace: userSpace, stops: stops)
    }

    fileprivate func parseRadialGradient(_ gradient: XMLIndexer) -> Fill? {
        guard let element = gradient.element else {
            return .none
        }

        var parentGradient: Gradient?
        if let link = element.allAttributes["xlink:href"]?.text.replacingOccurrences(of: " ", with: ""), link.hasPrefix("#") {

            let id = link.replacingOccurrences(of: "#", with: "")
            parentGradient = defFills[id] as? Gradient
        }

        var stopsArray: [Stop]?
        if gradient.children.isEmpty {
            stopsArray = parentGradient?.stops
        } else {
            stopsArray = parseStops(gradient.children)
        }

        guard let stops = stopsArray else {
            return .none
        }

        switch stops.count {
        case 0:
            return .none
        case 1:
            return stops.first?.color
        default:
            break
        }

        let parentRadialGradient = parentGradient as? RadialGradient
        var cx = getDoubleValueFromPercentage(element, attribute: "cx") ?? parentRadialGradient?.cx ?? 0.5
        var cy = getDoubleValueFromPercentage(element, attribute: "cy") ?? parentRadialGradient?.cy ?? 0.5
        var fx = getDoubleValueFromPercentage(element, attribute: "fx") ?? parentRadialGradient?.fx ?? cx
        var fy = getDoubleValueFromPercentage(element, attribute: "fy") ?? parentRadialGradient?.fy ?? cy
        let r = getDoubleValueFromPercentage(element, attribute: "r") ?? parentRadialGradient?.r ?? 0.5

        var userSpace = false
        if let gradientUnits = element.allAttributes["gradientUnits"]?.text, gradientUnits == "userSpaceOnUse" {
            userSpace = true
        } else if let parent = parentGradient {
            userSpace = parent.userSpace
        }

        if let gradientTransform = element.allAttributes["gradientTransform"]?.text {
            let transform = parseTransformationAttribute(gradientTransform)
            let cgTransform = RenderUtils.mapTransform(transform)
            
            let point1 = CGPoint(x: cx, y: cy).applying(cgTransform)
            cx = point1.x.doubleValue
            cy = point1.y.doubleValue
            
            let point2 = CGPoint(x: fx, y: fy).applying(cgTransform)
            fx = point2.x.doubleValue
            fy = point2.y.doubleValue
        }

        return RadialGradient(cx: cx, cy: cy, fx: fx, fy: fy, r: r, userSpace: userSpace, stops: stops)
    }

    fileprivate func parseStops(_ stops: [XMLIndexer]) -> [Stop] {
        var result = [Stop]()
        stops.forEach { stopXML in
            if let stop = parseStop(stopXML) {
                result.append(stop)
            }
        }
        return result
    }

    fileprivate func parseStop(_ stop: XMLIndexer) -> Stop? {
        guard let element = stop.element else {
            return .none
        }

        guard var offset = getDoubleValueFromPercentage(element, attribute: "offset") else {
            return .none
        }

        if offset < 0 {
            offset = 0
        } else if offset > 1 {
            offset = 1
        }
        var opacity: Double = 1
        if let stopOpacity = getStyleAttributes([:], element: element)["stop-opacity"], let doubleValue = Double(stopOpacity) {
            opacity = doubleValue
        }
        var color = Color.black
        if let stopColor = getStyleAttributes([:], element: element)["stop-color"] {
            color = createColor(stopColor.replacingOccurrences(of: " ", with: ""), opacity: opacity)
        }

        return Stop(offset: offset, color: color)
    }

    fileprivate func parsePath(_ path: XMLIndexer) -> Path? {
        if let d = path.element?.allAttributes["d"]?.text {
            return Path(segments: PathDataReader(input: d).read())
        }
        return .none
    }

    fileprivate func getDoubleValue(_ element: SWXMLHash.XMLElement, attribute: String) -> Double? {
        guard let attributeValue = element.allAttributes[attribute]?.text, let doubleValue = Double(attributeValue) else {
            return .none
        }
        return doubleValue
    }

    fileprivate func getDoubleValueFromPercentage(_ element: SWXMLHash.XMLElement, attribute: String) -> Double? {
        guard let attributeValue = element.allAttributes[attribute]?.text else {
            return .none
        }
        if !attributeValue.contains("%") {
            return self.getDoubleValue(element, attribute: attribute)
        } else {
            let value = attributeValue.replacingOccurrences(of: "%", with: "")
            if let doubleValue = Double(value) {
                return doubleValue / 100
            }
        }
        return .none
    }

    fileprivate func getIntValue(_ element: SWXMLHash.XMLElement, attribute: String) -> Int? {
        if let attributeValue = element.allAttributes[attribute]?.text {
            if let doubleValue = Double(attributeValue) {
                return Int(doubleValue)
            }
        }
        return .none
    }

    fileprivate func getFontName(_ attributes: [String: String]) -> String? {
        return attributes["font-family"]
    }

    fileprivate func getFontSize(_ attributes: [String: String]) -> Int? {
        guard let fontSize = attributes["font-size"] else {
            return .none
        }
        if let size = Double(fontSize) {
            return (Int(round(size)))
        }
        return .none
    }

    fileprivate func getFontStyle(_ attributes: [String: String], style: String) -> Bool? {
        guard let fontStyle = attributes["font-style"] else {
            return .none
        }
        if fontStyle.lowercased() == style {
            return true
        }
        return false
    }

    fileprivate func getFontWeight(_ attributes: [String: String]) -> String? {
        guard let fontWeight = attributes["font-weight"] else {
            return .none
        }
        return fontWeight
    }

    fileprivate func getFontWeight(_ attributes: [String: String], style: String) -> Bool? {
        guard let fontWeight = attributes["font-weight"] else {
            return .none
        }
        if fontWeight.lowercased() == style {
            return true
        }
        return false
    }

    fileprivate func getClipPath(_ attributes: [String: String]) -> Locus? {
        if let clipPath = attributes["clip-path"] {
            let index = clipPath.index(clipPath.startIndex, offsetBy: 4)
            let id = String(clipPath.suffix(from: index))
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .replacingOccurrences(of: "#", with: "")
            if let locus = defClip[id] {
                return locus
            }
        }
        return .none
    }

    fileprivate func getTextAnchor(_ attributes: [String: String]) -> String? {
        guard let textAnchor = attributes["text-anchor"] else {
            return .none
        }
        return textAnchor
    }

    fileprivate func getTextDecoration(_ attributes: [String: String], decoration: String) -> Bool? {
        guard let textDecoration = attributes["text-decoration"] else {
            return .none
        }
        if textDecoration.contains(decoration) {
            return true
        }
        return false
    }

    fileprivate func copyNode(_ referenceNode: Node) -> Node? {
        let pos = referenceNode.place
        let opaque = referenceNode.opaque
        let visible = referenceNode.visible
        let clip = referenceNode.clip
        let tag = referenceNode.tag

        if let shape = referenceNode as? Shape {
            return Shape(form: shape.form, fill: shape.fill, stroke: shape.stroke, place: pos, opaque: opaque, clip: clip, visible: visible, tag: tag)
        }
        if let text = referenceNode as? Text {
            return Text(text: text.text, font: text.font, fill: text.fill, stroke: text.stroke, align: text.align, baseline: text.baseline, place: pos, opaque: opaque, clip: clip, visible: visible, tag: tag)
        }
        if let image = referenceNode as? Image {
            return Image(src: image.src, xAlign: image.xAlign, yAlign: image.yAlign, aspectRatio: image.aspectRatio, w: image.w, h: image.h, place: pos, opaque: opaque, clip: clip, visible: visible, tag: tag)
        }
        if let group = referenceNode as? Group {
            var contents = [Node]()
            group.contents.forEach { node in
                if let copy = copyNode(node) {
                    contents.append(copy)
                }
            }
            return Group(contents: contents, place: pos, opaque: opaque, clip: clip, visible: visible, tag: tag)
        }
        return .none
    }

    fileprivate func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180
    }

}

private class PathDataReader {
    
    private let input: String
    private var current: UnicodeScalar?
    private var iterator: String.UnicodeScalarView.Iterator

    init(input: String) {
        self.input = input
        self.iterator = input.unicodeScalars.makeIterator()
    }
    
    public func read() -> [PathSegment] {
        let _ = readNext()
        var segments = [PathSegment]()
        while let array = readSegments() {
            segments.append(contentsOf: array)
        }
        return segments
    }

    private func readSegments() -> [PathSegment]? {
        if let type = readSegmentType() {
            let count = getArgCount(segment: type)
            if (count == 0) {
                return [PathSegment(type: type)]
            }
            var result = [PathSegment]()
            let data = readData()
            var index = 0
            while (index < data.count) {
                let end = index + count
                if (end > data.count) {
                    // TODO need to generate error:
                    // "Path '\(type)' has invalid number of arguments: \(data.count)"
                    break
                }
                result.append(PathSegment(type: type, data: Array(data[index..<end])))
                index = end
            }
            return result
        }
        return nil
    }

    private func readData() -> [Double] {
        var data = [Double]()
        while(true) {
            while(!isNumStart()) {
                if (getPathSegmentType() != nil || readNext() == nil) {
                    return data
                }
            }
            if let double = Double(readNum()) {
                data.append(double)
            }
        }
    }

    fileprivate func readNum() -> String {
        var chars = [current!]
        var hasDot = current == "."
        while let ch = readDigit(&hasDot) {
            chars.append(ch)
        }
        var buf = ""
        buf.unicodeScalars.append(contentsOf: chars)
        return buf
    }

    fileprivate func readDigit(_ hasDot: inout Bool) -> UnicodeScalar? {
        if let ch = readNext() {
            if (ch >= "0" && ch <= "9") {
                return ch
            } else if (ch == "." && !hasDot) {
                hasDot = true
                return ch
            }
        }
        return nil
    }

    fileprivate func isNum(ch: UnicodeScalar, hasDot: inout Bool) -> Bool {
        switch(ch) {
        case "0"..."9": return true
        case ".":
            if hasDot {
                return false
            }
            hasDot = true
        default:
            return true
        }
        return false
    }

    private func readNext() -> UnicodeScalar? {
        current = iterator.next()
        return current
    }
    
    private func readSegmentType() -> PathSegmentType? {
        while(true) {
            if let type = getPathSegmentType() {
                let _ = readNext()
                return type
            }
            if (readNext() == nil) {
                return nil
            }
        }
    }
    
    fileprivate func getPathSegmentType() -> PathSegmentType? {
        if let ch = current {
            switch(ch) {
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
            default: break
            }
        }
        return nil
    }
    
    fileprivate func getArgCount(segment: PathSegmentType) -> Int {
        switch(segment) {
        case .H, .h, .V, .v: return 1
        case .M, .m, .L, .l, .T, .t: return 2
        case .S, .s, .Q, .q: return 4
        case .C, .c: return 6
        case .A, .a: return 7
        default: return 0
        }
    }

    fileprivate func isNumStart() -> Bool {
        if let ch = current {
            return (ch >= "0" && ch <= "9") || ch == "." || ch == "-"
        }
        return false
    }

}
