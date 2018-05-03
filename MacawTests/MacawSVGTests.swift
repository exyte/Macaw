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
                let result = SVGSerializer.serialize(node: node)
                XCTAssertEqual(result, clipReferenceContent)
            }
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
    
    
    func create(_ test: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let path = bundle.path(forResource: test, ofType: "svg")?.replacingOccurrences(of: ".svg", with: ".reference")
            let node = try SVGParser.parse(bundle: bundle, path: test)
            let result = SVGSerializer.serialize(node: node)
            try result.write(to: URL(fileURLWithPath: path!), atomically: true, encoding: String.Encoding.utf8)
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
    
    func testViewBox() {
        validate("viewBox")
    }
 
    func testClipWithParser() {
        validate("clip")
    }
    
    func testCSSStyleReference() {
        validate("style")
    }
    
    func testSVGTransformSkew() {
        validate("transform")
    }
    
    func testSVGEllipse() {
        validate("ellipse")
    }
    
    func testSVGCircle() {
        validate("circle")
    }
    
    func testSVGGroup() {
        validate("group")
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
    
    func validateJSON(node: Node, referenceFile: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        
        do {
            if let path = bundle.path(forResource: referenceFile, ofType: "reference"), let node = node as? Serializable {
                let referenceContent = try String(contentsOfFile: path)
                
                let jsonData = try JSONSerialization.data(withJSONObject: node.toDictionary(), options: .prettyPrinted)
                let nodeContent = String(data: jsonData, encoding: String.Encoding.utf8)
                
                XCTAssertEqual(nodeContent, referenceContent)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func validateJSON(_ test: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let node = try SVGParser.parse(bundle: bundle, path: test)
            validateJSON(node: node, referenceFile: test)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func createJSON(_ test: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let path = bundle.path(forResource: test, ofType: "svg")?.replacingOccurrences(of: ".svg", with: ".reference")
            let node = try SVGParser.parse(bundle: bundle, path: test)
            guard let serializableNode = node as? Serializable else {
                XCTFail()
                return
            }
            let jsonData = try JSONSerialization.data(withJSONObject: serializableNode.toDictionary(), options: .prettyPrinted)
            try jsonData.write(to: URL(fileURLWithPath: path!))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testColorProp02() {
        validateJSON("color-prop-02-f-manual")
    }
    
    func testShapesCircle01() {
        validateJSON("shapes-circle-01-t-manual")
    }
}
