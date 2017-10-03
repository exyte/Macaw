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
    
    func testCSSStyleReference() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let styleReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><g><circle  r=\"10\" cy=\"50\" cx=\"50\"  fill=\"white\" stroke=\"#231F20\" stroke-width=\"1.5\"/><circle  r=\"10\" cy=\"50\" cx=\"80\"  fill=\"black\"/></g></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "style")
            XCTAssert(SVGSerializer.serialize(node: node) == styleReferenceContent)
        } catch {
            print(error)
        }
    }

    func testSVGEllipse() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let ellipseReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><ellipse  cy=\"80\" ry=\"50\" rx=\"100\" cx=\"200\"  fill=\"yellow\" stroke=\"purple\" stroke-width=\"2.0\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "ellipse")
            print(SVGSerializer.serialize(node: node))
            XCTAssert(SVGSerializer.serialize(node: node) == ellipseReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGCircle() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let circleReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><circle  r=\"40\" cy=\"50\" cx=\"50\"  fill=\"red\" stroke=\"black\" stroke-width=\"3.0\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "circle")
            XCTAssert(SVGSerializer.serialize(node: node) == circleReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGGroup() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let groupReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><g><path  d=\"M 150 0L 75 200L 225 200z \"  fill=\"black\" stroke=\"black\" stroke-width=\"2.0\"/><line  y1=\"0\" x2=\"200\" x1=\"0\" y2=\"200\"  fill=\"black\" stroke=\"white\" stroke-width=\"2.0\"/></g></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "group")
            print(SVGSerializer.serialize(node: node))
            XCTAssert(SVGSerializer.serialize(node: node) == groupReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGLine() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let lineReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><line  y1=\"0\" x2=\"200\" x1=\"0\" y2=\"200\"  fill=\"black\" stroke=\"red\" stroke-width=\"2.0\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "line")
            XCTAssert(SVGSerializer.serialize(node: node) == lineReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGPolygon() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let lineReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><polygon  points=\"200.0,10.0,250.0,190.0,160.0,210.0\"  fill=\"black\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "polygon")
            XCTAssert(SVGSerializer.serialize(node: node) == lineReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGPolyline() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let lineReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><polyline  points=\"0.0,40.0,40.0,40.0,40.0,80.0,80.0,80.0,80.0,120.0,120.0,120.0,120.0,160.0\"  fill=\"white\" stroke=\"red\" stroke-width=\"4.0\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "polyline")
            XCTAssert(SVGSerializer.serialize(node: node) == lineReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGRect() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let rectReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><rect  height=\"150\" x=\"50\" y=\"0\" width=\"150\"  fill=\"black\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "rect")
            XCTAssert(SVGSerializer.serialize(node: node) == rectReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGRoundRect() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let roundRectReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><rect  height=\"150\" ry=\"20\" rx=\"20\" width=\"150\"  fill=\"black\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "roundRect")
            XCTAssert(SVGSerializer.serialize(node: node) == roundRectReferenceContent)
        } catch {
            print(error)
        }
    }
    
    func testSVGTriangle() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let triangleReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><g><path  d=\"M 150 0L 75 200L 225 200z \"  fill=\"black\" stroke=\"black\" stroke-width=\"2.0\"/></g></svg>"
        do {
            let node = try SVGParser.parse(bundle:bundle, path: "triangle")
            XCTAssert(SVGSerializer.serialize(node: node) == triangleReferenceContent)
        } catch {
            print(error)
        }
    }
}
