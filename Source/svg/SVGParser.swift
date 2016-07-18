import Foundation
import SWXMLHash

public class SVGParser {

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
    let closePathAbsolute = Character("Z")
    let closePathRelative = Character("z")
    let availableStyleAttributes = ["stroke", "stroke-width", "fill"]

    private let xmlString: String
    private let initialPosition: Transform

    private var nodes = [Node]()

    private enum PathCommandType {
        case MoveTo
        case LineTo
        case LineV
        case LineH
        case CurveTo
        case ClosePath
        case None
    }

    private typealias PathCommand = (type: PathCommandType, expression: String, absolute: Bool)

    public init(_ string: String, pos: Transform = Transform()) {
        self.xmlString = string
        self.initialPosition = pos
    }

    public func parse() -> Group {
        let parsedXml = SWXMLHash.parse(xmlString)
        iterateThroughXmlTree(parsedXml.children)

        let group = Group(contents: self.nodes)
        return group
    }

    private func iterateThroughXmlTree(children: [XMLIndexer]) {
        children.forEach { child in
            if let element = child.element {
                if element.name == "svg" {
                    iterateThroughXmlTree(child.children)
                } else if let node = parseNode(child, groupPosition: self.initialPosition) {
                    self.nodes.append(node)
                }
            }
        }
    }

    private func parseNode(node: XMLIndexer, groupStyle: [String: String] = [:], groupPosition: Transform = Transform()) -> Node? {
        if let element = node.element {
            if node.children.isEmpty {
                return parseShape(node, groupStyle: groupStyle, groupPosition: groupPosition)
            } else if element.name == "g" {
                return parseGroup(node, groupStyle: groupStyle, groupPosition: groupPosition)
            }
        }
        return .None
    }

