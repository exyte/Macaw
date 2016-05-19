import Foundation
import SWXMLHash

public class SVGParser {

	let groupTag = "g"
	let pathTag = "path"
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

	private let xmlString: String
	private let position: Transform

	private var shapes = [Shape]()

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
		xmlString = string
		position = pos
	}

	public func parse() -> Group {
		let parsedXml = SWXMLHash.parse(xmlString)
		iterateThroughXmlTree(parsedXml.children)

		let group = Group(
			contents: shapes
		)
		return group
	}

	private func iterateThroughXmlTree(children: [XMLIndexer]) {
		for child in children {
			if let element = child.element {
				if element.name == groupTag {
					if let shape = parseGroup(child) {
						shapes.append(shape)
					}
				}
			}
			iterateThroughXmlTree(child.children)
		}
	}

	private func parseGroup(group: XMLIndexer) -> Shape? {
		var childPath: XMLIndexer?
		for child in group.children {
			if let element = child.element {
				if element.name == pathTag {
					childPath = child
				}
			}
		}

		guard let element = group.element else {
			return nil
		}
		var styleElements = [String: String]()
		if let styleAttr = element.attributes["style"] {
			let styleAttrParts = styleAttr.componentsSeparatedByString(";")

			for styleAttrPart in styleAttrParts {
				let currentStyle = styleAttrPart.componentsSeparatedByString(":")
				if currentStyle.count == 2 {
					styleElements.updateValue(currentStyle[1], forKey: currentStyle[0].stringByReplacingOccurrencesOfString(" ", withString: ""))
				}
			}
		}

		if childPath != nil {
			if let path = parsePath(childPath!) {
				let shape = Shape(
					form: path,
					fill: getFillColor(styleElements),
					stroke: getStroke(styleElements),
					pos: position
				)
				return shape
			}
		}
		return nil
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
		if color != nil {
			return Stroke(
				fill: color!,
				width: getStrokeWidth(styleParts),
				cap: .round,
				join: .round
			)
		}
		return nil
	}

	private func getStrokeWidth(styleParts: [String: String]) -> Double {
		var width: Double = 1
		if let strokeWidth = styleParts["stroke-width"] {
			let strokeWidth = strokeWidth.stringByReplacingOccurrencesOfString(" ", withString: "")
			width = Double(strokeWidth)!
		}
		return width
	}

	private func parsePath(path: XMLIndexer) -> Path? {
		if let dAttr = path.element!.attributes["d"] {
			let pathSegments = parseCommands(dAttr)
			return Path(segments: pathSegments)
		}
		return nil
	}

	private func parseCommands(d: String) -> [PathSegment] {
		var pathCommands = [PathCommand]()
		var commandChar = Character(" ")
		var commandString = ""
		for character in d.characters {
			if isCommandCharacter(character) {
				if !commandString.isEmpty {
					pathCommands.append(
						PathCommand(
							type: getCommandType(commandChar),
							expression: commandString,
							absolute: true
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
		for command in pathCommands {
			if let parsedCommand = parseCommand(command) {
				commands.append(parsedCommand)
			}
		}
		return commands
	}

	private func parseCommand(command: PathCommand) -> PathSegment? {
		print("Expression: \(command.expression)")

		let characterSet = NSMutableCharacterSet()
		characterSet.addCharactersInString(" ")
		characterSet.addCharactersInString(",")
		var commandParams = command.expression.componentsSeparatedByCharactersInSet(characterSet)
		var separatedValues = [String]()
		commandParams.forEach { param in
			separatedValues.appendContentsOf(separateNegativeValuesIfNeeded(param))
		}

		print("Params: \(separatedValues)")
		switch command.type {
		case .MoveTo:
			print("MoveTo \(separatedValues.count)")
			if separatedValues.count < 2 {
				return .None
			}

			guard let x = Double(separatedValues[0]), y = Double(separatedValues[1]) else {
				return .None
			}

			return Move(x: x, y: y, absolute: true)
		case .LineTo:
			print("LineTo \(commandParams.count)")
			if commandParams.count < 2 {
				return .None
			}

			guard let x = Double(separatedValues[0]), y = Double(separatedValues[1]) else {
				return .None
			}

			return PLine(x: x, y: y, absolute: true)
		case .LineH:
			print("LineHorizontal \(separatedValues.count)")
			if separatedValues.count < 1 {
				return .None
			}

			guard let x = Double(separatedValues[0]) else {
				return .None
			}

			return HLine(x: x, absolute: true)

		case .LineV:
			print("LineVertical \(separatedValues.count)")
			if separatedValues.count < 1 {
				return .None
			}

			guard let y = Double(separatedValues[0]) else {
				return .None
			}

			return VLine(y: y, absolute: true)

		case .CurveTo:
			print("CurveTo \(separatedValues.count)")
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

			return Cubic(x1: x1, y1: y1, x2: x2, y2: y2, x: x, y: y, absolute: true)
		case .ClosePath:
			print("Close Path")
			return Close()
		default:
			return nil
		}
	}

	private func separateNegativeValuesIfNeeded(expression: String) -> [String] {

		var values = [String]()
		var value = String()
		for c in expression.characters {
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
}
