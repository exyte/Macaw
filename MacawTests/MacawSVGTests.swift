import XCTest

#if os(OSX)
@testable import MacawOSX
#elseif os(iOS)
@testable import Macaw
#endif

class MacawSVGTests: XCTestCase {
    
    /*
     When test are running, if shouldSaveFaildedTestImage set to true, result images will be saved into MacawTestOutputData folder in documents.
     
     Also, there is no way to detect that multiple test will runs.
     In this case, when all MacawSVGTests will be performed, set multipleTestsWillRun to true, then all test images will be saved to the folder.
     
     Then, if you want to investigate one particular test result, set multipleTestsWillRun to false and test folder will be deleted before new test will run.
     */
    
    private let testFolderName = "MacawTestOutputData"
    private let shouldComparePNGImages = true
    private let multipleTestsWillRun = false
    private let shouldSaveFailedTestImage = false
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        if shouldSaveFailedTestImage {
            setupTestFolderDirectory()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func compareResults(nodeContent: String?, referenceContent: String?) {
        guard let nodeContent = nodeContent else {
            XCTFail("nodeContent is empty")
            return
        }
        guard let referenceContent = referenceContent else {
            XCTFail("referenceContent is empty")
            return
        }

        if nodeContent != referenceContent {
            XCTFail("nodeContent is not equal to referenceContent" + TestUtils.prettyFirstDifferenceBetweenStrings(s1: nodeContent, s2: referenceContent))
        }
    }

    func validate(node: Node, referenceFile: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        
        do {
            if let path = bundle.path(forResource: referenceFile, ofType: "reference") {
                let clipReferenceContent = try String.init(contentsOfFile: path).trimmingCharacters(in: .newlines)
                let result = SVGSerializer.serialize(node: node)
                compareResults(nodeContent: result, referenceContent: clipReferenceContent)
            } else {
                XCTFail("No file \(referenceFile)")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func validate(_ testResource: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let node = try SVGParser.parse(resource: testResource, fromBundle: bundle)
            validate(node: node, referenceFile: testResource)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func createWithPath(_ testResourcePath: String) {
        do {
            let node = try SVGParser.parse(fullPath: testResourcePath)
            let result = SVGSerializer.serialize(node: node)
            let path = testResourcePath.replacingOccurrences(of: ".svg", with: ".reference")
            try result.write(to: URL(fileURLWithPath: path), atomically: true, encoding: String.Encoding.utf8)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func createReference(node: Node, name: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let result = SVGSerializer.serialize(node: node)
            let path = bundle.bundlePath + "/" + name + ".reference"
            try result.write(to: URL(fileURLWithPath: path), atomically: true, encoding: String.Encoding.utf8)
        } catch {
            XCTFail(error.localizedDescription)
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
        let node = Ellipse(cx: 20, cy: 20, rx: 20, ry:20).arc(shift: 0, extent: 6.28318500518799).fill(with: Color.clear)
        node.stroke = Stroke(fill: Color.clear)

        validate(node: node, referenceFile: "clearColor")
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
            if let mImage = MImage(contentsOfFile: path), let base64Content = MImagePNGRepresentation(mImage)?.base64EncodedString() {
                let imageSize = mImage.size
                let imageReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\"  ><image    xlink:href=\"data:image/png;base64,\(String(base64Content))\" width=\"\(imageSize.width)\" height=\"\(imageSize.height)\" /></svg>"
                
                let node = Image(image: mImage)
                let imageSerialization = SVGSerializer.serialize(node: node)
                XCTAssertEqual(imageSerialization, imageReferenceContent)
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
            if let path = bundle.path(forResource: referenceFile, ofType: "reference") {

                let referenceContent = try String(contentsOfFile: path)
                let nodeContent = String(data: getJSONData(node: node), encoding: String.Encoding.utf8)
                compareResults(nodeContent: nodeContent, referenceContent: referenceContent)
                
                let nativeImage = getImage(from: referenceFile)
            
                //To save new PNG image for test, uncomment this
                //saveImage(image: nativeImage, fileName: referenceFile)
                #if os(OSX)
                if shouldComparePNGImages {
                    validateImage(nodeImage: nativeImage, referenceFile: referenceFile)
                }
                #endif
            } else {
                XCTFail("No file \(referenceFile)")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func validateJSON(_ testResource: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let node = try SVGParser.parse(resource: testResource, fromBundle: bundle)
            validateJSON(node: node, referenceFile: testResource)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func validateImage(nodeImage: MImage, referenceFile: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        
        guard let fullpath = bundle.path(forResource: referenceFile, ofType: "png"), let referenceImage = MImage(contentsOfFile: fullpath) else {
            XCTFail("No reference image \(referenceFile)")
            return
        }
        
        #if os(OSX)
        guard let referenceContentData = referenceImage.tiffRepresentation else {
            XCTFail("Failed to get Data from png \(referenceFile).png")
            return
        }
        
        guard let nodeContentData = nodeImage.tiffRepresentation else {
            XCTFail("Failed to get Data from reference image \(referenceFile)")
            return
        }
        #endif
        
        #if os(iOS)
        guard let referenceContentData = referenceImage.pngData() else {
            XCTFail("Failed to get Data from png \(referenceFile).png")
            return
        }
        
        guard  let nodeContentData = nodeImage.pngData() else {
            XCTFail("Failed to get Data from reference image \(referenceFile)")
            return
        }
        #endif
        
        if referenceContentData != nodeContentData {
            
            var failInfo = "referenceImageData is not equal to nodeImageData"
            
            if shouldSaveFailedTestImage {
                let _ = saveImage(image: referenceImage, fileName: referenceFile + "_reference")
                let _ = saveImage(image: nodeImage, fileName: referenceFile + "_incorrect")
                
                failInfo.append("\n Images are saved in \(testFolderName) folder in Documents directory")
            }
            
            XCTFail(failInfo)
        }
    }

    func createJSON(_ testResourcePath: String) {
        do {
            let bundle = Bundle(for: type(of: TestUtils()))
            let node = try SVGParser.parse(resource: testResourcePath, fromBundle: bundle)
            let fileName = testResourcePath + ".reference"
            let jsonData = getJSONData(node: node)
            print("New reference file in \(String(writeToFile(data: jsonData, fileName: fileName)!.path))")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func getJSONData(node: Node) -> Data {
        guard let serializableNode = node as? Serializable else {
            XCTFail()
            return Data()
        }
        do {
            #if os(OSX)
            if #available(OSX 10.13, *) {
                return try JSONSerialization.data(withJSONObject: serializableNode.toDictionary(), options: [.prettyPrinted, .sortedKeys])
            } else {
                return try JSONSerialization.data(withJSONObject: serializableNode.toDictionary(), options: .prettyPrinted)
            }
            #endif
            
            #if os(iOS)
            if #available(iOS 11.0, *) {
                return try JSONSerialization.data(withJSONObject: serializableNode.toDictionary(), options: [.prettyPrinted, .sortedKeys])
            } else {
                return try JSONSerialization.data(withJSONObject: serializableNode.toDictionary(), options: .prettyPrinted)
            }
            #endif
        } catch {
            XCTFail(error.localizedDescription)
            return Data()
        }
    }
    
    func writeToFile(string: String, fileName: String) -> URL? {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) as NSURL else {
            return .none
        }
        do {
            let path = directory.appendingPathComponent("\(fileName)")!
            try string.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            return path
        } catch {
            print(error.localizedDescription)
            return .none
        }
    }

    func writeToFile(data: Data, fileName: String) -> URL? {
        guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL,
            let testDirectory = documentDirectory.appendingPathComponent(testFolderName) else {
                return .none
        }
        do {
            let path = testDirectory.appendingPathComponent("\(fileName)")
            try data.write(to: path)
            return path
        } catch {
            XCTFail(error.localizedDescription)
            return .none
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
    
    func testColorProp05() {
        validateJSON("color-prop-05-t-manual")
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
    
    func testCoordsTrans01() {
        validateJSON("coords-trans-01-b-manual")
    }
    
    func testCoordsTrans02() {
        validateJSON("coords-trans-02-t-manual")
    }
    
    func testCoordsTrans03() {
        validateJSON("coords-trans-03-t-manual")
    }
    
    func testCoordsTrans04() {
        validateJSON("coords-trans-04-t-manual")
    }
    
    func testCoordsTrans05() {
        validateJSON("coords-trans-05-t-manual")
    }
    
    func testCoordsTrans06() {
        validateJSON("coords-trans-06-t-manual")
    }
    
    func testCoordsTrans07() {
        validateJSON("coords-trans-07-t-manual")
    }
    
    func testCoordsTrans08() {
        validateJSON("coords-trans-08-t-manual")
    }
    
    func testCoordsTrans09() {
        validateJSON("coords-trans-09-t-manual")
    }
    
    func testCoordsTrans10() {
        validateJSON("coords-trans-10-f-manual")
    }
    
    func testCoordsTrans11() {
        validateJSON("coords-trans-11-f-manual")
    }
    
    func testCoordsTrans12() {
        validateJSON("coords-trans-12-f-manual")
    }
    
    func testCoordsTrans13() {
        validateJSON("coords-trans-13-f-manual")
    }
    
    func testCoordsTrans14() {
        validateJSON("coords-trans-14-f-manual")
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
    
    func testPaintingStroke07() {
        validateJSON("painting-stroke-07-t-manual")
    }
    
    func testPathsData18() {
        validateJSON("paths-data-18-f-manual")
    }

    func testPathsData01() {
        validateJSON("paths-data-01-t-manual")
    }
    
    func testPathsData06() {
        validateJSON("paths-data-06-t-manual")
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
    
    func testShapesRect02() {
        validateJSON("shapes-rect-02-t-manual")
    }
    
    func testShapesRect03() {
        validateJSON("shapes-rect-03-t-manual")
    }
    
    func testShapesRect04() {
        validateJSON("shapes-rect-04-f-manual")
    }
    
    func testShapesRect05() {
        validateJSON("shapes-rect-05-f-manual")
    }
    
    func testShapesRect06() {
        validateJSON("shapes-rect-06-f-manual")
    }
    
    func testShapesRect07() {
        validateJSON("shapes-rect-07-f-manual")
    }
    
    func testPaintingFill04() {
        validateJSON("painting-fill-04-t-manual")
    }
    
    func testShapesPolyline01() {
        validateJSON("shapes-polyline-01-t-manual")
    }
    
    func testShapesPolyline02() {
        validateJSON("shapes-polyline-02-t-manual")
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
    
    func testShapesCircle01() {
        validateJSON("shapes-circle-01-t-manual")
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
    
    func testStructUse01() {
        validateJSON("struct-use-01-t-manual")
    }
    
    func testStructUse03() {
        validateJSON("struct-use-03-t-manual")
    }
    
    func testStructUse12() {
        validateJSON("struct-use-12-f-manual")
    }
    
    func testColorProp03() {
        validateJSON("color-prop-03-t-manual")
    }
    
    func testColorProp04() {
        #if os(iOS)
        validateJSON("color-prop-04-t-manual")
        #elseif os(OSX)
        validateJSON("color-prop-04-t-manual-osx")
        #endif
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
    
    func testPathsData02() {
        validateJSON("paths-data-02-t-manual")
    }
    
    func testPathsData19() {
        validateJSON("paths-data-19-f-manual")
    }
    
    func testPathsData20() {
        validateJSON("paths-data-20-f-manual")
    }
    
    func testStructGroup01() {
        validateJSON("struct-group-01-t-manual")
    }
    
    func testPaintingStroke05() {
        validateJSON("painting-stroke-05-t-manual")
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

    func testShapesGrammar01() {
        validateJSON("shapes-grammar-01-f-manual")
    }
    
    func testPserversGrad01() {
        validateJSON("pservers-grad-01-b-manual")
    }
    
    func testPserversGrad02() {
        validateJSON("pservers-grad-02-b-manual")
    }
    
    func testPserversGrad03() {
        validateJSON("pservers-grad-03-b-manual")
    }
    
    func testPserversGrad07() {
        validateJSON("pservers-grad-07-b-manual")
    }
    
    func testPserversGrad09() {
        validateJSON("pservers-grad-09-b-manual")
    }
    
    func testPserversGrad12() {
        validateJSON("pservers-grad-12-b-manual")
    }
    
    func testPserversGrad13() {
        validateJSON("pservers-grad-13-b-manual")
    }
    
    func testPserversGrad15() {
        validateJSON("pservers-grad-15-b-manual")
    }
    
    func testPserversGrad22() {
        validateJSON("pservers-grad-22-b-manual")
    }
    
    func testPserversGrad23() {
        validateJSON("pservers-grad-23-f-manual")
    }
    
    func testPserversGrad24() {
        validateJSON("pservers-grad-24-f-manual")
    }
    
    func testMaskingIntro01() {
        validateJSON("masking-intro-01-f-manual")
    }
    
    func testMaskingFilter01() {
        validateJSON("masking-filter-01-f-manual")
    }
    
    func testMaskingPath02() {
        validateJSON("masking-path-02-b-manual")
    }
    
    func testMaskingPath13() {
        validateJSON("masking-path-13-f-manual")
    }
    
    func testMaskingMask02() {
        validateJSON("masking-mask-02-f-manual")
    }
    
    func getImage(from svgName: String) -> MImage {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let node = try SVGParser.parse(resource: svgName, fromBundle: bundle)
            
            var frame = node.bounds
            if frame == nil, let group = node as? Group {
                frame = Group(contents: group.contents).bounds
            }
            
            let image = node.toNativeImage(size: frame?.size() ?? Size.init(w: 100, h: 100))
            return image
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        XCTFail()
        return MImage()
    }
    
    func saveImage(image: MImage, fileName: String) {
        #if os(OSX)
        guard let data = image.tiffRepresentation else {
            return
        }
        #endif
        
        #if os(iOS)
        guard let data = image.pngData() else {
            return
        }
        #endif
        
        let _ = writeToFile(data: data, fileName: "\(fileName).png")
    }
    
    fileprivate func setupTestFolderDirectory() {
        guard let myDocuments = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let testDirectoryPath = myDocuments.appendingPathComponent("\(testFolderName)")
        
        do {
            if !multipleTestsWillRun {
                try FileManager.default.removeItem(at: testDirectoryPath)
            }
            
            var isDirectory: ObjCBool = ObjCBool(true)
            if !FileManager.default.fileExists(atPath: testDirectoryPath.absoluteString, isDirectory: &isDirectory) {
                try FileManager.default.createDirectory(at: testDirectoryPath, withIntermediateDirectories: true, attributes: .none)
            }
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
    }

}
