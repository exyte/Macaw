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

    let availableStyleAttributes = ["stroke", "stroke-width", "stroke-opacity", "stroke-dasharray", "stroke-dashoffset", "stroke-linecap", "stroke-linejoin",
                                    "fill", "fill-rule", "text-anchor", "clip-path", "fill-opacity",
                                    "stop-color", "stop-opacity",
                                    "font-family", "font-size",
                                    "font-weight", "opacity", "color", "visibility"]

    fileprivate let xmlString: String
    fileprivate let initialPosition: Transform

    fileprivate var nodes = [Node]()
    fileprivate var defNodes = [String: XMLIndexer]()
    fileprivate var defFills = [String: Fill]()
    fileprivate var defMasks = [String: Shape]()
    fileprivate var defClip = [String: Locus]()
    fileprivate var defEffects = [String: Effect]()

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

        var layout: NodeLayout?
        for child in parsedXml.children {
            if let element = child.element {
                if element.name == "svg" {
                    layout = parseViewBox(element)
                    prepareSvg(child.children)
                    break
                }
            }
        }
        parseSvg(parsedXml.children)

        if let layout = layout {
            return SVGCanvas(layout: layout, contents: nodes)
        }
        return Group(contents: nodes)
    }

    fileprivate func prepareSvg(_ children: [XMLIndexer]) {
        children.forEach { child in
            prepareSvg(child)
        }
    }

    fileprivate func prepareSvg(_ node: XMLIndexer) {
        if let element = node.element {
            if element.name == "defs" {
                parseDefinitions(node)
            } else if element.name == "style" {
                parseStyle(node)
            } else if element.name == "g" {
                node.children.forEach { child in
                    prepareSvg(child)
                }
            }
        }
    }

    fileprivate func parseSvg(_ children: [XMLIndexer]) {
        children.forEach { child in
            if let element = child.element {
                if element.name == "svg" {
                    parseSvg(child.children)
                } else if let node = parseNode(child) {
                    self.nodes.append(node)
                }
            }
        }
    }

    fileprivate func parseViewBox(_ element: SWXMLHash.XMLElement) -> SVGNodeLayout {
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
            guard strings.count == 2 else { fatalError("Invalid content mode") }

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

    fileprivate func parseNode(_ node: XMLIndexer, groupStyle: [String: String] = [:]) -> Node? {
        if let element = node.element {
            switch element.name {
            case "g":
                return parseGroup(node, groupStyle: groupStyle)
            case "clipPath":
                if let id = element.allAttributes["id"]?.text, let clip = parseClip(node) {
                    self.defClip[id] = clip
                }
            case "style", "defs":
                // do nothing - it was parsed on first iteration
                return .none
            default:
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

    fileprivate func parseDefinitions(_ defs: XMLIndexer, groupStyle: [String: String] = [:]) {
        defs.children.forEach(parseDefinition(_:))
    }

    private func parseDefinition(_ child: XMLIndexer) {
        guard let id = child.element?.allAttributes["id"]?.text, let element = child.element else {
            return
        }

        if element.name == "fill", let fill = parseFill(child) {
            defFills[id] = fill
        } else if element.name == "mask", let mask = parseMask(child) {
            defMasks[id] = mask
        } else if element.name == "filter", let effect = parseEffect(child) {
            defEffects[id] = effect
        } else if element.name == "clip", let clip = parseClip(child) {
            defClip[id] = clip
        } else if let _ = parseNode(child) {
            // TODO we don't really need to parse node
            defNodes[id] = child
        }
    }

    fileprivate func parseElement(_ node: XMLIndexer, groupStyle: [String: String] = [:]) -> Node? {
        guard let element = node.element else {
            return .none
        }

        let nodeStyle = getStyleAttributes(groupStyle, element: element)
        if nodeStyle["display"] == "none" {
            return .none
        }
        if nodeStyle["visibility"] == "hidden" {
            return .none
        }

        guard let parsedNode = parseElementInternal(node, groupStyle: nodeStyle) else {
            return .none
        }

        if let filterString = element.allAttributes["filter"]?.text ?? nodeStyle["filter"], let filterId = parseIdFromUrl(filterString), let effect = defEffects[filterId] {
            parsedNode.effect = effect
        }

        return parsedNode
    }

    fileprivate func parseElementInternal(_ node: XMLIndexer, groupStyle: [String: String] = [:]) -> Node? {
        guard let element = node.element else {
            return .none
        }
        let id = node.element?.allAttributes["id"]?.text

        let styleAttributes = groupStyle
        let position = getPosition(element)
        switch element.name {
        case "path":
            if var path = parsePath(node) {
                if let rule = getFillRule(styleAttributes) {
                    path = Path(segments: path.segments, fillRule: rule)
                }
                return Shape(form: path, fill: getFillColor(styleAttributes, groupStyle: styleAttributes), stroke: getStroke(styleAttributes, groupStyle: styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
            }
        case "line":
            if let line = parseLine(node) {
                return Shape(form: line, fill: getFillColor(styleAttributes, groupStyle: styleAttributes), stroke: getStroke(styleAttributes, groupStyle: styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
            }
        case "rect":
            if let rect = parseRect(node) {
                return Shape(form: rect, fill: getFillColor(styleAttributes, groupStyle: styleAttributes), stroke: getStroke(styleAttributes, groupStyle: styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
            }
        case "circle":
            if let circle = parseCircle(node) {
                return Shape(form: circle, fill: getFillColor(styleAttributes, groupStyle: styleAttributes), stroke: getStroke(styleAttributes, groupStyle: styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
            }
        case "ellipse":
            if let ellipse = parseEllipse(node) {
                return Shape(form: ellipse, fill: getFillColor(styleAttributes, groupStyle: styleAttributes), stroke: getStroke(styleAttributes, groupStyle: styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
            }
        case "polygon":
            if let polygon = parsePolygon(node) {
                return Shape(form: polygon, fill: getFillColor(styleAttributes, groupStyle: styleAttributes), stroke: getStroke(styleAttributes, groupStyle: styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
            }
        case "polyline":
            if let polyline = parsePolyline(node) {
                return Shape(form: polyline, fill: getFillColor(styleAttributes, groupStyle: styleAttributes), stroke: getStroke(styleAttributes, groupStyle: styleAttributes), place: position, opacity: getOpacity(styleAttributes), clip: getClipPath(styleAttributes), tag: getTag(element))
            }
        case "image":
            return parseImage(node, opacity: getOpacity(styleAttributes), pos: position, clip: getClipPath(styleAttributes))
        case "text":
            return parseText(node, textAnchor: getTextAnchor(styleAttributes), fill: getFillColor(styleAttributes, groupStyle: styleAttributes),
                             stroke: getStroke(styleAttributes, groupStyle: styleAttributes), opacity: getOpacity(styleAttributes), fontName: getFontName(styleAttributes), fontSize: getFontSize(styleAttributes), fontWeight: getFontWeight(styleAttributes), pos: position)
        case "use":
            return parseUse(node, groupStyle: styleAttributes, place: position)
        case "linearGradient", "radialGradient", "fill":
            if let fill = parseFill(node), let id = id {
                defFills[id] = fill
            }
        case "filter":
            if let effect = parseEffect(node), let id = id {
                defEffects[id] = effect
            }
        case "mask":
            if let mask = parseMask(node), let id = id {
                defMasks[id] = mask
            }
        case "title":
            break
        default:
            print("SVG parsing error. Shape \(element.name) not supported")
            return .none
        }

        return .none
    }

    fileprivate func parseFill(_ fill: XMLIndexer) -> Fill? {
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

    fileprivate func parseGroup(_ group: XMLIndexer, groupStyle: [String: String] = [:]) -> Group? {
        guard let element = group.element else {
            return .none
        }
        var groupNodes: [Node] = []
        let style = getStyleAttributes(groupStyle, element: element)
        let position = getPosition(element)
        var mask: TransformedLocus?
        if let maskId = element.allAttributes["mask"]?.text
            .replacingOccurrences(of: "url(#", with: "")
            .replacingOccurrences(of: ")", with: "") {
            let maskShape = defMasks[maskId]
            mask = TransformedLocus(locus: maskShape!.form, transform: maskShape!.place)
        }
        group.children.forEach { child in
            if let node = parseNode(child, groupStyle: style) {
                groupNodes.append(node)
            }
        }
        return Group(contents: groupNodes, place: position, clip: mask, tag: getTag(element))
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
            if let styleAttribute = element.allAttributes[availableAttribute]?.text, styleAttribute != "inherit" {
                styleAttributes.updateValue(styleAttribute, forKey: availableAttribute)
            }
        }

        return styleAttributes
    }

    fileprivate func createColor(_ hexString: String, opacity: Double = 1) -> Color {
        let opacity = min(max(opacity, 0), 1)
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

    fileprivate func getFillColor(_ styleParts: [String: String], groupStyle: [String: String] = [:]) -> Fill? {
        guard var fillColor = styleParts["fill"] else {
            return Color.black
        }
        if fillColor == "none" || fillColor == "transparent" {
            return .none
        }
        if fillColor == "currentColor", let currentColor = groupStyle["color"] {
            fillColor = currentColor
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
        } else if let colorId = parseIdFromUrl(fillColor) {
            return defFills[colorId]
        } else {
            return createColor(fillColor.replacingOccurrences(of: " ", with: ""), opacity: opacity)
        }
    }

    fileprivate func getStroke(_ styleParts: [String: String], groupStyle: [String: String] = [:]) -> Stroke? {
        guard var strokeColor = styleParts["stroke"] else {
            return .none
        }
        if strokeColor == "none" {
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
        if let defaultColor = SVGConstants.colorList[strokeColor] {
            let color = Color(val: defaultColor)
            fill = color.with(a: opacity)
        } else if strokeColor.hasPrefix("rgb") {
            fill = parseRGBNotation(colorString: strokeColor)
        } else if let colorId = parseIdFromUrl(strokeColor) {
            fill = defFills[colorId]
        } else {
            fill = createColor(strokeColor.replacingOccurrences(of: " ", with: ""), opacity: opacity)
        }

        if let strokeFill = fill {
            return Stroke(fill: strokeFill,
                          width: getStrokeWidth(styleParts),
                          cap: getStrokeCap(styleParts),
                          join: getStrokeJoin(styleParts),
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
            var characterSet = CharacterSet()
            characterSet.insert(" ")
            characterSet.insert(",")
            let separatedValues = strokeDashes.components(separatedBy: characterSet)
            separatedValues.forEach { value in
                if let doubleValue = doubleFromString(value) {
                    dashes.append(doubleValue)
                }
            }
        }
        return dashes
    }

    fileprivate func getStrokeOffset(_ styleParts: [String: String]) -> Double {
        if let strokeOffset = styleParts["stroke-dashoffset"], let offset = Double(strokeOffset) { // TODO use doubleFromString once it's merged
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
            } else if anchor == "end" {
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
            return collectTspans(fullString.substring(from: closingTagRange.location + closingTagRange.length), collectedTspans: collection, withWhitespace: withWhitespace, textAnchor: textAnchor, fill: fill, stroke: stroke, opacity: opacity, fontName: fontName, fontSize: fontSize, fontWeight: fontWeight, bounds: Rect(x: bounds.x, y: bounds.y, w: bounds.w + text.bounds().w, h: bounds.h))
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
        if tagRange.location >= fullString.length { // leave recursion
            return collection
        }
        return collectTspans(fullString.substring(from: tagRange.location), collectedTspans: collection,
                             withWhitespace: nextStringWhitespace, textAnchor: textAnchor, fill: fill, stroke: stroke,
                             opacity: opacity, fontName: fontName, fontSize: fontSize, fontWeight: fontWeight, bounds: Rect(x: bounds.x, y: bounds.y, w: bounds.w + text.bounds().w, h: bounds.h))
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
                    fill: ((attributes["fill"] != nil) ? getFillColor(attributes)! : fill) ?? Color.black, stroke: stroke ?? getStroke(attributes),
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
                node.place = place.move(dx: getDoubleValue(element, attribute: "x") ?? 0, dy: getDoubleValue(element, attribute: "y") ?? 0)
                return node
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

    fileprivate func parseEffect(_ filterNode: XMLIndexer) -> Effect? {
        let defaultSource = "SourceGraphic"
        var effects = [String: Effect]()
        for child in filterNode.children.reversed() {
            guard let element = child.element else { continue }

            let filterIn = element.allAttributes["in"]?.text ?? defaultSource
            let filterOut = element.allAttributes["result"]?.text ?? ""
            let currentEffect = effects[filterOut]
            effects.removeValue(forKey: filterOut)

            switch element.name {
            case "feOffset":
                if let dx = getDoubleValue(element, attribute: "dx"), let dy = getDoubleValue(element, attribute: "dy") {
                    effects[filterIn] = OffsetEffect(dx: dx, dy: dy, input: currentEffect)
                }
            case "feGaussianBlur":
                if let radius = getDoubleValue(element, attribute: "stdDeviation") {
                    effects[filterIn] = GaussianBlur(radius: radius, input: currentEffect)
                }
            case "feBlend":
                if let filterIn2 = element.allAttributes["in2"]?.text {
                    if filterIn2 == defaultSource {
                        effects[filterIn] = nil
                    } else if filterIn == defaultSource {
                        effects[filterIn2] = nil
                    }
                }
            default:
                print("SVG parsing error. Filter \(element.name) not supported")
                continue
            }
        }
        return effects.first?.value
    }

    fileprivate func parseMask(_ mask: XMLIndexer) -> Shape? {
        guard let element = mask.element else {
            return .none
        }
        var node: Node?
        mask.children.forEach { indexer in
            let position = getPosition(indexer.element!)
            if let useNode = parseUse(indexer, place: position) {
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
            maskShape = Shape(form: shape.form, place: node!.place, tag: getTag(element))
        }
        let maskStyleAttributes = getStyleAttributes([:], element: element)
        maskShape.fill = getFillColor(maskStyleAttributes)

        if let id = mask.element?.allAttributes["id"]?.text {
            maskShape.place = node!.place
            defMasks[id] = maskShape
            return .none
        }

        return maskShape
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
        let r = getDoubleValueFromPercentage(element, attribute: "r") ?? parentRadialGradient?.r ?? 0.5

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
        var color = Color.black
        if var stopColor = getStyleAttributes([:], element: element)["stop-color"] {
            if stopColor == "currentColor", let currentColor = groupStyle["color"] {
                stopColor = currentColor
            }
            if let defaultColor = SVGConstants.colorList[stopColor] {
                color = Color(val: defaultColor).with(a: opacity)
            } else {
                color = createColor(stopColor.replacingOccurrences(of: " ", with: ""), opacity: opacity)
            }

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

    fileprivate func getClipPath(_ attributes: [String: String]) -> Locus? {
        if let clipPath = attributes["clip-path"], let id = parseIdFromUrl(clipPath) {
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
            while !isNumStart() {
                if getPathSegmentType() != nil || readNext() == nil {
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

    fileprivate func isNumStart() -> Bool {
        if let ch = current {
            return (ch >= "0" && ch <= "9") || ch == "." || ch == "-"
        }
        return false
    }

}

fileprivate extension String {
    func substringWithOffset(fromStart: Int, fromEnd: Int) -> String {
        let start = index(startIndex, offsetBy: fromStart)
        let end = index(endIndex, offsetBy: -fromEnd)
        return String(self[start..<end])
    }
}
