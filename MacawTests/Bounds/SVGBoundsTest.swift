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
    
    func validate(name: String, referenceBounds: Rect) {
        let passingThreshold = 0.2
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let node = try SVGParser.parse(bundle:bundle, path: name)
            var testResult = false
            if let bounds = node.bounds() {
//                print("\n<rect x=\"\(Double(round(100*bounds.x)/100))\" y=\"\(Double(round(100*bounds.y)/100))\" width=\"\(Double(round(100*bounds.w)/100))\" height=\"\(Double(round(100*bounds.h)/100))\" stroke=\"red\" stroke-width=\"1\" fill=\"none\"/>\n")
                testResult = (Double(round(100*bounds.x)/100) - referenceBounds.x < passingThreshold)
                testResult = testResult && (Double(round(100*bounds.y)/100) - referenceBounds.y < passingThreshold)
                testResult = testResult && (Double(round(100*bounds.w)/100) - referenceBounds.w < passingThreshold)
                testResult = testResult && (Double(round(100*bounds.h)/100) - referenceBounds.h < passingThreshold)
            }
            XCTAssert(testResult)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testPathBounds1() {
        validate(name: "pathbounds1", referenceBounds: Rect(x: 101.4, y: 36.7, w: 7.6, h: 35.0))
    }
    
    func testPathBounds2() {
        validate(name: "pathbounds2", referenceBounds: Rect(x: 36.7, y: 101.4, w: 35, h: 7.6))
    }
    
    func testPathBounds3() {
        validate(name: "pathbounds3", referenceBounds: Rect(x: 0, y: 0, w: 50, h: 50))
    }

    func testPathBounds4() {
        validate(name: "pathbounds4", referenceBounds: Rect(x: 9.5, y: 27.0, w: 171, h: 106))
    }
    
    func testPathBoundsCubicAbsolute() {
        validate(name: "cubicAbsolute", referenceBounds: Rect(x: 33.66, y: 9.5, w: 16.84, h: 41))
    }
    
    func testPathBoundsCubicRelative() {
        validate(name: "cubicRelative", referenceBounds: Rect(x: 49.5, y: 49.5, w: 51, h: 17.57))
    }
}

