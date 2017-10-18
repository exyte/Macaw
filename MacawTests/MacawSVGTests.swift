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

    func testTextBasicTransform() {
        let referenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><g transform=\"translate(100,100)\" ><text    dominant-baseline=\"text-before-edge\"  fill=\"black\" transform=\"matrix(0.707106781186548,-0.707106781186547,0.707106781186547,0.707106781186548,0.0,0.0)\" >Point</text></g></g></svg>"
        let text1 = Text(text: "Point")
        text1.place = Transform(m11: cos(Double.pi/4.0), m12: -sin(Double.pi/4.0), m21: sin(Double.pi/4.0), m22: cos(Double.pi/4.0), dx: 0, dy: 0)
        let group1 = Group(contents: [text1])
        group1.place = Transform(dx: 100, dy: 100)
        let node = Group(contents: [group1])
        XCTAssertEqual(SVGSerializer.serialize(node: node), referenceContent)
    }

    func testClipWithParser() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let clipReferenceContent = "//<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><defs><clipPath id=\"clipPath1\"><path  d=\"M 20 0m -20 0a 20 20 0 1 0 40 0a 20 20 0 1 0 -40 0M 0 10L 0 45L 100 45L 100 10z M 0 55L 0 90L 100 90L 100 55z \" /></clipPath></defs><g><circle  r=\"50\" cy=\"50\" cx=\"50\"  clip-path=\"url(#clipPath1)\"  fill=\"black\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "clip")
            XCTAssert(SVGSerializer.serialize(node: node) == clipReferenceContent)
        } catch {
            print(error)
        }
    }

    func testClipManual() {
        let clipReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><defs><clipPath id=\"clipPath1\"><rect  height=\"90\" x=\"10\" y=\"10\" width=\"90\" /></clipPath><clipPath id=\"clipPath2\"><rect  height=\"190\" x=\"110\" y=\"110\" width=\"190\" /></clipPath></defs><g><circle  r=\"20\" cy=\"20\" cx=\"20\"  clip-path=\"url(#clipPath1)\"  fill=\"red\"/><circle  r=\"20\" cy=\"120\" cx=\"120\"  clip-path=\"url(#clipPath2)\"  fill=\"green\"/></g></svg>"
        let path1 = Rect(x: 10, y: 10, w: 90, h: 90)
        let circle1 = Circle(cx: 20, cy: 20, r: 20).fill(with: Color.red)
        circle1.clip = path1
        let path2 = Rect(x: 110, y: 110, w: 190, h: 190)
        let circle2 = Circle(cx: 120, cy: 120, r: 20).fill(with: Color.green)
        circle2.clip = path2
        let node = Group(contents:[circle1, circle2])
        XCTAssertEqual(SVGSerializer.serialize(node: node), clipReferenceContent)
    }

    func testCSSStyleReference() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let styleReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><g><circle  r=\"10\" cy=\"50\" cx=\"50\"  fill=\"white\" stroke=\"#231F20\" stroke-width=\"1.5\"/><circle  r=\"10\" cy=\"50\" cx=\"80\"  fill=\"black\"/></g></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "style")
            XCTAssertEqual(SVGSerializer.serialize(node: node), styleReferenceContent)
        } catch {
            print(error)
        }
    }

    func testSVGArcsGroup() {
        let g1 = Group(contents:[Ellipse(cx: 20, cy: 20, rx: 20, ry:20).arc(shift: 0, extent: 6.28318500518799).stroke(fill: Color.green)], place: Transform(dx:10, dy: 10))
        let g2 = Group(contents:[Ellipse(cx: 20, cy: 20, rx: 20, ry:20).arc(shift: 1.570796251297, extent: 1.57079637050629).stroke(fill: Color.green)], place: Transform(dx:10, dy: 140))
        let g3 = Group(contents:[Ellipse(cx: 20, cy: 20, rx: 20, ry:20).arc(shift: 3.14159250259399, extent: 2.67794513702393).stroke(fill: Color.green)], place: Transform(dx:110, dy: 140) )
        let group = Group(contents:[g1, g2, g3])
        let arcGroupReference = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><g transform=\"translate(10,10)\" ><ellipse  cy=\"20\" ry=\"20\" rx=\"20\" cx=\"20\"  fill=\"none\" stroke=\"green\" stroke-width=\"1.0\"/></g><g transform=\"translate(10,140)\" ><path  d=\"M20.0000015099579,39.9999999999999 A 20.0,20.0 0.0 0, 1 1.06581410364015e-14,20.0000006357301\"  fill=\"none\" stroke=\"green\" stroke-width=\"1.0\"/></g><g transform=\"translate(110,140)\" ><path  d=\"M2.27373675443232e-13,20.0000030199161 A 20.0,20.0 0.0 0, 1 37.888543296214,11.0557270424323\"  fill=\"none\" stroke=\"green\" stroke-width=\"1.0\"/></g></g></svg>"
        XCTAssertEqual(SVGSerializer.serialize(node: group), arcGroupReference)
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
 
    func testSVGTransform() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let transformReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><g transform=\"matrix(2.0,1.0,1.0,1.0,0.0,0.0)\" ><rect  height=\"5\" x=\"0\" y=\"0\" width=\"150\"  fill=\"blue\"/><rect  height=\"50\" x=\"0\" y=\"0\" width=\"5\"  fill=\"red\"/><rect  height=\"50\" x=\"150\" y=\"0\" width=\"5\"  fill=\"black\"/><rect  height=\"5\" x=\"0\" y=\"50\" width=\"150\"  fill=\"black\"/><ellipse  cy=\"25\" ry=\"15\" rx=\"40\" cx=\"75\"  fill=\"purple\"/></g></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "transform")
            XCTAssertEqual(SVGSerializer.serialize(node: node), transformReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGEllipse() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let ellipseReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><ellipse  cy=\"80\" ry=\"50\" rx=\"100\" cx=\"200\"  fill=\"yellow\" stroke=\"purple\" stroke-width=\"2.0\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "ellipse")
            XCTAssertEqual(SVGSerializer.serialize(node: node), ellipseReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGCircle() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let circleReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><circle  r=\"40\" cy=\"50\" cx=\"50\"  fill=\"red\" stroke=\"black\" stroke-width=\"3.0\"/><circle  r=\"40\" cy=\"50\" cx=\"140\"  fill=\"#F0F0AA\" stroke=\"black\" stroke-width=\"3.0\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "circle")
            XCTAssertEqual(SVGSerializer.serialize(node: node), circleReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGGroup() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let groupReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><g><path  d=\"M 150 0L 75 200L 225 200z \"  fill=\"black\" stroke=\"black\" stroke-width=\"2.0\"/><line  y1=\"0\" x2=\"200\" x1=\"0\" y2=\"200\"  fill=\"black\" stroke=\"white\" stroke-width=\"2.0\"/></g></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "group")
            XCTAssertEqual(SVGSerializer.serialize(node: node), groupReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGLine() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let lineReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><line  y1=\"0\" x2=\"200\" x1=\"0\" y2=\"200\"  fill=\"black\" stroke=\"red\" stroke-width=\"2.0\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "line")
            XCTAssertEqual(SVGSerializer.serialize(node: node), lineReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGPolygon() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let lineReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><polygon  points=\"200.0,10.0,250.0,190.0,160.0,210.0\"  fill=\"black\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "polygon")
            XCTAssertEqual(SVGSerializer.serialize(node: node), lineReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGPolyline() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let lineReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><polyline  points=\"0.0,40.0,40.0,40.0,40.0,80.0,80.0,80.0,80.0,120.0,120.0,120.0,120.0,160.0\"  fill=\"white\" stroke=\"red\" stroke-width=\"4.0\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "polyline")
            XCTAssertEqual(SVGSerializer.serialize(node: node), lineReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGRect() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let rectReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><rect  height=\"150\" x=\"50\" y=\"0\" width=\"150\"  fill=\"black\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "rect")
            XCTAssertEqual(SVGSerializer.serialize(node: node), rectReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGRoundRect() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let roundRectReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><rect  height=\"150\" ry=\"20\" rx=\"20\" width=\"150\"  fill=\"black\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "roundRect")
            XCTAssertEqual(SVGSerializer.serialize(node: node), roundRectReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGTriangle() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let triangleReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><path  d=\"M 150 0L 75 200L 225 200z \"  fill=\"black\" stroke=\"black\" stroke-width=\"2.0\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "triangle")
            XCTAssertEqual(SVGSerializer.serialize(node: node), triangleReferenceContent)
        } catch {
            print(error)
        }
    }
}
