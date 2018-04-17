import XCTest
@testable import Macaw

class MacawNewSVGTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func validate(node: Node, referenceFile: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        
        do {
            if let path = bundle.path(forResource: referenceFile, ofType: "reference") {
                let referenceContent = try String(contentsOfFile: path)
                
                let jsonData = try JSONSerialization.data(withJSONObject: node.toDictionary(), options: .prettyPrinted)
                let nodeContent = String(data: jsonData, encoding: String.Encoding.utf8)
                
                XCTAssertEqual(nodeContent, referenceContent)
            }
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func create(_ test: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let path = bundle.path(forResource: test, ofType: "svg")?.replacingOccurrences(of: ".svg", with: ".reference")
            let node = try SVGParser.parse(bundle: bundle, path: test)
            let jsonData = try JSONSerialization.data(withJSONObject: node.toDictionary(), options: .prettyPrinted)
            try jsonData.write(to: URL(fileURLWithPath: path!))
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func validate(_ test: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let node = try SVGParser.parse(bundle: bundle, path: test)
            validate(node: node, referenceFile: test)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    // uncomment to create new test reference file
//    func testCreate() {
//        create("color-prop-02-f-manual")
//    }
    
    func testViewBox() {
        validate("test")
    }
    
    func testColorProp02fmanual() {
        validate("color-prop-02-f-manual")
    }
}
