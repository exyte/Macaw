import XCTest
@testable import Macaw

class MacawTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSVGTriangle() {
        compareWithEtalonObject("triangle", referenceObject: createTriangleReferenceObject())
    }
    
    func compareWithEtalonObject(fileName: String, referenceObject: AnyObject) -> Bool {
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource(fileName, ofType: "svg")
        if let _ = path {
            let content = try? NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            if let svgString = content as? String {
                let parser = SVGParser(svgString)
                let group = parser.parse()
                let referenceArray = prepareParametersList(Mirror(reflecting: referenceObject))
                let parametersArray = prepareParametersList(Mirror(reflecting: group))
                return referenceArray.elementsEqual(parametersArray, isEquivalent: { first, second in
                    return first.0 == second.0 && first.1 == second.1
                })
            }
        }
        return false
    }
    
    func prepareParametersList(mirror: Mirror) -> [(String, String)] {
        var result:[(String, String)] = []
        for (_, attribute) in mirror.children.enumerate() {
            if let label = attribute.label where label == "_value" || label.characters.first != "_" {
                result.append((label, String(attribute.value)))
                result.appendContentsOf(prepareParametersList(Mirror(reflecting: attribute.value)))
            }
        }
        return result
    }
    
    func createTriangleReferenceObject() -> Group {
        let path = Path(segments: [Move(x: 150, y: 0), PLine(x: 75, y: 200), PLine(x: 225, y: 200), Close()])
        return Group(contents: [Shape(form: path)])
    }
    
}
