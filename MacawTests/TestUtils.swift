import Foundation
import Macaw

class TestUtils {

	class func compareWithReferenceObject(_ fileName: String, referenceObject: AnyObject) -> Bool {
        // TODO: this needs to be replaced with SVG tests
		return true
	}

	class func prepareParametersList(_ mirror: Mirror) -> [(String, String)] {
		var result: [(String, String)] = []
		for (_, attribute) in mirror.children.enumerated() {
			if let label = attribute.label , (label == "_value" || label.first != "_") && label != "contentsVar" {
				result.append((label, String(describing: attribute.value)))
				result.append(contentsOf: prepareParametersList(Mirror(reflecting: attribute.value)))
			}
		}
		return result
	}

}
