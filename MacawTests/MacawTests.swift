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
        XCTAssertTrue(compareWithReferenceObject("triangle", referenceObject: createTriangleReferenceObject()))
    }
    
    func testSVGLine() {
        XCTAssertTrue(compareWithReferenceObject("line", referenceObject: createLineReferenceObject()))
    }
    
    func testSVGRect() {
        XCTAssertTrue(compareWithReferenceObject("rect", referenceObject: createRectReferenceObject()))
    }
    
    func testSVGRoundRect() {
        XCTAssertTrue(compareWithReferenceObject("roundRect", referenceObject: createRoundRectReferenceObject()))
    }
    
    func testSVGPolygon() {
        XCTAssertTrue(compareWithReferenceObject("polygon", referenceObject: createPolygonReferenceObject()))
    }
    
    func testSVGPolyline() {
        XCTAssertTrue(compareWithReferenceObject("polyline", referenceObject: createPolylineReferenceObject()))
    }
    
    func testSVGCircle() {
        XCTAssertTrue(compareWithReferenceObject("circle", referenceObject: createCircleReferenceObject()))
    }
    
    func testSVGEllipse() {
        XCTAssertTrue(compareWithReferenceObject("ellipse", referenceObject: createEllipseReferenceObject()))
    }
    
    func compareWithReferenceObject(fileName: String, referenceObject: AnyObject) -> Bool {
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
                    //print("\(first.0) \(first.1) : \(second.0) \(second.1)")
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
        return Group(contents: [Shape(form: path, stroke: Stroke(fill: Color.rgb(0, g: 102, b: 0), width: 2, cap: .round, join: .round))])
    }
    
    func createLineReferenceObject() -> Group {
        let line = Line(x1: 0, y1: 0, x2: 200, y2: 200)
        return Group(contents: [Shape(form: line, stroke: Stroke(fill: Color.red, width: 2, cap: .round, join: .round))])
    }
    
    func createRectReferenceObject() -> Group {
        let rect = Rect(x: 50, w: 150, h: 150)
        return Group(contents: [Shape(form: rect)])
    }
    
    func createRoundRectReferenceObject() -> Group {
        let roundRect = RoundRect(rect: Rect(w: 150, h: 150), rx: 20, ry: 20)
        return Group(contents: [Shape(form: roundRect)])
    }
    
    func createPolygonReferenceObject() -> Group {
        let polygon = Polygon(points: [200, 10, 250, 190, 160, 210])
        return Group(contents: [Shape(form: polygon)])
    }
    
    func createPolylineReferenceObject() -> Group {
        let polyline = Polyline(points: [0, 40, 40, 40, 40, 80, 80, 80, 80, 120, 120, 120, 120, 160])
        return Group(contents: [Shape(form: polyline, stroke: Stroke(fill: Color.red, width: 4, cap: .round, join: .round), fill: Color.white)])
    }
    
    func createCircleReferenceObject() -> Group {
        let circle = Circle(cx: 50, cy: 50, r: 40)
        return Group(contents: [Shape(form: circle, stroke: Stroke(fill: Color.black, width: 3, cap: .round, join: .round), fill: Color.red)])
    }
    
    func createEllipseReferenceObject() -> Group {
        let ellipse = Ellipse(cx: 200, cy: 80, rx: 100, ry: 50)
        return Group(contents: [Shape(form: ellipse, stroke: Stroke(fill: Color.purple, width: 2, cap: .round, join: .round), fill: Color.yellow)])
    }
}
