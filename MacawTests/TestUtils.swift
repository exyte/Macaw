import Foundation
import Macaw

class TestUtils {

	class func compareWithReferenceObject(fileName: String, referenceObject: AnyObject) -> Bool {
		let bundle = NSBundle(forClass: TestUtils().dynamicType)
		if let path = bundle.pathForResource(fileName, ofType: "svg") {
			let content = try? NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
			if let svgString = content as? String {
				let group = SVGParser.parse(text: svgString)
				let referenceArray = TestUtils.prepareParametersList(Mirror(reflecting: referenceObject))
				let parametersArray = TestUtils.prepareParametersList(Mirror(reflecting: group))
				return referenceArray.elementsEqual(parametersArray, isEquivalent: { first, second in
					return first.0 == second.0 && first.1 == second.1
				})
			}
		}
		return false
	}

	class func prepareParametersList(mirror: Mirror) -> [(String, String)] {
		var result: [(String, String)] = []
		for (_, attribute) in mirror.children.enumerate() {
			if let label = attribute.label where label == "_value" || label.characters.first != "_" {
				result.append((label, String(attribute.value)))
				result.appendContentsOf(prepareParametersList(Mirror(reflecting: attribute.value)))
			}
		}
		return result
	}

}