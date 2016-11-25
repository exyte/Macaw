import Foundation
import Macaw

class TestUtils {

	class func compareWithReferenceObject(_ fileName: String, referenceObject: AnyObject) -> Bool {
		let bundle = Bundle(for: type(of: TestUtils()))
		if let path = bundle.path(forResource: fileName, ofType: "svg") {
			let content = try? NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
			if let svgString = content as? String {
				let group = SVGParser.parse(text: svgString)
				let referenceArray = TestUtils.prepareParametersList(Mirror(reflecting: referenceObject))
				let parametersArray = TestUtils.prepareParametersList(Mirror(reflecting: group))
				return referenceArray.elementsEqual(parametersArray, by: { first, second in
					return first.0 == second.0 && first.1 == second.1
				})
			}
		}
		return false
	}

	class func prepareParametersList(_ mirror: Mirror) -> [(String, String)] {
		var result: [(String, String)] = []
		for (_, attribute) in mirror.children.enumerated() {
			if let label = attribute.label , (label == "_value" || label.characters.first != "_") && label != "contentsVar" {
				result.append((label, String(describing: attribute.value)))
				result.append(contentsOf: prepareParametersList(Mirror(reflecting: attribute.value)))
			}
		}
		return result
	}

}
