import Foundation

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
    
    // MARK: - Resources
    static func getResource(group: String, name: String, type: String) -> URL? {
        let resourceURL = resourcesFolder
            .appendingPathComponent(group)
            .appendingPathComponent("\(name).\(type)", isDirectory: false)
        return resourceURL
    }
    
    static let resourcesFolder: URL = {
        let sourceFile = #file // this file must be in the root of the MacawTests Directory
        let testFile = URL(fileURLWithPath: "\(sourceFile)", isDirectory: false)
        let testsFolder = testFile.deletingLastPathComponent()
        return testsFolder.appendingPathComponent("Resources", isDirectory: true)
    }()
    
}
