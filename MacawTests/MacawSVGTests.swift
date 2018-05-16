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
            } else {
                XCTFail("No file \(referenceFile)")
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
        
        validate(node: node, referenceFile: "textBasicTransform")
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
        
        validate(node: group, referenceFile: "arcsgroup")
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
            } else {
                XCTFail("No file \(referenceFile)")
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
    
    func testTextAlign01() {
        validateJSON("text-align-01-b-manual")
    }
    
    func testPathsData07() {
        validateJSON("paths-data-07-t-manual")
    }
    
    func testColorProp01() {
        validateJSON("color-prop-01-b-manual")
    }
    
    func testShapesEllipse01() {
        validateJSON("shapes-ellipse-01-t-manual")
    }
    
    func testPathsData15() {
        validateJSON("paths-data-15-t-manual")
    }
    
    func testPathsData12() {
        validateJSON("paths-data-12-t-manual")
    }
    
    func testCoordsTrans06() {
        validateJSON("coords-trans-06-t-manual")
    }
    
    func testCoordsCoord01() {
        validateJSON("coords-coord-01-t-manual")
    }
    
    func testPaintingControl06() {
        validateJSON("painting-control-06-f-manual")
    }
    
    func testShapesLine02() {
        validateJSON("shapes-line-02-f-manual")
    }
    
    func testPathsData13() {
        validateJSON("paths-data-13-t-manual")
    }
    
    func testPaintingStroke02() {
        validateJSON("painting-stroke-02-t-manual")
    }
    
    func testPathsData01() {
        validateJSON("paths-data-01-t-manual")
    }
    
    func testPathsData06() {
        validateJSON("paths-data-06-t-manual")
    }
    
    func testCoordsTrans07() {
        validateJSON("coords-trans-07-t-manual")
    }
    
    func testCoordsTrans01() {
        validateJSON("coords-trans-01-b-manual")
    }
    
    func testPaintingStroke01() {
        validateJSON("painting-stroke-01-t-manual")
    }
    
    func testShapesIntro01() {
        validateJSON("shapes-intro-01-t-manual")
    }
    
    func testCoordsTransformattr05() {
        validateJSON("coords-transformattr-05-f-manual")
    }
    
    func testCoordsTransformattr02() {
        validateJSON("coords-transformattr-02-f-manual")
    }
    
    func testPaintingFill03() {
        validateJSON("painting-fill-03-t-manual")
    }
    
    func testShapesRect05() {
        validateJSON("shapes-rect-05-f-manual")
    }
    
    func testPaintingFill04() {
        validateJSON("painting-fill-04-t-manual")
    }
    
    func testShapesPolyline01() {
        validateJSON("shapes-polyline-01-t-manual")
    }
    
    func testShapesPolygon02() {
        validateJSON("shapes-polygon-02-t-manual")
    }
    
    func testPaintingFill05() {
        validateJSON("painting-fill-05-b-manual")
    }
    
    func testStructFrag01() {
        validateJSON("struct-frag-01-t-manual")
    }
    
    func testShapesLine01() {
        validateJSON("shapes-line-01-t-manual")
    }
    
    func testPathsData17() {
        validateJSON("paths-data-17-f-manual")
    }
    
    func testRenderElems02() {
        validateJSON("render-elems-02-t-manual")
    }
    
    func testPaintingFill02() {
        validateJSON("painting-fill-02-t-manual")
    }
    
    func testShapesRect04() {
        validateJSON("shapes-rect-04-f-manual")
    }
    
    func testCoordsTransformattr03() {
        validateJSON("coords-transformattr-03-f-manual")
    }
    
    func testCoordsTransformattr04() {
        validateJSON("coords-transformattr-04-f-manual")
    }
    
    func testRenderElems03() {
        validateJSON("render-elems-03-t-manual")
    }
    
    func testTextFonts02() {
        validateJSON("text-fonts-02-t-manual")
    }
    
    func testShapesPolygon01() {
        validateJSON("shapes-polygon-01-t-manual")
    }
    
    func testPaintingStroke08() {
        validateJSON("painting-stroke-08-t-manual")
    }
    
    func testCoordsTransformattr01() {
        validateJSON("coords-transformattr-01-f-manual")
    }
    
    func testCoordsTrans09() {
        validateJSON("coords-trans-09-t-manual")
    }
    
    func testShapesCircle02() {
        validateJSON("shapes-circle-02-t-manual")
    }
    
    func testRenderElems01() {
        validateJSON("render-elems-01-t-manual")
    }
    
    func testPserversGradStops01() {
        validateJSON("pservers-grad-stops-01-f-manual")
    }
    
    func testStructFrag02() {
        validateJSON("struct-frag-02-t-manual")
    }
    
    func testPaintingStroke03() {
        validateJSON("painting-stroke-03-t-manual")
    }
    
    func testPaintingStroke09() {
        validateJSON("painting-stroke-09-t-manual")
    }
    
    func testCoordsTrans08() {
        validateJSON("coords-trans-08-t-manual")
    }
    
    func testPaintingFill01() {
        validateJSON("painting-fill-01-t-manual")
    }
    
    func testTextFonts01() {
        validateJSON("text-fonts-01-t-manual")
    }
    
    func testStructFrag04() {
        validateJSON("struct-frag-04-t-manual")
    }
    
    func testStructFrag03() {
        validateJSON("struct-frag-03-t-manual")
    }
    
    func testStructUse12() {
        validateJSON("struct-use-12-f-manual")
    }
    
    func testStructUse03() {
        validateJSON("struct-use-03-t-manual")
    }
    
    func testColorProp03() {
        validateJSON("color-prop-03-t-manual")
    }
    
    func testTypesBasic01() {
        validateJSON("types-basic-01-f-manual")
    }
    
    func testShapesEllipse02() {
        validateJSON("shapes-ellipse-02-t-manual")
    }
    
    func testPaintingControl02() {
        validateJSON("painting-control-02-f-manual")
    }
    
    func testCoordsCoord02() {
        validateJSON("coords-coord-02-t-manual")
    }
    
    func testCoordsTrans05() {
        validateJSON("coords-trans-05-t-manual")
    }
    
    func testCoordsTrans02() {
        validateJSON("coords-trans-02-t-manual")
    }
    
    func testPathsData02() {
        validateJSON("paths-data-02-t-manual")
    }
    
    func testPathsData19() {
        validateJSON("paths-data-19-f-manual")
    }
    
    func testStructGroup01() {
        validateJSON("struct-group-01-t-manual")
    }
    
    func testPaintingStroke05() {
        validateJSON("painting-stroke-05-t-manual")
    }
    
    func testCoordsTrans03() {
        validateJSON("coords-trans-03-t-manual")
    }
    
    func testCoordsTrans04() {
        validateJSON("coords-trans-04-t-manual")
    }
    
    func testMetadataExample01() {
        validateJSON("metadata-example-01-t-manual")
    }
    
    func testStructDefs01() {
        validateJSON("struct-defs-01-t-manual")
    }
    
    func testPaintingControl03() {
        validateJSON("painting-control-03-f-manual")
    }
    
    func testPaintingControl01() {
        validateJSON("painting-control-01-f-manual")
    }
    
    func testPathsData14() {
        validateJSON("paths-data-14-t-manual")
    }
    
    func testPaintingStroke06() {
        validateJSON("painting-stroke-06-t-manual")
    }
    
    func testShapesEllipse03() {
        validateJSON("shapes-ellipse-03-f-manual")
    }
    
    func testStructFrag06() {
        validateJSON("struct-frag-06-t-manual")
    }
    
    func testShapesPolygon03() {
        validateJSON("shapes-polygon-03-t-manual")
    }
    
    func testPathsData03() {
        validateJSON("paths-data-03-f-manual")
    }
    
    func testPathsData08() {
        validateJSON("paths-data-08-t-manual")
    }
    
    func testPathsData09() {
        validateJSON("paths-data-09-t-manual")
    }
    
    func testPathsData16() {
        validateJSON("paths-data-16-t-manual")
    }
    
    func testPathsData04() {
        validateJSON("paths-data-04-t-manual")
    }
    
    func testPaintingStroke04() {
        validateJSON("painting-stroke-04-t-manual")
    }
    
    func testPathsData05() {
        validateJSON("paths-data-05-t-manual")
    }
    
    func testPathsData10() {
        validateJSON("paths-data-10-t-manual")
    }
}
