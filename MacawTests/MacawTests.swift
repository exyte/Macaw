import XCTest
@testable import Macaw

class MacawTests: XCTestCase {

	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		super.setUp()
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testSVGTriangle() {
		XCTAssertTrue(TestUtils.compareWithReferenceObject("triangle", referenceObject: createTriangleReferenceObject()))
	}

	func testSVGLine() {
		XCTAssertTrue(TestUtils.compareWithReferenceObject("line", referenceObject: createLineReferenceObject()))
	}

	func testSVGRect() {
		XCTAssertTrue(TestUtils.compareWithReferenceObject("rect", referenceObject: createRectReferenceObject()))
	}

	func testSVGRoundRect() {
		XCTAssertTrue(TestUtils.compareWithReferenceObject("roundRect", referenceObject: createRoundRectReferenceObject()))
	}

	func testSVGPolygon() {
		XCTAssertTrue(TestUtils.compareWithReferenceObject("polygon", referenceObject: createPolygonReferenceObject()))
	}

	func testSVGPolyline() {
		XCTAssertTrue(TestUtils.compareWithReferenceObject("polyline", referenceObject: createPolylineReferenceObject()))
	}

	func testSVGCircle() {
		XCTAssertTrue(TestUtils.compareWithReferenceObject("circle", referenceObject: createCircleReferenceObject()))
	}

	func testSVGEllipse() {
		XCTAssertTrue(TestUtils.compareWithReferenceObject("ellipse", referenceObject: createEllipseReferenceObject()))
	}

	func testSVGGroup() {
		XCTAssertTrue(TestUtils.compareWithReferenceObject("group", referenceObject: createGroupReferenceObject()))
	}

	func createTriangleReferenceObject() -> Group {
		let path = MoveTo(x: 150, y: 0).lineTo(x: 75, y: 200).lineTo(x: 225, y: 200).close().build()
		return Group(contents: [Shape(form: path, stroke: Stroke(fill: Color.black, width: 2, cap: .round, join: .round))])
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

		return Group(contents: [Shape(form: polyline,
		                              fill: Color.white,
		                              stroke: Stroke(fill: Color.red, width: 4, cap: .round, join: .round))])
	}

	func createCircleReferenceObject() -> Group {
		let circle = Circle(cx: 50, cy: 50, r: 40)

		return Group(contents: [Shape(form: circle,
		                              fill: Color.red,
		                              stroke: Stroke(fill: Color.black, width: 3, cap: .round, join: .round))])
	}

	func createEllipseReferenceObject() -> Group {
		let ellipse = Ellipse(cx: 200, cy: 80, rx: 100, ry: 50)

		return Group(contents: [Shape(form: ellipse,
		                              fill: Color.yellow,
		                              stroke: Stroke(fill: Color.purple, width: 2, cap: .round, join: .round))])
	}

	func createGroupReferenceObject() -> Group {
		let pathShape = Shape(form: MoveTo(x: 150, y: 0).lineTo(x: 75, y: 200).lineTo(x: 225, y: 200).close().build(),
			stroke: Stroke(fill: Color.black, width: 2, cap: .round, join: .round))

		let lineShape = Shape(form: Line(x1: 0, y1: 0, x2: 200, y2: 200),
			stroke: Stroke(fill: Color.white, width: 2, cap: .round, join: .round))

		return Group(contents: [Group(contents: [pathShape, lineShape])])
	}
}
