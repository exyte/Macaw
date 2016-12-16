import Foundation
import SWXMLHash
import CoreGraphics

///
/// This class used to parse SVG file and build corresponding Macaw scene
///
open class SVGParser {

    /// Parse an SVG file identified by the specified bundle, name and file extension.
    /// - returns: Root node of the corresponding Macaw scene.
    open class func parse(bundle: Bundle, path: String, ofType: String = "svg") -> Node? {
        guard let path = bundle.path(forResource: path, ofType: ofType) else {
            return .none
        }
        do {
            let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            return SVGParser.parse(text: text)
        } catch _ {
            return .none
        }
    }
    
    /// Parse an SVG file identified by the specified name and file extension.
    /// - returns: Root node of the corresponding Macaw scene.
    open class func parse(path: String, ofType: String = "svg") -> Node? {
        return SVGParser.parse(bundle: Bundle.main, path: path, ofType: ofType)
    }
    
    /// Parse the specified content of an SVG file.
    /// - returns: Root node of the corresponding Macaw scene.
    open class func parse(text: String) -> Node {
        return SVGParser(text).parse()
    }
    
	let availableStyleAttributes = ["stroke", "stroke-width", "stroke-opacity", "stroke-dasharray", "stroke-linecap", "stroke-linejoin",
		"fill", "fill-opacity",
		"stop-color", "stop-opacity",
		"font-family", "font-size",
		"opacity"]

	fileprivate let xmlString: String
	fileprivate let initialPosition: Transform

