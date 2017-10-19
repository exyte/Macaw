import XCTest
@testable import Macaw

class MacawSVGTests: XCTestCase {
    
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
                let clipReferenceContent = try String.init(contentsOfFile: path).trimmingCharacters(in: .newlines)
                XCTAssertEqual(SVGSerializer.serialize(node: node), clipReferenceContent)
            }
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func validate(_ test: String, withReference: Bool = false) {
        let bundle = Bundle(for: type(of: TestUtils()))
        var ext = "svg"
        if withReference {
            ext = "reference"
        }
        do {
            if let path = bundle.path(forResource: test, ofType: ext) {
                let referenceContent = try String.init(contentsOfFile: path).trimmingCharacters(in: .newlines)
                let node = try SVGParser.parse(bundle:bundle, path: test)
                let testContent = SVGSerializer.serialize(node: node)
                    .replacingOccurrences(of: "version=\"1.1\"  ><g>", with: "version=\"1.1\"  >")
                    .replacingOccurrences(of: "defs><g>", with: "defs>")
                    .replacingOccurrences(of: "</g></svg>", with: "</svg>")
                XCTAssertEqual(testContent, referenceContent)
            }
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testTextBasicTransform() {
        let text1 = Text(text: "Point")
        text1.place = Transform(m11: cos(.pi/4.0), m12: -sin(.pi/4.0), m21: sin(.pi/4.0), m22: cos(.pi/4.0), dx: 0, dy: 0)
        let group1 = Group(contents: [text1])
        group1.place = Transform(dx: 100, dy: 100)
        let node = Group(contents: [group1])
        
        validate(node: node, referenceFile: "testBasicTransform")
    }

    func testClipManual() {
        let path1 = Rect(x: 10, y: 10, w: 90, h: 90)
        let circle1 = Circle(cx: 20, cy: 20, r: 20).fill(with: Color.red)
        circle1.clip = path1
        let path2 = Rect(x: 110, y: 110, w: 190, h: 190)
        let circle2 = Circle(cx: 120, cy: 120, r: 20).fill(with: Color.green)
        circle2.clip = path2
        let node = Group(contents:[circle1, circle2])
        
        validate(node: node, referenceFile: "clipManual")
    }

    func testSVGClearColor() {
        let clearColorReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><ellipse  cy=\"20\" ry=\"20\" rx=\"20\" cx=\"20\"  fill=\"#000000\" fill-opacity=\"0.0\" stroke=\"#000000\" stroke-opacity=\"0.0\" stroke-width=\"1.0\"/></svg>"
        let node = Ellipse(cx: 20, cy: 20, rx: 20, ry:20).arc(shift: 0, extent: 6.28318500518799).fill(with: Color.clear)
        node.stroke = Stroke(fill: Color.clear)
        XCTAssertEqual(SVGSerializer.serialize(node: node), clearColorReferenceContent)
    }

    func testSVGArcsGroup() {
        let g1 = Group(contents:[Ellipse(cx: 20, cy: 20, rx: 20, ry:20).arc(shift: 0, extent: 6.28318500518799).stroke(fill: Color.green)], place: Transform(dx:10, dy: 10))
        let g2 = Group(contents:[Ellipse(cx: 20, cy: 20, rx: 20, ry:20).arc(shift: 1.570796251297, extent: 1.57079637050629).stroke(fill: Color.green)], place: Transform(dx:10, dy: 140))
        let g3 = Group(contents:[Ellipse(cx: 20, cy: 20, rx: 20, ry:20).arc(shift: 3.14159250259399, extent: 2.67794513702393).stroke(fill: Color.green)], place: Transform(dx:110, dy: 140) )
        let group = Group(contents:[g1, g2, g3])
        
        validate(node: group, referenceFile: "arcsGroup")
    }
    
    func testSVGImage() {
        let bundle = Bundle(for: type(of: TestUtils()))
        if let path = bundle.path(forResource: "small-logo", ofType: "png") {
            if let mimage = MImage(contentsOfFile: path), let base64Content = MImagePNGRepresentation(mimage)?.base64EncodedString() {
                let node = Image(image: mimage)
                let imageReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><image    xlink:href=\"data:image/png;base64,\(String(base64Content))\" width=\"59.0\" height=\"43.0\" /></svg>"
                XCTAssertEqual(SVGSerializer.serialize(node: node), imageReferenceContent)
            }
        }
    }
 
    func testClipWithParser() {
        validate("clip", withReference: true)
    }
    
    func testCSSStyleReference() {
        validate("style", withReference: true)
    }
    
    func testSVGTransformSkew() {
        validate("transform", withReference: true)
    }
    
    func testSVGEllipse() {
        validate("ellipse")
    }
    
    func testSVGCircle() {
        validate("circle")
    }
    
    func testSVGGroup() {
        validate("group", withReference: true)
    }
    
    func testSVGLine() {
        validate("line")
    }
    
    func testSVGPolygon() {
        validate("polygon")
    }
    
    func testSVGPolyline() {
        validate("polyline")
    }
    
    func testSVGRect() {
        validate("rect")
    }
    
    func testSVGRoundRect() {
        validate("roundRect")
    }
    
    func testSVGTriangle() {
        validate("triangle")
    }
}