    private func parseShape(shape: XMLIndexer, groupStyle: [String: String] = [:], groupPosition: Transform = Transform()) -> Shape? {
        if let element = shape.element {
            let styleAttributes = getStyleAttributes(groupStyle, element: element)
            let position = getPosition(groupPosition, element: element)
            switch element.name {
            case "path":
                if let path = parsePath(shape) {
                    return Shape(form: path, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), pos: position)
                }
            case "line":
                if let line = parseLine(shape) {
                    return Shape(form: line, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), pos: position)
                }
            case "rect":
                if let rect = parseRect(shape) {
                    return Shape(form: rect, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), pos: position)
                }
            case "circle":
                if let circle = parseCircle(shape) {
                    return Shape(form: circle, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), pos: position)
                }
            case "ellipse":
                if let ellipse = parseEllipse(shape) {
                    return Shape(form: ellipse, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), pos: position)
                }
            case "polygon":
                if let polygon = parsePolygon(shape) {
                    return Shape(form: polygon, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), pos: position)
                }
            case "polyline":
                if let polyline = parsePolyline(shape) {
                    return Shape(form: polyline, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), pos: position)
                }
            default:
                print("SVG parsing error. Shape \(element.name) not supported")
                return .None
            }
        }
        return .None
    }

    private func parseGroup(group: XMLIndexer, groupStyle: [String: String] = [:], groupPosition: Transform = Transform()) -> Group? {
        guard let element = group.element else {
            return .None
        }
        var groupNodes: [Node] = []
        let style = getStyleAttributes(groupStyle, element: element)
        let position = getPosition(groupPosition, element: element)
        group.children.forEach { child in
            if let node = parseNode(child, groupStyle: style, groupPosition: position) {
                groupNodes.append(node)
            }
        }
        return Group(contents: groupNodes)
    }
    
    private func getPosition(groupPosition: Transform = Transform(), element: XMLElement) -> Transform {
        guard let transformAttribute = element.attributes["transform"] else {
            return groupPosition
        }
        return parseTransformationAttribute(transformAttribute, transform: groupPosition)
    }
    
    private func parseTransformationAttribute(attributes: String, transform: Transform) -> Transform {
        do {
            var finalTransform = transform
            let transformPattern = "([a-z]+)\\(((\\d+\\.?\\d*\\s*,?\\s*)+)\\)"
            let matcher = try NSRegularExpression(pattern: transformPattern, options: .CaseInsensitive)
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
                        finalTransform = transform.move(x, my: y)
                    }
                case "scale":
                    if let x = Double(values[0]) {
                        var y: Double = x
                        if values.indices.contains(1) {
                            y = Double(values[1]) ?? x
                        }
                        finalTransform = transform.scale(x, sy: y)
                    }
                case "rotate":
                    if let angle = Double(values[0]) {
                        if values.count == 1 {
                            finalTransform = transform.rotate(angle)
                        } else if values.count == 3 {
                            if let x = Double(values[1]), y = Double(values[2]) {
                                finalTransform = transform.move(x, my: y).rotate(angle).move(-x, my: -y)
                            }
                        }
                    }
                case "skewX":
                    if let x = Double(values[0]) {
                        finalTransform = transform.shear(x, shy: 0)
                    }
                case "skewY":
                    if let y = Double(values[0]) {
                        finalTransform = transform.shear(0, shy: y)
                    }
                case "matrix":
                    if values.count != 6 {
                        return transform
                    }
                    if let m11 = Double(values[0]), m12 = Double(values[1]),
                        m21 = Double(values[2]), m22 = Double(values[3]),
                        dx = Double(values[4]), dy = Double(values[5]) {
                        
                        let transformMatrix = Transform(m11: m11, m12: m12, m21: m21, m22: m22, dx: dx, dy: dy)
                        finalTransform = concat(transform, t2: transformMatrix)
                    }
                default: break
                }
                let rangeToRemove = NSRange(location: 0, length: matchedAttribute.range.location + matchedAttribute.range.length)
                let newAttributeString = (attributes as NSString).stringByReplacingCharactersInRange(rangeToRemove, withString: "")
                return parseTransformationAttribute(newAttributeString, transform: finalTransform)
            } else {
                return transform
            }
        } catch {
            return transform
        }
    }
    
    private func parseTransformValues(values: String, collectedValues: [String] = []) -> [String] {
        var updatedValues: [String] = collectedValues
        do {
            let pattern = "\\d+\\.?\\d*"
            let matcher = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let fullRange = NSRange(location: 0, length: values.characters.count)
            if let matchedValue = matcher.firstMatchInString(values, options: .ReportCompletion, range: fullRange) {
                let value = (values as NSString).substringWithRange(matchedValue.range)
                updatedValues.append(value)
                let rangeToRemove = NSRange(location: 0, length: matchedValue.range.location + matchedValue.range.length)
                let newValues = (values as NSString).stringByReplacingCharactersInRange(rangeToRemove, withString: "")
                return parseTransformValues(newValues, collectedValues: updatedValues)
            }
        } catch {
            
        }
        return updatedValues
    }

    private func getStyleAttributes(groupAttributes: [String: String], element: XMLElement) -> [String: String] {
        var styleAttributes: [String: String] = groupAttributes
        if let style = element.attributes["style"] {
            let styleParts = style.componentsSeparatedByString(";")
            styleParts.forEach { styleAttribute in
                let currentStyle = styleAttribute.componentsSeparatedByString(":")
                if currentStyle.count == 2 {
                    styleAttributes.updateValue(currentStyle[1], forKey: currentStyle[0].stringByReplacingOccurrencesOfString(" ", withString: ""))
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

    private func createColor(hexString: String) -> Color {
        var cleanedHexString = hexString
        if hexString.hasPrefix("#") {
            cleanedHexString = hexString.stringByReplacingOccurrencesOfString("#", withString: "")
        }

        var rgbValue: UInt32 = 0
        NSScanner(string: cleanedHexString).scanHexInt(&rgbValue)

        let red = CGFloat((rgbValue >> 16) & 0xff)
        let green = CGFloat((rgbValue >> 08) & 0xff)
        let blue = CGFloat((rgbValue >> 00) & 0xff)

        return Color.rgb(Int(red), g: Int(green), b: Int(blue))
    }

    private func getFillColor(styleParts: [String: String]) -> Color? {
        var color: Color?
        if let fillColor = styleParts["fill"] {
            color = createColor(fillColor.stringByReplacingOccurrencesOfString(" ", withString: ""))
        }
        return color
    }

    private func getStroke(styleParts: [String: String]) -> Stroke? {
        var color: Color?
        if let strokeColor = styleParts["stroke"] {
            color = createColor(strokeColor.stringByReplacingOccurrencesOfString(" ", withString: ""))
        }
        if let strokeColor = color {
            return Stroke(fill: strokeColor,
                width: getStrokeWidth(styleParts),
                cap: .round,
                join: .round)
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

    private func parseLine(line: XMLIndexer) -> Line? {
        guard let element = line.element else {
            return .None
        }

        if let x1Attr = element.attributes["x1"],
            x2Attr = element.attributes["x2"],
            y1Attr = element.attributes["y1"],
            y2Attr = element.attributes["y2"],

            // Doubles
            x1 = Double(x1Attr),
            x2 = Double(x2Attr),
            y1 = Double(y1Attr),
            y2 = Double(y2Attr) {

                return Line(x1: x1, y1: y1, x2: x2, y2: y2)
        }

        return .None
    }

    private func parseRect(rect: XMLIndexer) -> Locus? {
        guard let element = rect.element else {
            return .None
        }

        if let widthAttr = element.attributes["width"],
            heightAttr = element.attributes["height"],

            // Doubles
            width = Double(widthAttr),
            height = Double(heightAttr) {

                var attributes: [String: Double] = [:]
                if let xAttr = element.attributes["x"], x = Double(xAttr) {
                    attributes["x"] = x
                }
                if let yAttr = element.attributes["y"], y = Double(yAttr) {
                    attributes["y"] = y
                }
                if let rxAttr = element.attributes["rx"], rx = Double(rxAttr) {
                    attributes["rx"] = rx
                }
                if let ryAttr = element.attributes["ry"], ry = Double(ryAttr) {
                    attributes["ry"] = ry
                }
                let resultRect = Rect(
                    x: attributes["x"] ?? 0,
                    y: attributes["y"] ?? 0,
                    w: width, h: height)

                if attributes["rx"] != nil || attributes["ry"] != nil {

                    return RoundRect(rect: resultRect,
                        rx: attributes["rx"] ?? 0,
                        ry: attributes["ry"] ?? 0)
                }

                return resultRect
        }

        return .None
    }

    private func parseCircle(circle: XMLIndexer) -> Circle? {
        guard let element = circle.element else {
            return .None
        }

        if let rAttr = element.attributes["r"],
            r = Double(rAttr) {

                var cx: Double = 0
                var cy: Double = 0
                if let cxAttr = element.attributes["cx"], circleX = Double(cxAttr) {
                    cx = circleX
                }
                if let cyAttr = element.attributes["cy"], circleY = Double(cyAttr) {
                    cy = circleY
                }

                return Circle(cx: cx, cy: cy, r: r)
        }

        return .None
    }

    private func parseEllipse(ellipse: XMLIndexer) -> Ellipse? {
        guard let element = ellipse.element else {
            return .None
        }

        if let rxAttr = element.attributes["rx"],
            ryAttr = element.attributes["ry"],

            // Doubles
            rx = Double(rxAttr),
            ry = Double(ryAttr) {

                var cx: Double = 0
                var cy: Double = 0
                if let cxAttr = element.attributes["cx"], ellipseX = Double(cxAttr) {
                    cx = ellipseX
                }
                if let cyAttr = element.attributes["cy"], ellipseY = Double(cyAttr) {
                    cy = ellipseY
                }

                return Ellipse(cx: cx, cy: cy, rx: rx, ry: ry)
        }

        return .None
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

            return Move(x: x, y: y, absolute: command.absolute)

        case .LineTo:
            if commandParams.count < 2 {
                return .None
            }

            guard let x = Double(separatedValues[0]), y = Double(separatedValues[1]) else {
                return .None
            }

            return PLine(x: x, y: y, absolute: command.absolute)

        case .LineH:
            if separatedValues.count < 1 {
                return .None
            }

            guard let x = Double(separatedValues[0]) else {
                return .None
            }

            return HLine(x: x, absolute: command.absolute)

        case .LineV:
            if separatedValues.count < 1 {
                return .None
            }

            guard let y = Double(separatedValues[0]) else {
                return .None
            }

            return VLine(y: y, absolute: command.absolute)

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

            return Cubic(x1: x1, y1: y1, x2: x2, y2: y2, x: x, y: y, absolute: command.absolute)

        case .ClosePath:
            return Close()
        default:
            return .None
        }
    }

    private func separateNegativeValuesIfNeeded(expression: String) -> [String] {
        var values = [String]()
        var value = String()

        expression.characters.forEach { c in
            if c == "-" {
                if value.characters.count != 0 {
                    values.append(value)
                    value = String()
                }
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
        case closePathAbsolute:
            return .ClosePath
        case closePathRelative:
            return .ClosePath
        default:
            return .None
        }
    }
    
    private func concat(t1: Transform, t2: Transform) -> Transform {
        let nm11 = t2.m11 * t1.m11 + t2.m12 * t1.m21
        let nm21 = t2.m21 * t1.m11 + t2.m22 * t1.m21
        let ndx = t2.dx * t1.m11 + t2.dy * t1.m21 + t1.dx
        let nm12 = t2.m11 * t1.m12 + t2.m12 * t1.m22
        let nm22 = t2.m21 * t1.m12 + t2.m22 * t1.m22
        let ndy = t2.dx * t1.m12 + t2.dy * t1.m22 + t1.dy
        return Transform(m11: nm11, m12: nm12, m21: nm21, m22: nm22, dx: ndx, dy: ndy)
    }
}