	fileprivate var nodes = [Node]()
	fileprivate var defNodes = [String: Node]()
	fileprivate var defFills = [String: Fill]()
    fileprivate var defMasks = [String: Shape]()

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
			} else if element.name == "defs" {
				parseDefinitions(node)
			} else {
				return parseElement(node, groupStyle: groupStyle)
			}
		}
		return .none
	}

	fileprivate func parseDefinitions(_ defs: XMLIndexer) {
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
                continue
			}
            if let mask = parseMask(child) {
                self.defMasks[id] = mask
                continue
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
					return Shape(form: path, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes))
				}
			case "line":
				if let line = parseLine(node) {
					return Shape(form: line, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes))
				}
			case "rect":
				if let rect = parseRect(node) {
					return Shape(form: rect, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes))
				}
			case "circle":
				if let circle = parseCircle(node) {
					return Shape(form: circle, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), place: position, opacity: getOpacity(styleAttributes))
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
				return parseUse(node, fill: getFillColor(styleAttributes), stroke: getStroke(styleAttributes), pos: position, opacity: getOpacity(styleAttributes))
            case "mask":
                return parseMask(node)
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
        return Group(contents: groupNodes, place: position)
	}
    
    fileprivate func getMask(mask: String) -> Locus? {
        if let maskIdenitifierMatcher = SVGParserRegexHelper.getMaskIdenitifierMatcher() {
            let fullRange = NSMakeRange(0, mask.characters.count)
            if let match = maskIdenitifierMatcher.firstMatch(in: mask, options: .reportCompletion, range: fullRange), let maskReferenceNode = self.defMasks[(mask as NSString).substring(with: match.rangeAt(1))] {
                return maskReferenceNode.form
            }
        }
        return .none
    }

	fileprivate func getPosition(_ element: XMLElement) -> Transform {
		guard let transformAttribute = element.attributes["transform"] else {
			return Transform()
		}
		return parseTransformationAttribute(transformAttribute)
	}

	fileprivate func parseTransformationAttribute(_ attributes: String, transform: Transform = Transform()) -> Transform {
		guard let matcher = SVGParserRegexHelper.getTransformAttributeMatcher() else {
			return transform
		}
		var finalTransform = transform
		let fullRange = NSRange(location: 0, length: attributes.characters.count)
		if let matchedAttribute = matcher.firstMatch(in: attributes, options: .reportCompletion, range: fullRange) {
			let attributeName = (attributes as NSString).substring(with: matchedAttribute.rangeAt(1))
			let values = parseTransformValues((attributes as NSString).substring(with: matchedAttribute.rangeAt(2)))
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
				if let m11 = Double(values[0]), let m12 = Double(values[1]),
					let m21 = Double(values[2]), let m22 = Double(values[3]),
					let dx = Double(values[4]), let dy = Double(values[5]) {

						let transformMatrix = Transform(m11: m11, m12: m12, m21: m21, m22: m22, dx: dx, dy: dy)
						finalTransform = GeomUtils.concat(t1: transform, t2: transformMatrix)
				}
			default: break
			}
			let rangeToRemove = NSRange(location: 0, length: matchedAttribute.range.location + matchedAttribute.range.length)
			let newAttributeString = (attributes as NSString).replacingCharacters(in: rangeToRemove, with: "")
			return parseTransformationAttribute(newAttributeString, transform: finalTransform)
		} else {
			return transform
		}
	}

	fileprivate func parseTransformValues(_ values: String, collectedValues: [String] = []) -> [String] {
		guard let matcher = SVGParserRegexHelper.getTransformMatcher() else {
			return collectedValues
		}
		var updatedValues: [String] = collectedValues
		let fullRange = NSRange(location: 0, length: values.characters.count)
		if let matchedValue = matcher.firstMatch(in: values, options: .reportCompletion, range: fullRange) {
			let value = (values as NSString).substring(with: matchedValue.range)
			updatedValues.append(value)
			let rangeToRemove = NSRange(location: 0, length: matchedValue.range.location + matchedValue.range.length)
			let newValues = (values as NSString).replacingCharacters(in: rangeToRemove, with: "")
			return parseTransformValues(newValues, collectedValues: updatedValues)
		}
		return updatedValues
	}

	fileprivate func getStyleAttributes(_ groupAttributes: [String: String], element: XMLElement) -> [String: String] {
		var styleAttributes: [String: String] = groupAttributes
		if let style = element.attributes["style"] {
            
			let styleParts = style.replacingOccurrences(of: " ", with: "").components(separatedBy: ";")
			styleParts.forEach { styleAttribute in
				let currentStyle = styleAttribute.components(separatedBy: ":")
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

	fileprivate func createColor(_ hexString: String, opacity: Double = 1) -> Color {
		var cleanedHexString = hexString
		if hexString.hasPrefix("#") {
			cleanedHexString = hexString.replacingOccurrences(of: "#", with: "")
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
		if fillColor == "none" {
			return .none
		}
		var opacity: Double = 1
		if let fillOpacity = styleParts["fill-opacity"] {
			opacity = Double(fillOpacity.replacingOccurrences(of: " ", with: "")) ?? 1
		}
        if let defaultColor = SVGConstants.colorList[fillColor] {
            return Color(val: defaultColor)
        }
		if fillColor.hasPrefix("url") {
			let index = fillColor.characters.index(fillColor.startIndex, offsetBy: 4)
			let id = fillColor.substring(from: index)
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
		if strokeColor.hasPrefix("url") {
			let index = strokeColor.characters.index(strokeColor.startIndex, offsetBy: 4)
			let id = strokeColor.substring(from: index)
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
            let digits = digitsArray.joined(separator: "")
            if let value = NumberFormatter().number(from: digits) {
                return value.doubleValue
            }
		}
        return 1
	}

	fileprivate func getStrokeCap(_ styleParts: [String: String]) -> LineCap {
		var cap = LineCap.square
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
			let height = getDoubleValue(element, attribute: "height")
		, width > 0 && height > 0 else {

			return .none
		}

		let resultRect = Rect(x: getDoubleValue(element, attribute: "x") ?? 0, y: getDoubleValue(element, attribute: "y") ?? 0, w: width, h: height)

		let rxOpt = getDoubleValue(element, attribute: "rx")
		let ryOpt = getDoubleValue(element, attribute: "ry")
		if let rx = rxOpt, let ry = ryOpt {
			return RoundRect(rect: resultRect, rx: rx, ry: ry)
		}
		let rOpt = rxOpt ?? ryOpt
		if let r = rOpt , r >= 0 {
			return RoundRect(rect: resultRect, rx: r, ry: r)
		}
		return resultRect
	}

	fileprivate func parseCircle(_ circle: XMLIndexer) -> Circle? {
		guard let element = circle.element, let r = getDoubleValue(element, attribute: "r") , r > 0 else {
			return .none
		}

		return Circle(cx: getDoubleValue(element, attribute: "cx") ?? 0, cy: getDoubleValue(element, attribute: "cy") ?? 0, r: r)
	}

	fileprivate func parseEllipse(_ ellipse: XMLIndexer) -> Arc? {
		guard let element = ellipse.element,
			let rx = getDoubleValue(element, attribute: "rx"),
			let ry = getDoubleValue(element, attribute: "ry")
		, rx > 0 && ry > 0 else {
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

		if let points = element.attributes["points"] {
			return Polygon(points: parsePoints(points))
		}

		return .none
	}

	fileprivate func parsePolyline(_ polyline: XMLIndexer) -> Polyline? {
		guard let element = polyline.element else {
			return .none
		}

		if let points = element.attributes["points"] {
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

	fileprivate func parseImage(_ image: XMLIndexer, opacity: Double, pos: Transform = Transform()) -> Image? {
		guard let element = image.element, let link = element.attributes["xlink:href"] else {
			return .none
		}
		let position = pos.move(dx: getDoubleValue(element, attribute: "x") ?? 0, dy: getDoubleValue(element, attribute: "y") ?? 0)
		return Image(src: link, w: getIntValue(element, attribute: "width") ?? 0, h: getIntValue(element, attribute: "height") ?? 0, place: position)
	}

	fileprivate func parseText(_ text: XMLIndexer, fill: Fill?, opacity: Double, fontName: String?, fontSize: Int?,
		pos: Transform = Transform()) -> Node? {
			guard let element = text.element else {
				return .none
			}
			if text.children.isEmpty {
				return parseSimpleText(element, fill: fill, opacity: opacity, fontName: fontName, fontSize: fontSize)
			} else {
				guard let matcher = SVGParserRegexHelper.getTextElementMatcher() else {
					return .none
				}
				let elementString = element.description
				let fullRange = NSMakeRange(0, elementString.characters.count)
				if let match = matcher.firstMatch(in: elementString, options: .reportCompletion, range: fullRange) {
					let tspans = (elementString as NSString).substring(with: match.rangeAt(1))
					return Group(contents: collectTspans(tspans, fill: fill, opacity: opacity, fontName: fontName, fontSize: fontSize,
						bounds: Rect(x: getDoubleValue(element, attribute: "x") ?? 0, y: getDoubleValue(element, attribute: "y") ?? 0)),
						place: pos)
				}
			}
			return .none
	}

	fileprivate func parseSimpleText(_ text: XMLElement, fill: Fill?, opacity: Double, fontName: String?, fontSize: Int?, pos: Transform = Transform()) -> Text? {
		guard let string = text.text else {
			return .none
		}
		let position = pos.move(dx: getDoubleValue(text, attribute: "x") ?? 0, dy: getDoubleValue(text, attribute: "y") ?? 0)
		return Text(text: string, font: getFont(fontName: fontName, fontSize: fontSize), fill: fill ?? Color.black, place: position, opacity: opacity)
	}

	// REFACTOR

	fileprivate func collectTspans(_ tspan: String, collectedTspans: [Node] = [], withWhitespace: Bool = false, fill: Fill?, opacity: Double, fontName: String?, fontSize: Int?, bounds: Rect) -> [Node] {
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
				let text = parseTspan(indexer, withWhitespace: withWhitespace, fill: fill, opacity: opacity, fontName: fontName, fontSize: fontSize, bounds: bounds) else {

					// skip this element if it can't be parsed
					return collectTspans(fullString.substring(from: closingTagRange.location + closingTagRange.length), collectedTspans: collectedTspans, fill: fill, opacity: opacity,
						fontName: fontName, fontSize: fontSize, bounds: bounds)
			}
			collection.append(text)
			let nextString = fullString.substring(from: closingTagRange.location + closingTagRange.length) as NSString
			var withWhitespace = false
			if nextString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location == 0 {
				withWhitespace = true
			}
			return collectTspans(fullString.substring(from: closingTagRange.location + closingTagRange.length), collectedTspans: collection, withWhitespace: withWhitespace, fill: fill, opacity: opacity, fontName: fontName, fontSize: fontSize, bounds: text.bounds())
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
		if trimmedString.characters.count != textString.length {
			nextStringWhitespace = true
		}
		trimmedString = withWhitespace ? " \(trimmedString)" : trimmedString
		let text = Text(text: trimmedString, font: getFont(fontName: fontName, fontSize: fontSize),
			fill: fill ?? Color.black, baseline: .alphabetic,
			place: Transform().move(dx: bounds.x + bounds.w, dy: bounds.y), opacity: opacity)
		collection.append(text)
		return collectTspans(fullString.substring(from: tagRange.location), collectedTspans: collection, withWhitespace: nextStringWhitespace, fill: fill, opacity: opacity,
			fontName: fontName, fontSize: fontSize, bounds: text.bounds())
	}

	fileprivate func parseTspan(_ tspan: XMLIndexer, withWhitespace: Bool = false, fill: Fill?, opacity: Double, fontName: String?,
		fontSize: Int?, bounds: Rect) -> Text? {

			guard let element = tspan.element, let string = element.text else {
				return .none
			}
			var shouldAddWhitespace = withWhitespace
			let pos = getTspanPosition(element, bounds: bounds, withWhitespace: &shouldAddWhitespace)
			let text = shouldAddWhitespace ? " \(string)" : string
			let attributes = getStyleAttributes([:], element: element)

			return Text(text: text, font: getFont(attributes, fontName: fontName, fontSize: fontSize),
				fill: fill ?? getFillColor(attributes) ?? Color.black, baseline: .alphabetic,
				place: pos, opacity: getOpacity(attributes) ?? opacity)
	}

	fileprivate func getFont(_ attributes: [String: String] = [:], fontName: String?, fontSize: Int?) -> Font {
		return Font(
			name: getFontName(attributes) ?? fontName ?? "Serif",
			size: getFontSize(attributes) ?? fontSize ?? 12)
	}

	fileprivate func getTspanPosition(_ element: XMLElement, bounds: Rect, withWhitespace: inout Bool) -> Transform {
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

	fileprivate func parseUse(_ use: XMLIndexer, fill: Fill?, stroke: Stroke?, pos: Transform, opacity: Double) -> Node? {
		guard let element = use.element, let link = element.attributes["xlink:href"] else {
			return .none
		}
		var id = link
		if id.hasPrefix("#") {
			id = id.replacingOccurrences(of: "#", with: "")
		}
		guard let referenceNode = self.defNodes[id], let node = copyNode(referenceNode) else {
			return .none
		}
		node.place = pos.move(dx: getDoubleValue(element, attribute: "x") ?? 0, dy: getDoubleValue(element, attribute: "y") ?? 0)
		node.opacity = opacity
        let maskString = element.attributes["mask"] ?? ""
		return parseUseNode(node: node, fill: fill, stroke: stroke, mask: maskString)
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
                let fullRange = NSMakeRange(0, mask.characters.count)
                if let match = maskIdenitifierMatcher.firstMatch(in: mask, options: .reportCompletion, range: fullRange), let maskReferenceNode = self.defMasks[(mask as NSString).substring(with: match.rangeAt(1))] {
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
                parseUseNode(node: node, fill: fill, stroke: stroke, mask: mask)
            }
            return group
        }
        return node
    }
    
    fileprivate func parseMask(_ mask: XMLIndexer) -> Shape? {
        guard let element = mask.element else {
            return .none
        }
        var node: Node?
        mask.children.forEach { indexer in
            if let useNode = parseUse(indexer, fill: .none, stroke: .none, pos: Transform(), opacity: 0) {
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
            maskShape = Shape(form: circle.arc(shift: 0, extent: degreesToRadians(360)))
        } else {
            maskShape = Shape(form: shape.form)
        }
        let maskStyleAttributes = getStyleAttributes([:], element: element)
        maskShape.fill = getFillColor(maskStyleAttributes)
        return maskShape
    }

	fileprivate func parseLinearGradient(_ gradient: XMLIndexer) -> Fill? {
		guard let element = gradient.element else {
			return .none
		}
		var parentGradient: LinearGradient?
		if let link = element.attributes["xlink:href"]?.replacingOccurrences(of: " ", with: "")
		, link.hasPrefix("#") {

			let id = link.replacingOccurrences(of: "#", with: "")
			parentGradient = defFills[id] as? LinearGradient
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

		let x1 = getDoubleValueFromPercentage(element, attribute: "x1") ?? parentGradient?.x1 ?? 0
		let y1 = getDoubleValueFromPercentage(element, attribute: "y1") ?? parentGradient?.y1 ?? 0
		let x2 = getDoubleValueFromPercentage(element, attribute: "x2") ?? parentGradient?.x2 ?? 1
		let y2 = getDoubleValueFromPercentage(element, attribute: "y2") ?? parentGradient?.y2 ?? 0
		var userSpace = false
		if let gradientUnits = element.attributes["gradientUnits"] , gradientUnits == "userSpaceOnUse" {
			userSpace = true
		} else if let parent = parentGradient {
			userSpace = parent.userSpace
		}
		return LinearGradient(x1: x1, y1: y1, x2: x2, y2: y2, userSpace: userSpace, stops: stops)
	}

	fileprivate func parseRadialGradient(_ gradient: XMLIndexer) -> Fill? {
		guard let element = gradient.element else {
			return .none
		}
		var parentGradient: RadialGradient?
		if let link = element.attributes["xlink:href"]?.replacingOccurrences(of: " ", with: "")
		, link.hasPrefix("#") {

			let id = link.replacingOccurrences(of: "#", with: "")
			parentGradient = defFills[id] as? RadialGradient
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

		let cx = getDoubleValueFromPercentage(element, attribute: "cx") ?? parentGradient?.cx ?? 0.5
		let cy = getDoubleValueFromPercentage(element, attribute: "cy") ?? parentGradient?.cy ?? 0.5
		let fx = getDoubleValueFromPercentage(element, attribute: "fx") ?? parentGradient?.fx ?? cx
		let fy = getDoubleValueFromPercentage(element, attribute: "fy") ?? parentGradient?.fy ?? cy
		let r = getDoubleValueFromPercentage(element, attribute: "r") ?? parentGradient?.r ?? 0.5
		var userSpace = false
		if let gradientUnits = element.attributes["gradientUnits"] , gradientUnits == "userSpaceOnUse" {
			userSpace = true
		} else if let parent = parentGradient {
			userSpace = parent.userSpace
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
		if let dAttr = path.element?.attributes["d"] {
            return Path(segments: parsePathCommands(dAttr))
		}
		return .none
	}
    
    fileprivate func parsePathCommands(_ d: String) -> [PathSegment] {
        var pathCommands = [PathCommand]()
        var pathCommandName: NSString? = ""
        var pathCommandValues: NSString? = ""
        let scanner = Scanner(string: d)
        let set = CharacterSet(charactersIn: SVGConstants.pathCommands.joined())
        let charCount = d.characters.count
        repeat {
            scanner.scanCharacters(from: set, into: &pathCommandName)
            scanner.scanUpToCharacters(from: set, into: &pathCommandValues)
            pathCommands.append(
                PathCommand(
                    type: getCommandType(pathCommandName! as String),
                    expression: pathCommandValues! as String,
                    absolute: isAbsolute(pathCommandName! as String)
                )
            )
            if scanner.scanLocation == charCount {
                break
            }
        } while pathCommandValues!.length > 0
        var commands = [PathSegment]()
        pathCommands.forEach { command in
            if let parsedCommand = parseCommand(command) {
                commands.append(parsedCommand)
            }
        }
        return commands
    }

    fileprivate func parseCommand(_ command: PathCommand) -> PathSegment? {
		var characterSet = CharacterSet()
		characterSet.insert(" ")
		characterSet.insert(",")
		let commandParams = command.expression.components(separatedBy: characterSet)
		var separatedValues = [String]()
		commandParams.forEach { param in
			separatedValues.append(contentsOf: separateNegativeValuesIfNeeded(param))
		}

		switch command.type {
		case .moveTo:
            var data = [Double]()
            separatedValues.forEach { value in
                if let double = Double(value) {
                    data.append(double)
                }
            }
            
            if data.count < 2 {
                return .none
            }

			return PathSegment(type: command.absolute ? .M : .m, data: data)

		case .lineTo:
            var data = [Double]()
            separatedValues.forEach { value in
                if let double = Double(value) {
                    data.append(double)
                }
            }
            
            if data.count < 2 {
                return .none
            }

			return PathSegment(type: command.absolute ? .L : .l, data: data)

		case .lineH:
			if separatedValues.count < 1 {
				return .none
			}
            
            guard let x = Double(separatedValues[0]) else {
                return .none
            }
            
            return PathSegment(type: command.absolute ? .H : .h, data: [x])

		case .lineV:
			if separatedValues.count < 1 {
				return .none
			}
            
            guard let y = Double(separatedValues[0]) else {
                return .none
            }
            
            return PathSegment(type: command.absolute ? .V : .v, data: [y])

		case .curveTo:
            var data = [Double]()
            separatedValues.forEach { value in
                if let double = Double(value) {
                    data.append(double)
                }
            }
            
            if data.count < 6 {
                return .none
            }

			return PathSegment(type: command.absolute ? .C : .c, data: data)

		case .smoothCurveTo:
            var data = [Double]()
            separatedValues.forEach { value in
                if let double = Double(value) {
                    data.append(double)
                }
            }
            
            if data.count < 4 {
                return .none
            }

			return PathSegment(type: command.absolute ? .S : .s, data: data)

		case .closePath:
			return PathSegment(type: .z)
		default:
			return .none
		}
	}

	fileprivate func separateNegativeValuesIfNeeded(_ expression: String) -> [String] {
		var values = [String]()
		var value = String()
		var e = false
        
        expression.unicodeScalars.forEach { scalar in
            if scalar == "e" {
                e = true
            }
            if scalar == "-" && !e {
                if !value.isEmpty {
                    values.append(value)
                    value = String()
                }
                e = false
            }
            
            value.append("\(scalar)")
        }

		if !value.isEmpty {
			values.append(value)
		}

		return values
	}

	fileprivate func isAbsolute(_ commandString: String) -> Bool {
		switch commandString {
		case SVGConstants.moveToAbsolute:
			return true
		case SVGConstants.moveToRelative:
			return false
		case SVGConstants.lineToAbsolute:
			return true
		case SVGConstants.lineToRelative:
			return false
		case SVGConstants.lineHorizontalAbsolute:
			return true
		case SVGConstants.lineHorizontalRelative:
			return false
		case SVGConstants.lineVerticalAbsolute:
			return true
		case SVGConstants.lineVerticalRelative:
			return false
		case SVGConstants.curveToAbsolute:
			return true
		case SVGConstants.curveToRelative:
			return false
		case SVGConstants.smoothCurveToAbsolute:
			return true
		case SVGConstants.smoothCurveToRelative:
			return false
		case SVGConstants.closePathAbsolute:
			return true
		case SVGConstants.closePathRelative:
			return false
		default:
			return true
		}
	}

	fileprivate func getCommandType(_ commandString: String) -> PathCommandType {
		switch commandString {
		case SVGConstants.moveToAbsolute:
			return .moveTo
		case SVGConstants.moveToRelative:
			return .moveTo
		case SVGConstants.lineToAbsolute:
			return .lineTo
		case SVGConstants.lineToRelative:
			return .lineTo
		case SVGConstants.lineVerticalAbsolute:
			return .lineV
		case SVGConstants.lineVerticalRelative:
			return .lineV
		case SVGConstants.lineHorizontalAbsolute:
			return .lineH
		case SVGConstants.lineHorizontalRelative:
			return .lineH
		case SVGConstants.curveToAbsolute:
			return .curveTo
		case SVGConstants.curveToRelative:
			return .curveTo
		case SVGConstants.smoothCurveToAbsolute:
			return .smoothCurveTo
		case SVGConstants.smoothCurveToRelative:
			return .smoothCurveTo
		case SVGConstants.closePathAbsolute:
			return .closePath
		case SVGConstants.closePathRelative:
			return .closePath
		default:
			return .none
		}
	}

	fileprivate func getDoubleValue(_ element: XMLElement, attribute: String) -> Double? {
		guard let attributeValue = element.attributes[attribute], let doubleValue = Double(attributeValue) else {
			return .none
		}
		return doubleValue
	}

	fileprivate func getDoubleValueFromPercentage(_ element: XMLElement, attribute: String) -> Double? {
		guard let attributeValue = element.attributes[attribute] else {
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

	fileprivate func getIntValue(_ element: XMLElement, attribute: String) -> Int? {
		guard let attributeValue = element.attributes[attribute], let intValue = Int(attributeValue) else {
			return .none
		}
		return intValue
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

	fileprivate func getFontWeight(_ attributes: [String: String], style: String) -> Bool? {
		guard let fontWeight = attributes["font-weight"] else {
			return .none
		}
		if fontWeight.lowercased() == style {
			return true
		}
		return false
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
			return Text(text: text.text, font: text.font, fill: text.fill, align: text.align, baseline: text.baseline, place: pos, opaque: opaque, clip: clip, visible: visible, tag: tag)
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
