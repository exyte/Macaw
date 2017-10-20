import XCTest
@testable import Macaw

class SVGBoundsTest: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPathBounds1() {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "pathbounds1")
            var testResult = false
            if let bounds = node.bounds() {
                testResult = (Double(round(100*bounds.x)/100) == 101.4)
                testResult = testResult && (Double(round(100*bounds.y)/100) == 36.7)
                testResult = testResult && (Double(round(100*bounds.w)/100) == 7.6)
                testResult = testResult && (Double(round(100*bounds.h)/100) == 35.0)
            }
            XCTAssert(testResult)
        } catch {
            print(error)
        }
    }
    
    func testPathBounds2() {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "pathbounds2")
            var testResult = false
            if let bounds = node.bounds() {
//                print("\n<rect x=\"\(Double(round(100*bounds.x)/100))\" y=\"\(Double(round(100*bounds.y)/100))\" width=\"\(Double(round(100*bounds.w)/100))\" height=\"\(Double(round(100*bounds.h)/100))\" stroke=\"red\" stroke-width=\"1\" fill=\"none\"/>\n")
                testResult = Double(round(100*bounds.x)/100) == 36.7
                testResult = testResult && Double(round(100*bounds.y)/100) == 101.4
                testResult = testResult && Double(round(100*bounds.w)/100) == 35.17
                testResult = testResult && Double(round(100*bounds.h)/100) == 7.6
            }
            XCTAssert(testResult)
        } catch {
            print(error)
        }
    }
    
    func testPathBoundsCubic() {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "pathbounds3")
            var testResult = false
            if let bounds = node.bounds() {
                testResult = Double(round(100*bounds.x)/100) == 0.0
                testResult = testResult && Double(round(100*bounds.y)/100) == 0.0
                testResult = testResult && Double(round(100*bounds.w)/100) == 50.0
                testResult = testResult && Double(round(100*bounds.h)/100) == 50.0
            }
            XCTAssert(testResult)
        } catch {
            print(error)
        }
    }

}

