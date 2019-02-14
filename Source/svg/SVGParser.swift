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
    ///
    /// - Parameters:
    ///   - bundle: Bundle resource
    ///   - path: Resource filename
    ///   - ofType: Type of resource file. The default is "svg"
    /// - Returns: Root node of the corresponding Macaw scene.
    /// - Throws: An SVGParserError of no such file
    @available(*, deprecated)
    open class func parse(bundle: Bundle, path: String, ofType: String = "svg") throws -> Node {
        guard let fullPath = bundle.path(forResource: path, ofType: ofType) else {
            throw SVGParserError.noSuchFile(path: "\(path).\(ofType)")
        }
        let text = try String(contentsOfFile: fullPath, encoding: .utf8)
        return try SVGParser.parse(text: text)
    }

    /// Parse an SVG file identified by the specified name and file extension.
    ///
    /// - Parameters:
    ///   - path: Resource filename
    ///   - ofType: Type of resource file. The default is "svg"
    /// - Returns: Root node of the corresponding Macaw scene.
    /// - Throws: An SVGParserError of no such file
    @available(*, deprecated)
    open class func parse(path: String, ofType: String = "svg") throws -> Node {
        return try SVGParser.parse(bundle: Bundle.main, path: path, ofType: ofType)
    }

    /// Parse an SVG file
    ///
    /// - Parameters:
    ///   - resource: Resource file name
    ///   - type: Type of resource file. The default is `svg`
    ///   - directory: Directory of given resource
    ///   - bundle: Bundle of given resource
    /// - Returns: Root node of the corresponding Macaw scene.
    /// - Throws: An SVGParserError of no such file
    open class func parse(resource: String,
                          ofType type: String = "svg",
                          inDirectory directory: String? = nil,
                          fromBundle bundle: Bundle = Bundle.main) throws -> Node {
        guard let fullpath = bundle.path(forResource: resource, ofType: type, inDirectory: directory) else {
            throw SVGParserError.noSuchFile(path: "\(resource).\(type)")
        }
        return try SVGParser.parse(fullPath: fullpath)
    }

    /// Parse an SVG file identified by full file path
    ///
    /// - Parameter fullPath: Full path
    /// - Returns: Root node of the corresponding Macaw scene.
    /// - Throws: An SVGParserError of no such file
    open class func parse(fullPath: String) throws -> Node {
        guard let text = try? String(contentsOfFile: fullPath, encoding: .utf8) else {
            throw SVGParserError.noSuchFile(path: fullPath)
        }
        return try SVGParser.parse(text: text)
    }

    /// Parse the specified content of an SVG file.
    /// - returns: Root node of the corresponding Macaw scene.
    open class func parse(text: String) throws -> Node {
        return try SVGParser(text).parse()
    }

    let availableStyleAttributes = ["stroke", "stroke-width", "stroke-opacity", "stroke-dasharray", "stroke-dashoffset", "stroke-linecap", "stroke-linejoin", "stroke-miterlimit",
                                    "fill", "fill-rule", "fill-opacity", "clip-path", "mask",
                                    "opacity", "color", "stop-color", "stop-opacity",
                                    "font-family", "font-size", "font-weight", "text-anchor",
                                    "visibility", "display"]

    fileprivate let xmlString: String
    fileprivate let initialPosition: Transform

    fileprivate var nodes = [Node]()
    fileprivate var defNodes = [String: XMLIndexer]()
    fileprivate var defFills = [String: Fill]()
    fileprivate var defMasks = [String: UserSpaceNode]()
    fileprivate var defClip = [String: UserSpaceLocus]()
    fileprivate var defEffects = [String: Effect]()
    fileprivate var defPatterns = [String: UserSpacePattern]()

    fileprivate var styles = CSSParser()

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

    fileprivate func parse() throws -> Group {
        let config = SWXMLHash.config { config in
            config.shouldProcessNamespaces = true
        }
        let parsedXml = config.parse(xmlString)

        var svgElement: SWXMLHash.XMLElement?
        for child in parsedXml.children {
            if let element = child.element {
                if element.name == "svg" {
                    svgElement = element
                    try prepareSvg(child.children)
                    break
                }
            }
        }
        let layout = svgElement != nil ? try parseViewBox(svgElement!) : nil
        try parseSvg(parsedXml.children)
        let root = layout != nil ? SVGCanvas(layout: layout!, contents: nodes) : Group(contents: nodes)
        if let opacity = svgElement?.attribute(by: "opacity") {
            root.opacity = getOpacity(opacity.text)
        }
        return root
    }

    fileprivate func prepareSvg(_ children: [XMLIndexer]) throws {
        try children.forEach { child in
            try prepareSvg(child)
        }
    }

    fileprivate func prepareSvg(_ node: XMLIndexer) throws {
        if let element = node.element {
            if element.name == "style" {
                parseStyle(node)
            } else if element.name == "defs" || element.name == "g" {
                try node.children.forEach { child in
                    try prepareSvg(child)
                }
            }
            if let id = element.allAttributes["id"]?.text {
                switch element.name {
                case "linearGradient", "radialGradient", "fill":
                    defFills[id] = try parseFill(node)
                case "pattern":
                    defPatterns[id] = try parsePattern(node)
                case "mask":
                    defMasks[id] = try parseMask(node)
                case "filter":
                    defEffects[id] = try parseEffect(node)
                case "clip", "clipPath":
                    defClip[id] = try parseClip(node)
                default:
                    defNodes[id] = node
                }
            }
        }
    }

    fileprivate func parseSvg(_ children: [XMLIndexer]) throws {
        try children.forEach { child in
            if let element = child.element {
                if element.name == "svg" {
                    try parseSvg(child.children)
                } else if let node = try parseNode(child) {
                    self.nodes.append(node)
                }
            }
        }
    }

    fileprivate func parseViewBox(_ element: SWXMLHash.XMLElement) throws -> SVGNodeLayout? {
        if element.allAttributes["width"] == nil && element.allAttributes["height"] == nil && element.allAttributes["viewBox"] == nil {
            return .none
        }

        let w = getDimensionValue(element, attribute: "width") ?? SVGLength(percent: 100)
        let h = getDimensionValue(element, attribute: "height") ?? SVGLength(percent: 100)
        let svgSize = SVGSize(width: w, height: h)

        var viewBox: Rect?
        if let viewBoxString = element.allAttributes["viewBox"]?.text {
            let nums = viewBoxString.components(separatedBy: .whitespaces).map { Double($0) }
            if nums.count == 4, let x = nums[0], let y = nums[1], let w = nums[2], let h = nums[3] {
                viewBox = Rect(x: x, y: y, w: w, h: h)
            }
        }

        var xAligningMode, yAligningMode: Align?
        var scalingMode: AspectRatio?
        if let contentModeString = element.allAttributes["preserveAspectRatio"]?.text {
            let strings = contentModeString.components(separatedBy: CharacterSet(charactersIn: " "))
            if strings.count == 1 { // none
                scalingMode = parseAspectRatio(strings[0])
                return SVGNodeLayout(svgSize: svgSize, viewBox: viewBox, scaling: scalingMode)
            }
            guard strings.count == 2 else {
                throw SVGParserError.invalidContentMode
            }

            let alignString = strings[0]
            var xAlign = alignString.prefix(4).lowercased()
            xAlign.remove(at: xAlign.startIndex)
            xAligningMode = parseAlign(xAlign)

            var yAlign = alignString.suffix(4).lowercased()
            yAlign.remove(at: yAlign.startIndex)
            yAligningMode = parseAlign(yAlign)

            scalingMode = parseAspectRatio(strings[1])
        }

        return SVGNodeLayout(svgSize: svgSize, viewBox: viewBox, scaling: scalingMode, xAlign: xAligningMode, yAlign: yAligningMode)
    }

    fileprivate func parseNode(_ node: XMLIndexer, groupStyle: [String: String] = [:]) throws -> Node? {
        var result: Node?
        if let element = node.element {
            let style = getStyleAttributes(groupStyle, element: element)
            if style["display"] == "none" {
                return .none
            }
            switch element.name {
            case "g":
                result = try parseGroup(node, style: style)
            case "style", "defs":
                // do nothing - it was parsed on first iteration
                return .none
            default:
                result = try parseElement(node, style: style)
            }

            if let result = result, let filterString = style["filter"], let filterId = parseIdFromUrl(filterString), let effect = defEffects[filterId] {
                result.effect = effect
            }
        }
        return result
    }

    fileprivate func parseStyle(_ styleNode: XMLIndexer) {
        if let rawStyle = styleNode.element?.text {
            styles.parse(content: rawStyle)
        }
    }

    fileprivate func parseElement(_ node: XMLIndexer, style: [String: String]) throws -> Node? {
        if style["visibility"] == "hidden" {
            return .none
        }
        guard let element = node.element else {
            return .none
        }
        let position = getPosition(element)
        switch element.name {
        case "path":
            if var path = parsePath(node) {
                if let rule = getFillRule(style) {
                    path = Path(segments: path.segments, fillRule: rule)
                }

                let mask = try getMask(style, locus: path)

                return Shape(form: path, fill: getFillColor(style, groupStyle: style, locus: path), stroke: getStroke(style, groupStyle: style), place: position, opacity: getOpacity(style), clip: getClipPath(style, locus: path), mask: mask, tag: getTag(element))
            }
        case "line":
            if let line = parseLine(node) {
                let mask = try getMask(style, locus: line)
                return Shape(form: line, fill: getFillColor(style, groupStyle: style, locus: line), stroke: getStroke(style, groupStyle: style), place: position, opacity: getOpacity(style), clip: getClipPath(style, locus: line), mask: mask, tag: getTag(element))
            }
        case "rect":
            if let rect = parseRect(node) {
                let mask = try getMask(style, locus: rect)
                return Shape(form: rect, fill: getFillColor(style, groupStyle: style, locus: rect), stroke: getStroke(style, groupStyle: style), place: position, opacity: getOpacity(style), clip: getClipPath(style, locus: rect), mask: mask, tag: getTag(element))
            }
        case "circle":
            if let circle = parseCircle(node) {
                let mask = try getMask(style, locus: circle)
                return Shape(form: circle, fill: getFillColor(style, groupStyle: style, locus: circle), stroke: getStroke(style, groupStyle: style), place: position, opacity: getOpacity(style), clip: getClipPath(style, locus: circle), mask: mask, tag: getTag(element))
            }
        case "ellipse":
            if let ellipse = parseEllipse(node) {
                let mask = try getMask(style, locus: ellipse)
                return Shape(form: ellipse, fill: getFillColor(style, groupStyle: style, locus: ellipse), stroke: getStroke(style, groupStyle: style), place: position, opacity: getOpacity(style), clip: getClipPath(style, locus: ellipse), mask: mask, tag: getTag(element))
            }
        case "polygon":
            if let polygon = parsePolygon(node) {
                let mask = try getMask(style, locus: polygon)
                return Shape(form: polygon, fill: getFillColor(style, groupStyle: style, locus: polygon), stroke: getStroke(style, groupStyle: style), place: position, opacity: getOpacity(style), clip: getClipPath(style, locus: polygon), mask: mask, tag: getTag(element))
            }
        case "polyline":
            if let polyline = parsePolyline(node) {
                let mask = try getMask(style, locus: polyline)
                return Shape(form: polyline, fill: getFillColor(style, groupStyle: style, locus: polyline), stroke: getStroke(style, groupStyle: style), place: position, opacity: getOpacity(style), clip: getClipPath(style, locus: polyline), mask: mask, tag: getTag(element))
            }
        case "image":
            return parseImage(node, opacity: getOpacity(style), pos: position, clip: getClipPath(style, locus: nil))
        case "text":
            return parseText(node, textAnchor: getTextAnchor(style), fill: getFillColor(style, groupStyle: style),
                             stroke: getStroke(style, groupStyle: style), opacity: getOpacity(style), fontName: getFontName(style), fontSize: getFontSize(style), fontWeight: getFontWeight(style), pos: position)
        case "use":
            return try parseUse(node, groupStyle: style, place: position)
        case "title", "desc", "mask", "clip", "filter",
             "linearGradient", "radialGradient", "fill":
            break
        default:
            print("SVG parsing error. Shape \(element.name) not supported")
            return .none
        }

        return .none
    }

    fileprivate func parseFill(_ fill: XMLIndexer) throws -> Fill? {
        guard let element = fill.element else {
            return .none
        }
        let style = getStyleAttributes([:], element: element)
        switch element.name {
        case "linearGradient":
            return parseLinearGradient(fill, groupStyle: style)
        case "radialGradient":
            return parseRadialGradient(fill, groupStyle: style)
        default:
            return .none
        }
    }

    fileprivate func parsePattern(_ pattern: XMLIndexer) throws -> UserSpacePattern? {
        guard let element = pattern.element else {
            return .none
        }

        var parentPattern: UserSpacePattern?
        if let link = element.allAttributes["xlink:href"]?.text.replacingOccurrences(of: " ", with: ""), link.hasPrefix("#") {
            let id = link.replacingOccurrences(of: "#", with: "")
            parentPattern = defPatterns[id]
        }

        let x = getDoubleValue(element, attribute: "x") ?? parentPattern?.bounds.x ?? 0
        let y = getDoubleValue(element, attribute: "y") ?? parentPattern?.bounds.y ?? 0
        let w = getDoubleValue(element, attribute: "width") ?? parentPattern?.bounds.w ?? 0
        let h = getDoubleValue(element, attribute: "height") ?? parentPattern?.bounds.h ?? 0
        let bounds = Rect(x: x, y: y, w: w, h: h)

        var userSpace = parentPattern?.userSpace ?? false
        if let units = element.allAttributes["patternUnits"]?.text, units == "userSpaceOnUse" {
            userSpace = true
        }
        var contentUserSpace = parentPattern?.contentUserSpace ?? true
        if let units = element.allAttributes["patternContentUnits"]?.text, units == "objectBoundingBox" {
            contentUserSpace = false
        }

        var contentNode: Node?
        if pattern.children.isEmpty {
            if let parentPattern = parentPattern {
                contentNode = parentPattern.content
            }
        } else if pattern.children.count == 1 {
            if let shape = try parseNode(pattern.children.first!) as? Shape {
                contentNode = shape
            }
        } else {
            var shapes = [Shape]()
            try pattern.children.forEach { indexer in
                if let shape = try parseNode(indexer) as? Shape {
                    shapes.append(shape)
                }
            }
            contentNode = Group(contents: shapes)
        }

        return UserSpacePattern(content: contentNode!, bounds: bounds, userSpace: userSpace, contentUserSpace: contentUserSpace)
    }

    fileprivate func parseGroup(_ group: XMLIndexer, style: [String: String]) throws -> Group? {
        guard let element = group.element else {
            return .none
        }
        var groupNodes: [Node] = []
        try group.children.forEach { child in
            if let node = try parseNode(child, groupStyle: style) {
                groupNodes.append(node)
            }
        }
        return Group(contents: groupNodes, place: getPosition(element), tag: getTag(element))
    }

    fileprivate func getPosition(_ element: SWXMLHash.XMLElement) -> Transform {
        guard let transformAttribute = element.allAttributes["transform"]?.text else {
            return Transform.identity
        }
        return parseTransformationAttribute(transformAttribute)
    }

    fileprivate func parseAlign(_ string: String) -> Align {
        if string == "min" {
            return .min
        }
        if string == "mid" {
            return .mid
        }
        return .max
    }

    fileprivate func parseAspectRatio(_ string: String) -> AspectRatio {
        if string == "meet" {
            return .meet
        }
        if string == "slice" {
            return .slice
        }
        return .none
    }

    var count = 0

    fileprivate func parseTransformationAttribute(_ attributes: String, transform: Transform = Transform()) -> Transform {
        guard let matcher = SVGParserRegexHelper.getTransformAttributeMatcher() else {
            return transform
        }

        let attributes = attributes.replacingOccurrences(of: "\n", with: "")
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
                    finalTransform = transform.concat(with: transformMatrix)
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

        for (att, val) in styles.getStyles(element: element) {
            if styleAttributes.index(forKey: att) == nil {
                styleAttributes.updateValue(val, forKey: att)
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
            if let styleAttribute = element.allAttributes[availableAttribute]?.text, styleAttribute != "inherit" {
                styleAttributes.updateValue(styleAttribute, forKey: availableAttribute)
            }
        }

        return styleAttributes
    }

    fileprivate func createColorFromHex(_ hexString: String, opacity: Double = 1) -> Color {
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

    fileprivate func createColor(_ colorString: String, opacity: Double = 1) -> Color? {
        if colorString == "none" || colorString == "transparent" {
            return .none
        }
        let opacity = min(max(opacity, 0), 1)
        if let defaultColor = SVGConstants.colorList[colorString] {
            let color = Color(val: defaultColor)
            return opacity != 1 ? color.with(a: opacity) : color
        }
        if colorString.hasPrefix("rgb") {
            let color = parseRGBNotation(colorString: colorString)
            return opacity != 1 ? color.with(a: opacity) : color
        }
        return createColorFromHex(colorString, opacity: opacity)
    }

    fileprivate func getFillColor(_ styleParts: [String: String], groupStyle: [String: String] = [:], locus: Locus? = nil) -> Fill? {
        var opacity: Double = 1
        if let fillOpacity = styleParts["fill-opacity"] {
            opacity = Double(fillOpacity.replacingOccurrences(of: " ", with: "")) ?? 1
        }

        guard var fillColor = styleParts["fill"] else {
            return Color.black.with(a: opacity)
        }
        if let colorId = parseIdFromUrl(fillColor) {
            if let fill = defFills[colorId] {
                return fill
            }
            if let pattern = defPatterns[colorId] {
                return getPatternFill(pattern: pattern, locus: locus)
            }
        }
        if fillColor == "currentColor", let currentColor = groupStyle["color"] {
            fillColor = currentColor
        }

        return createColor(fillColor.replacingOccurrences(of: " ", with: ""), opacity: opacity)
    }

    fileprivate func getPatternFill(pattern: UserSpacePattern, locus: Locus?) -> Pattern {
        if pattern.userSpace == false && pattern.contentUserSpace == true {
            let tranform = BoundsUtils.transformForLocusInRespectiveCoords(respectiveLocus: pattern.bounds, absoluteLocus: locus!)
            return Pattern(content: pattern.content, bounds: pattern.bounds.applying(tranform), userSpace: true)
        }
        if pattern.userSpace == true && pattern.contentUserSpace == false {
            if let patternNode = BoundsUtils.createNodeFromRespectiveCoords(respectiveNode: pattern.content, absoluteLocus: locus!) {
                return Pattern(content: patternNode, bounds: pattern.bounds, userSpace: pattern.userSpace)
            }
        }
        return Pattern(content: pattern.content, bounds: pattern.bounds, userSpace: true)
    }

    fileprivate func getStroke(_ styleParts: [String: String], groupStyle: [String: String] = [:]) -> Stroke? {
        guard var strokeColor = styleParts["stroke"] else {
            return .none
        }
        if strokeColor == "currentColor", let currentColor = groupStyle["color"] {
            strokeColor = currentColor
        }
        var opacity: Double = 1
        if let strokeOpacity = styleParts["stroke-opacity"] {
            opacity = Double(strokeOpacity.replacingOccurrences(of: " ", with: "")) ?? 1
            opacity = min(max(opacity, 0), 1)
        }
        var fill: Fill?
        if let colorId = parseIdFromUrl(strokeColor) {
            fill = defFills[colorId]
        } else {
            fill = createColor(strokeColor.replacingOccurrences(of: " ", with: ""), opacity: opacity)
        }

        if let strokeFill = fill {
            return Stroke(fill: strokeFill,
                          width: getStrokeWidth(styleParts),
                          cap: getStrokeCap(styleParts),
                          join: getStrokeJoin(styleParts),
                          miterLimit: getStrokeMiterLimit(styleParts),
                          dashes: getStrokeDashes(styleParts),
                          offset: getStrokeOffset(styleParts))
        }

        return .none
    }

    fileprivate func getStrokeWidth(_ styleParts: [String: String]) -> Double {
        if let strokeWidth = styleParts["stroke-width"], let value = doubleFromString(strokeWidth) {
            return value
        }
        return 1
    }

    fileprivate func getStrokeMiterLimit(_ styleParts: [String: String]) -> Double {
        if let strokeWidth = styleParts["stroke-miterlimit"], let value = doubleFromString(strokeWidth) {
            return value
        }
        return 4
    }

    fileprivate func getStrokeCap(_ styleParts: [String: String]) -> LineCap {
        var cap = LineCap.butt
        if let strokeCap = styleParts["stroke-linecap"] {
            switch strokeCap {
            case "round":
                cap = .round
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
            case "round":
                join = .round
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
            let separatedValues = strokeDashes.components(separatedBy: CharacterSet(charactersIn: " ,"))
            separatedValues.forEach { value in
                if let doubleValue = doubleFromString(value) {
                    dashes.append(doubleValue)
                }
            }
        }
        return dashes
    }

    fileprivate func getMatrix(_ element: SWXMLHash.XMLElement, attribute: String) -> [Double] {
        var result = [Double]()
        if let values = element.allAttributes[attribute]?.text {
            let separatedValues = values.components(separatedBy: CharacterSet(charactersIn: " ,"))
            separatedValues.forEach { value in
                if let doubleValue = doubleFromString(value) {
                    result.append(doubleValue)
                }
            }
        }
        return result
    }

    fileprivate func getStrokeOffset(_ styleParts: [String: String]) -> Double {
        if let strokeOffset = styleParts["stroke-dashoffset"], let offset = doubleFromString(strokeOffset) {
            return offset
        }
        return 0
    }

    fileprivate func getTag(_ element: SWXMLHash.XMLElement) -> [String] {
        let id = element.allAttributes["id"]?.text
        return id != nil ? [id!] : []
    }

    fileprivate func getOpacity(_ styleParts: [String: String]) -> Double {
        if let opacityAttr = styleParts["opacity"] {
            return getOpacity(opacityAttr)
        }
        return 1
    }

    fileprivate func getOpacity(_ opacity: String) -> Double {
        return Double(opacity.replacingOccurrences(of: " ", with: "")) ?? 1
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
        let pointPairs = pointsString.replacingOccurrences(of: "-", with: " -").components(separatedBy: " ")

        pointPairs.forEach { pointPair in
            let points = pointPair.components(separatedBy: ",")
            points.forEach { point in
                if let resultPoint = Double(point) {
                    resultPoints.append(resultPoint)
                }
            }
        }

        if resultPoints.count % 2 == 1 {
            resultPoints.removeLast()
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
            return parseSimpleText(element, textAnchor: textAnchor, fill: fill, stroke: stroke, opacity: opacity, fontName: fontName, fontSize: fontSize, fontWeight: fontWeight, pos: pos)
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
            } else if anchor == "end" {
                return .max
            }
        }
        return Align.min
    }

    fileprivate func parseSimpleText(_ text: SWXMLHash.XMLElement, textAnchor: String?, fill: Fill?, stroke: Stroke?, opacity: Double, fontName: String?, fontSize: Int?, fontWeight: String?, pos: Transform = Transform()) -> Text? {
        let string = text.text
        let position = pos.move(dx: getDoubleValue(text, attribute: "x") ?? 0, dy: getDoubleValue(text, attribute: "y") ?? 0)

        return Text(text: string, font: getFont(fontName: fontName, fontWeight: fontWeight, fontSize: fontSize), fill: fill, stroke: stroke, align: anchorToAlign(textAnchor), baseline: .bottom, place: position, opacity: opacity, tag: getTag(text))
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
                let text = parseTspan(indexer, withWhitespace: withWhitespace, textAnchor: textAnchor, fill: fill, stroke: stroke, opacity: opacity, fontName: fontName, fontSize: fontSize, fontWeight: fontWeight, bounds: bounds, previousCollectedTspan: collection.last) else {

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
            return collectTspans(fullString.substring(from: closingTagRange.location + closingTagRange.length), collectedTspans: collection, withWhitespace: withWhitespace, textAnchor: textAnchor, fill: fill, stroke: stroke, opacity: opacity, fontName: fontName, fontSize: fontSize, fontWeight: fontWeight, bounds: Rect(x: bounds.x, y: bounds.y, w: bounds.w + text.bounds.w, h: bounds.h))
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
                        fill: fill, stroke: stroke, align: anchorToAlign(textAnchor), baseline: .alphabetic,
                        place: Transform().move(dx: bounds.x + bounds.w, dy: bounds.y), opacity: opacity)
        collection.append(text)
        if tagRange.location >= fullString.length { // leave recursion
            return collection
        }
        return collectTspans(fullString.substring(from: tagRange.location), collectedTspans: collection,
                             withWhitespace: nextStringWhitespace, textAnchor: textAnchor, fill: fill, stroke: stroke,
                             opacity: opacity, fontName: fontName, fontSize: fontSize, fontWeight: fontWeight, bounds: Rect(x: bounds.x, y: bounds.y, w: bounds.w + text.bounds.w, h: bounds.h))
    }

    fileprivate func parseTspan(_ tspan: XMLIndexer, withWhitespace: Bool = false, textAnchor: String?, fill: Fill?, stroke: Stroke?, opacity: Double, fontName: String?, fontSize: Int?, fontWeight: String?, bounds: Rect, previousCollectedTspan: Node?) -> Text? {

        guard let element = tspan.element else {
            return .none
        }

        let string = element.text
        var shouldAddWhitespace = withWhitespace
        let pos = getTspanPosition(element, bounds: bounds, previousCollectedTspan: previousCollectedTspan, withWhitespace: &shouldAddWhitespace)
        let text = shouldAddWhitespace ? " \(string)" : string
        let attributes = getStyleAttributes([:], element: element)

        return Text(text: text, font: getFont(attributes, fontName: fontName, fontWeight: fontWeight, fontSize: fontSize),
                    fill: (attributes["fill"] != nil) ? getFillColor(attributes)! : fill, stroke: stroke ?? getStroke(attributes),
                    align: anchorToAlign(textAnchor ?? getTextAnchor(attributes)), baseline: .alphabetic,
                    place: pos, opacity: getOpacity(attributes), tag: getTag(element))
    }

    fileprivate func getFont(_ attributes: [String: String] = [:], fontName: String?, fontWeight: String?, fontSize: Int?) -> Font {
        return Font(
            name: getFontName(attributes) ?? fontName ?? "Serif",
            size: getFontSize(attributes) ?? fontSize ?? 12,
            weight: getFontWeight(attributes) ?? fontWeight ?? "normal")
    }

    fileprivate func getTspanPosition(_ element: SWXMLHash.XMLElement, bounds: Rect, previousCollectedTspan: Node?, withWhitespace: inout Bool) -> Transform {
        var xPos: Double = bounds.x + bounds.w
        var yPos: Double = bounds.y

        if let absX = getDoubleValue(element, attribute: "x") {
            xPos = absX
            withWhitespace = false

            if let relX = getDoubleValue(element, attribute: "dx") {
                xPos += relX
            }
        } else if let relX = getDoubleValue(element, attribute: "dx") {
            if let prevTspanX = previousCollectedTspan?.place.dx, let prevTspanW = previousCollectedTspan?.bounds?.w {
                xPos = prevTspanX + prevTspanW + relX
            } else {
                xPos += relX
            }
        }

        if let absY = getDoubleValue(element, attribute: "y") {
            yPos = absY

            if let relY = getDoubleValue(element, attribute: "dy") {
                yPos += relY
            }
        } else if let relY = getDoubleValue(element, attribute: "dy") {
            if let prevTspanY = previousCollectedTspan?.place.dy {
                yPos = prevTspanY + relY
            } else {
                yPos += relY
            }
        }

        return Transform.move(dx: xPos, dy: yPos)
    }

    private var usedReferenced = [String: String]()

    fileprivate func parseUse(_ use: XMLIndexer, groupStyle: [String: String] = [:], place: Transform = .identity) throws -> Node? {
        guard let element = use.element, let link = element.allAttributes["xlink:href"]?.text else {
            return .none
        }
        var id = link
        if id.hasPrefix("#") {
            id = id.replacingOccurrences(of: "#", with: "")
        }
        if let referenceNode = self.defNodes[id] {
            if usedReferenced[id] == nil {
                usedReferenced[id] = id
                defer {
                    usedReferenced.removeValue(forKey: id)
                }
                if let node = try parseNode(referenceNode, groupStyle: groupStyle) {
                    node.place = place.move(dx: getDoubleValue(element, attribute: "x") ?? 0, dy: getDoubleValue(element, attribute: "y") ?? 0).concat(with: node.place)
                    return node
                }
            }
        }
        return .none
    }

    fileprivate func parseClip(_ clip: XMLIndexer) throws -> UserSpaceLocus? {
        var userSpace = true
        if let units = clip.element?.allAttributes["clipPathUnits"]?.text, units == "objectBoundingBox" {
            userSpace = false
        }

        if clip.children.isEmpty {
            return .none
        }

        if clip.children.count == 1 {
            let shape = try parseNode(clip.children.first!) as! Shape
            if shape.place != Transform.identity {
                let locus = TransformedLocus(locus: shape.form, transform: shape.place)
                return UserSpaceLocus(locus: locus, userSpace: userSpace)
            }
            return UserSpaceLocus(locus: shape.form, userSpace: userSpace)
        }
        var path: Path? = .none
        try clip.children.forEach { indexer in
            if let shape = try parseNode(indexer) as? Shape {
                if let p = path {
                    path = Path(segments: p.segments + shape.form.toPath().segments, fillRule: p.fillRule)
                } else {
                    path = Path(segments: shape.form.toPath().segments)
                }
            }
        }
        return UserSpaceLocus(locus: path!, userSpace: userSpace)
    }

    fileprivate func parseMask(_ mask: XMLIndexer) throws -> UserSpaceNode? {
        var userSpace = true
        let styles = getStyleAttributes([:], element: mask.element!)
        if let units = mask.element?.allAttributes["maskContentUnits"]?.text, units == "objectBoundingBox" {
            userSpace = false
        }

        if mask.children.isEmpty {
            return .none
        }

        if mask.children.count == 1 {
            let node = try parseNode(mask.children.first!, groupStyle: styles)!
            return UserSpaceNode(node: node, userSpace: userSpace)
        }

        var nodes = [Node]()
        try mask.children.forEach { indexer in
            let position = getPosition(indexer.element!)
            if let useNode = try parseUse(indexer, groupStyle: styles, place: position) {
                nodes.append(useNode)
            } else if let contentNode = try parseNode(indexer, groupStyle: styles) {
                nodes.append(contentNode)
            }
        }

        return UserSpaceNode(node: Group(contents: nodes), userSpace: userSpace)
    }

    fileprivate func parseEffect(_ filterNode: XMLIndexer) throws -> Effect? {
        let defaultSource = "SourceGraphic"
        var effects = [String: Effect]()
        for child in filterNode.children {
            guard let element = child.element else { continue }

            let filterIn = element.allAttributes["in"]?.text ?? defaultSource
            var currentEffect = effects[filterIn]
            if currentEffect == nil && filterIn == "SourceAlpha" {
                currentEffect = AlphaEffect(input: nil)
            } else if currentEffect == nil && filterIn != defaultSource {
                throw SVGParserError.incorrectFilterEffectsOrder
            }
            effects.removeValue(forKey: filterIn)

            let filterOut = element.allAttributes["result"]?.text
            var resultingEffect: Effect? = .none

            switch element.name {
            case "feOffset":
                if let dx = getDoubleValue(element, attribute: "dx"), let dy = getDoubleValue(element, attribute: "dy") {
                    resultingEffect = OffsetEffect(dx: dx, dy: dy, input: currentEffect)
                }
            case "feGaussianBlur":
                if let radius = getDoubleValue(element, attribute: "stdDeviation") {
                    resultingEffect = GaussianBlur(r: radius, input: currentEffect)
                }
            case "feColorMatrix":
                if let type = element.allAttributes["type"]?.text {
                    var matrix: ColorMatrix?
                    if type == "saturate" {
                        matrix = ColorMatrix(saturate: getDoubleValue(element, attribute: "values")!)
                    } else if type == "hueRotate" {
                        let degrees = getDoubleValue(element, attribute: "values")!
                        matrix = ColorMatrix(hueRotate: degrees / 180 * Double.pi)
                    } else if type == "luminanceToAlpha" {
                        matrix = .luminanceToAlpha
                    } else { // "matrix"
                        matrix = ColorMatrix(values: getMatrix(element, attribute: "values"))
                    }
                    resultingEffect = ColorMatrixEffect(matrix: matrix!, input: currentEffect)
                }
            case "feBlend":
                if let filterIn2 = element.allAttributes["in2"]?.text {
                    if currentEffect != nil {
                        resultingEffect = BlendEffect(input: currentEffect)
                    } else if let currentEffect = effects[filterIn2] {
                        resultingEffect = BlendEffect(input: currentEffect)
                    }
                }
            default:
                print("SVG parsing error. Filter \(element.name) not supported")
                continue
            }

            if filterOut == nil {
                return resultingEffect
            }
            effects[filterOut!] = resultingEffect
        }

        if effects.count == 1 {
            return effects.first?.value
        }
        return nil
    }

    fileprivate func parseLinearGradient(_ gradient: XMLIndexer, groupStyle: [String: String] = [:]) -> Fill? {
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
            stopsArray = parseStops(gradient.children, groupStyle: groupStyle)
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
            let cgTransform = transform.toCG()

            let point1 = CGPoint(x: x1, y: y1).applying(cgTransform)
            x1 = point1.x.doubleValue
            y1 = point1.y.doubleValue

            let point2 = CGPoint(x: x2, y: y2).applying(cgTransform)
            x2 = point2.x.doubleValue
            y2 = point2.y.doubleValue
        }

        return LinearGradient(x1: x1, y1: y1, x2: x2, y2: y2, userSpace: userSpace, stops: stops)
    }

    fileprivate func parseRadialGradient(_ gradient: XMLIndexer, groupStyle: [String: String] = [:]) -> Fill? {
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
            stopsArray = parseStops(gradient.children, groupStyle: groupStyle)
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
        var r = getDoubleValueFromPercentage(element, attribute: "r") ?? parentRadialGradient?.r ?? 0.5

        var userSpace = false
        if let gradientUnits = element.allAttributes["gradientUnits"]?.text, gradientUnits == "userSpaceOnUse" {
            userSpace = true
        } else if let parent = parentGradient {
            userSpace = parent.userSpace
        }

        if let gradientTransform = element.allAttributes["gradientTransform"]?.text {
            let transform = parseTransformationAttribute(gradientTransform)
            let cgTransform = transform.toCG()

            let point1 = CGPoint(x: cx, y: cy).applying(cgTransform)
            cx = point1.x.doubleValue
            cy = point1.y.doubleValue

            let xScale = abs(transform.m11)
            let yScale = abs(transform.m22)
            if xScale == yScale {
                r *= xScale
            } else {
                print("SVG parsing error. No oval radial gradients supported")
            }

            let point2 = CGPoint(x: fx, y: fy).applying(cgTransform)
            fx = point2.x.doubleValue
            fy = point2.y.doubleValue
        }

        return RadialGradient(cx: cx, cy: cy, fx: fx, fy: fy, r: r, userSpace: userSpace, stops: stops)
    }

    fileprivate func parseStops(_ stops: [XMLIndexer], groupStyle: [String: String] = [:]) -> [Stop] {
        var result = [Stop]()
        stops.forEach { stopXML in
            if let stop = parseStop(stopXML, groupStyle: groupStyle) {
                result.append(stop)
            }
        }
        return result
    }

    fileprivate func parseStop(_ stop: XMLIndexer, groupStyle: [String: String] = [:]) -> Stop? {
        guard let element = stop.element else {
            return .none
        }
        guard let offset = getDoubleValueFromPercentage(element, attribute: "offset") else {
            return .none
        }

        var opacity: Double = 1
        if let stopOpacity = getStyleAttributes([:], element: element)["stop-opacity"], let doubleValue = Double(stopOpacity) {
            opacity = doubleValue
        }
        var color = Color.black.with(a: opacity)
        if var stopColor = getStyleAttributes([:], element: element)["stop-color"] {
            if stopColor == "currentColor", let currentColor = groupStyle["color"] {
                stopColor = currentColor
            }
            color = createColor(stopColor.replacingOccurrences(of: " ", with: ""), opacity: opacity)!
        }

        return Stop(offset: offset, color: color)
    }

    fileprivate func parsePath(_ path: XMLIndexer) -> Path? {
        if let d = path.element?.allAttributes["d"]?.text {
            return Path(segments: PathDataReader(input: d).read())
        }
        return .none
    }

    fileprivate func parseIdFromUrl(_ urlString: String) -> String? {
        if urlString.hasPrefix("url") {
            return urlString.substringWithOffset(fromStart: 5, fromEnd: 1)
        }
        return .none
    }

    fileprivate func getDoubleValue(_ element: SWXMLHash.XMLElement, attribute: String) -> Double? {
        guard let attributeValue = element.allAttributes[attribute]?.text else {
            return .none
        }
        return doubleFromString(attributeValue)
    }

    fileprivate func getDimensionValue(_ element: SWXMLHash.XMLElement, attribute: String) -> SVGLength? {
        guard let attributeValue = element.allAttributes[attribute]?.text else {
            return .none
        }
        return dimensionFromString(attributeValue)
    }

    fileprivate func dimensionFromString(_ string: String) -> SVGLength? {
        if let value = doubleFromString(string) {
            return SVGLength(pixels: value)
        }
        if string.hasSuffix("%") {
            return SVGLength(percent: Double(string.dropLast())!)
        }
        return .none
    }

    fileprivate func doubleFromString(_ string: String) -> Double? {
        if let doubleValue = Double(string) {
            return doubleValue
        }
        if string == "none" {
            return 0
        }
        guard let matcher = SVGParserRegexHelper.getUnitsIdenitifierMatcher() else {
            return .none
        }
        let fullRange = NSRange(location: 0, length: string.count)
        if let match = matcher.firstMatch(in: string, options: .reportCompletion, range: fullRange) {

            let unitString = (string as NSString).substring(with: match.range(at: 1))
            let numberString = String(string.dropLast(unitString.count))
            let value = Double(numberString)!
            switch unitString {
            case "px" :
                return value
            default:
                print("SVG parsing error. Unit \(unitString) not supported")
                return value
            }
        }
        return .none
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
        return attributes["font-family"]?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    fileprivate func getFontSize(_ attributes: [String: String]) -> Int? {
        guard let fontSize = attributes["font-size"], let size = doubleFromString(fontSize) else {
            return .none
        }
        return Int(round(size))
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

    fileprivate func getClipPath(_ attributes: [String: String], locus: Locus?) -> Locus? {
        if let clipPath = attributes["clip-path"], let id = parseIdFromUrl(clipPath) {
            if let userSpaceLocus = defClip[id] {
                if !userSpaceLocus.userSpace {
                    guard let locus = locus else {
                        return .none
                    }
                    let transform = BoundsUtils.transformForLocusInRespectiveCoords(respectiveLocus: userSpaceLocus.locus, absoluteLocus: locus)
                    return TransformedLocus(locus: userSpaceLocus.locus, transform: transform)
                }
                return userSpaceLocus.locus
            }
        }
        return .none
    }

    fileprivate func getMask(_ attributes: [String: String], locus: Locus?) throws -> Node? {
        guard let maskName = attributes["mask"], let id = parseIdFromUrl(maskName), let userSpaceNode = defMasks[id], let locus = locus else {
            return .none
        }
        if !userSpaceNode.userSpace {
            if let group = userSpaceNode.node as? Group {
                for node in group.contents {
                    if let shape = node as? Shape {
                        shape.place = BoundsUtils.transformForLocusInRespectiveCoords(respectiveLocus: shape.form, absoluteLocus: locus)
                    }
                }
                return group
            }
            if let shape = userSpaceNode.node as? Shape {
                shape.place = BoundsUtils.transformForLocusInRespectiveCoords(respectiveLocus: shape.form, absoluteLocus: locus)
                return shape
            } else {
                throw SVGParserError.maskUnsupportedNodeType
            }
        }
        return userSpaceNode.node
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

    fileprivate func getFillRule(_ attributes: [String: String]) -> FillRule? {
        if let rule = attributes["fill-rule"] {
            switch rule {
            case "nonzero":
                return .nonzero
            case "evenodd":
                return .evenodd
            default:
                return .none
            }
        }
        return .none
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
    private var previous: UnicodeScalar?
    private var iterator: String.UnicodeScalarView.Iterator

    init(input: String) {
        self.input = input
        self.iterator = input.unicodeScalars.makeIterator()
    }

    public func read() -> [PathSegment] {
        _ = readNext()
        var segments = [PathSegment]()
        while let array = readSegments() {
            segments.append(contentsOf: array)
        }
        return segments
    }

    private func readSegments() -> [PathSegment]? {
        if let type = readSegmentType() {
            let argCount = getArgCount(segment: type)
            if argCount == 0 {
                return [PathSegment(type: type)]
            }
            var result = [PathSegment]()
            let data = readData()
            var index = 0
            var isFirstSegment = true
            while index < data.count {
                let end = index + argCount
                if end > data.count {
                    // TODO need to generate error:
                    // "Path '\(type)' has invalid number of arguments: \(data.count)"
                    break
                }
                var currentType = type
                if type == .M && !isFirstSegment {
                    currentType = .L
                }
                if type == .m && !isFirstSegment {
                    currentType = .l
                }
                result.append(PathSegment(type: currentType, data: Array(data[index..<end])))
                isFirstSegment = false
                index = end
            }
            return result
        }
        return nil
    }

    private func readData() -> [Double] {
        var data = [Double]()
        while true {
            skipSpaces()
            if let value = readNum() {
                data.append(value)
            } else {
                return data
            }
        }
    }

    private func skipSpaces() {
        var ch = current
        while ch != nil && "\n\r\t ,".contains(String(ch!)) {
            ch = readNext()
        }
    }

    fileprivate func readNum() -> Double? {
        guard let ch = current else {
            return nil
        }
        if (ch >= "0" && ch <= "9") || ch == "." || ch == "-" {
            var chars = [ch]
            var hasDot = ch == "."
            while let ch = readDigit(&hasDot) {
                chars.append(ch)
            }
            var buf = ""
            buf.unicodeScalars.append(contentsOf: chars)
            return Double(buf)
        }
        return nil
    }

    fileprivate func readDigit(_ hasDot: inout Bool) -> UnicodeScalar? {
        if let ch = readNext() {
            if (ch >= "0" && ch <= "9") || ch == "e" || (previous == "e" && ch == "-") {
                return ch
            } else if ch == "." && !hasDot {
                hasDot = true
                return ch
            }
        }
        return nil
    }

    fileprivate func isNum(ch: UnicodeScalar, hasDot: inout Bool) -> Bool {
        switch ch {
        case "0"..."9":
            return true
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
        previous = current
        current = iterator.next()
        return current
    }

    private func isAcceptableSeparator(_ ch: UnicodeScalar?) -> Bool {
        if let ch = ch {
            return "\n\r\t ,".contains(String(ch))
        }
        return false
    }

    private func readSegmentType() -> PathSegmentType? {
        while true {
            if let type = getPathSegmentType() {
                _ = readNext()
                return type
            }
            if readNext() == nil {
                return nil
            }
        }
    }

    fileprivate func getPathSegmentType() -> PathSegmentType? {
        if let ch = current {
            switch ch {
            case "M":
                return .M
            case "m":
                return .m
            case "L":
                return .L
            case "l":
                return .l
            case "C":
                return .C
            case "c":
                return .c
            case "Q":
                return .Q
            case "q":
                return .q
            case "A":
                return .A
            case "a":
                return .a
            case "z", "Z":
                return .z
            case "H":
                return .H
            case "h":
                return .h
            case "V":
                return .V
            case "v":
                return .v
            case "S":
                return .S
            case "s":
                return .s
            case "T":
                return .T
            case "t":
                return .t
            default:
                break
            }
        }
        return nil
    }

    fileprivate func getArgCount(segment: PathSegmentType) -> Int {
        switch segment {
        case .H, .h, .V, .v:
            return 1
        case .M, .m, .L, .l, .T, .t:
            return 2
        case .S, .s, .Q, .q:
            return 4
        case .C, .c:
            return 6
        case .A, .a:
            return 7
        default:
            return 0
        }
    }

}

fileprivate extension String {
    func substringWithOffset(fromStart: Int, fromEnd: Int) -> String {
        let start = index(startIndex, offsetBy: fromStart)
        let end = index(endIndex, offsetBy: -fromEnd)
        return String(self[start..<end])
    }
}

fileprivate class UserSpaceLocus {
    let locus: Locus
    let userSpace: Bool

    init(locus: Locus, userSpace: Bool) {
        self.locus = locus
        self.userSpace = userSpace
    }
}

fileprivate class UserSpaceNode {
    let node: Node
    let userSpace: Bool

    init(node: Node, userSpace: Bool) {
        self.node = node
        self.userSpace = userSpace
    }
}

fileprivate class UserSpacePattern {
    let content: Node
    let bounds: Rect
    let userSpace: Bool
    let contentUserSpace: Bool

    init(content: Node, bounds: Rect, userSpace: Bool = false, contentUserSpace: Bool = true) {
        self.content = content
        self.bounds = bounds
        self.userSpace = userSpace
        self.contentUserSpace = contentUserSpace
    }
}
