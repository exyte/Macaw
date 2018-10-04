//
//  NodeBoundsTests.swift
//  Macaw
//
//  Created by Daniil Manin on 5/10/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

#if os(iOS)

import XCTest
@testable import Macaw

class NodeBoundsTests: XCTestCase {
    var window: UIWindow!
    
    //TO DO: need to test paths bounds: M 50 50 C 20 20, 40 20, 50 10 and M 50 50 c 20 20, 40 20, 50 10
    //currently doesn't work because of http://www.openradar.me/6468254639 or #41355347 on https://bugreport.apple.com/
    
    override func setUp() {
        super.setUp()
        
        window = UIWindow()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func checkBounds(rect1: Rect?, rect2: Rect) {
        if let rect = rect1 {
            XCTAssertTrue(rect == rect2, "Test failed. Rects not equal")
        }
    }
    
    func validate(node: Node, referenceBounds: Rect) {
        let passingThreshold = 0.2
        
        var testResult = false
        if let bounds = node.bounds {
            testResult = (Double(round(100*bounds.x)/100) - referenceBounds.x < passingThreshold)
            testResult = testResult && (Double(round(100*bounds.y)/100) - referenceBounds.y < passingThreshold)
            testResult = testResult && (Double(round(100*bounds.w)/100) - referenceBounds.w < passingThreshold)
            testResult = testResult && (Double(round(100*bounds.h)/100) - referenceBounds.h < passingThreshold)
        }
        
        XCTAssert(testResult)
    }
    
    // MARK: - Shapes
    
    func testSimpleShapeZeroBounds() {
        let shape = Shape(form: Rect.zero())
    
        checkBounds(rect1: shape.bounds, rect2: Rect.zero())
    }
    
    func testSimpleShapeRect() {
        // Rect / RoundRect
        let shape = Shape(form: RoundRect(rect: Rect(x: 20.0, y: 15.0, w: 10.0, h: 10.0), rx: 8.0, ry: 1.0))
        let targetRect = Rect(x: 20.0, y: 15.0, w: 10.0, h: 10.0)
        
        checkBounds(rect1: shape.bounds, rect2: targetRect)
    }
    
    func testShapePoint() {
        let shape = Shape(form: Point(x: 10.0, y: 20.0))
        let targetRect = Rect(x: 10.0, y: 20.0, w: 0.0, h: 0.0)
        
        checkBounds(rect1: shape.bounds, rect2: targetRect)
    }
    
    func testShapeCircle() {
        let shape = Shape(form: Circle(cx: 10.0, cy: 15.0, r: 3.0))
        let targetRect = Rect(x: 7.0, y: 12.0, w: 6.0, h: 6.0)
        
        checkBounds(rect1: shape.bounds, rect2: targetRect)
    }
    
    func testShapeEllipse() {
        // Ellipse / Arc
        let targetRect = Rect(x: 97.0, y: 43.0, w: 6.0, h: 14.0)
        let ellipse = Ellipse(cx: 100.0, cy: 50.0, rx: 3.0, ry: 7.0)
        
        let shape = Shape(form: ellipse)
        checkBounds(rect1: shape.bounds, rect2: targetRect)
    }
    
    func testShapePath() {
        let segment = PathSegment(type: .M, data: [0, 0])
        var builder = PathBuilder(segment: segment)
        
        builder = builder.lineTo(x: -5.0, y: 0.0)
        builder = builder.lineTo(x: 7.0, y: 4.0)
        builder = builder.lineTo(x: 0.0, y: -1.0)
        builder = builder.lineTo(x: 10.0, y: 0.0)
        
        builder = builder.moveTo(x: 20.0, y: 20.0)
        builder = builder.lineTo(x: 25.0, y: 25.0)
        
        let path = builder.build()
        let shape = Shape(form: path)
        let targetRect = Rect(x: -5.0, y: -1.0, w: 30.0, h: 26.0)
        
        checkBounds(rect1: shape.bounds, rect2: targetRect)
    }
    
    func testShapeLine() {
        let shape = Shape(form: Line(x1: 10.0, y1: 15.0, x2: 1.0, y2: 1.0))
        let targetRect = Rect(x: 1.0, y: 1.0, w: 9.0, h: 14.0)
        
        checkBounds(rect1: shape.bounds, rect2: targetRect)
    }
    
    func testShapePoly(points: [Double], targetRect: Rect) {
        var shape = Shape(form: Polyline(points: points))
        checkBounds(rect1: shape.bounds, rect2: targetRect)
        
        shape = Shape(form: Polygon(points: points))
        checkBounds(rect1: shape.bounds, rect2: targetRect)
    }
    
    func testShapePoly() {
        let points: [Double] = [ 0, 2,
                                 1, 7,
                                 8, 8,
                                 100, 10,
                                 -5, 3]
        let targetRect = Rect(x: -5.0, y: 2.0, w: 105.0, h: 8.0)
        
        testShapePoly(points: points, targetRect: targetRect)
    }
    
    func testShapePolyWithoutPoints() {
        let targetRect = Rect.zero()
        
        testShapePoly(points: [], targetRect: targetRect)
    }
    
    func testShapePolyOnePoint() {
        let points: [Double] = [7, 4]
        let targetRect = Rect(x: 7.0, y: 4.0, w: 0.0, h: 0.0)
        
        testShapePoly(points: points, targetRect: targetRect)
    }
    
    // MARK: - Image
    
    func testSimpleImageZeroBounds() {
        let image = Image(src: "")
        
        XCTAssertNil(image.bounds, "Image bounds not nil")
    }

    // MARK: - Text
    
    func testSimpleText() {
        let texts = ["", "Hello, World", "Hello,\nWorld", "\nHello\n,\nWorld"]
        
        texts.forEach { text in
            let text = Text(text: text)
            
            let stringAttributes = [NSAttributedString.Key.font: MFont.systemFont(ofSize: MFont.systemFontSize)]
            let size = text.text.size(withAttributes: stringAttributes)
            let targetRect = Rect(x: 0.0, y: 0.0, w: size.width.doubleValue, h: size.height.doubleValue)
            
            checkBounds(rect1: text.bounds, rect2: targetRect)
        }
    }
    
    // MARK: - Group
    
    func testSimpleGroupZeroBounds() {
        let group = [].group()
        
        XCTAssertNil(group.bounds, "Group bounds not nil")
    }
    
    func testGroupZeroBounds() {
        var shapes: [Node] = []
        for _ in 0...10 {
            let shape = Shape(form: Rect.zero())
            shapes.append(shape)
        }
        
        let group = shapes.group()
        checkBounds(rect1: group.bounds, rect2: Rect.zero())
    }
    
    func testGroupRectInRect() {
        //        *************
        //        *           *
        //        *  *******  *
        //        *  *     *  *
        //        *  *******  *
        //        *           *
        //        *************
        
        let targetRect = Rect(x: 0.0, y: 0.0, w: 100.0, h: 100.0)
        
        let shape = Shape(form: targetRect)
        let internalShape = Shape(form: Rect(x: 25.0, y: 25.0, w: 50.0, h: 50.0))
        
        let group = [shape, internalShape].group()
        checkBounds(rect1: group.bounds, rect2: targetRect)
    }
    
    func testGroupRectBetweenRects() {
        //        *************                 *************
        //        *           *                 *           *
        //        *           *     *******     *           *
        //        *           *     *     *     *           *
        //        *           *     *******     *           *
        //        *           *                 *           *
        //        *************                 *           *
        //                                      *           *
        //                                      *************
        
        let targetRect = Rect(x: 10.0, y: 0.0, w: 290.0, h: 150.0)
        
        let leftShape = Shape(form: Rect(x: 10.0, y: 0.0, w: 100.0, h: 100.0))
        let midShape = Shape(form: Rect(x: 125.0, y: 25.0, w: 50.0, h: 50.0))
        let rightShape = Shape(form: Rect(x: 200.0, y: 0.0, w: 100.0, h: 150.0))
        
        let group = [leftShape, midShape, rightShape].group()
        checkBounds(rect1: group.bounds, rect2: targetRect)
    }
    
    func testPathBounds1() {
        
        let path = MoveTo(x: 101.9, y: 40.5)
            .c(0, -1.8, 1.5, -3.3, 3.3, -3.3)
            .s(3.3, 1.5, 3.3, 3.3)
            .v(27.4)
            .c(0, 1.8, -1.5, 3.3, -3.3, 3.3)
            .s(-3.3, -1.5, -3.3, -3.3)
            .V(40.5).Z().build()
        
        let shape = Shape(form: path)
        
        let targetRect = Rect(x: 101.9, y: 37.2, w: 6.6, h: 34.0)
        validate(node: shape, referenceBounds: targetRect)
    }
    
    func testPathBounds2() {
        
        let path = MoveTo(x: 68, y: 101.9)
            .c(1.8, 0, 3.3, 1.5, 3.3, 3.3)
            .s(-1.5, 3.3, -3.3, 3.3)
            .H(40.5)
            .c(-1.8, 0, -3.3, -1.5, -3.3, -3.3)
            .s(1.5, -3.3, 3.3, -3.3)
            .H(68).Z().build()
        
        let shape = Shape(form: path)
        let stroke = Stroke(fill: Color.black, width: 1.0, cap: .butt, join: .miter, miterLimit: 4.0, dashes: [], offset: 0.0)
        shape.stroke = stroke
        
        let targetRect = Rect(x: 36.7, y: 101.4, w: 35.1, h: 7.6)
        validate(node: shape, referenceBounds: targetRect)
    }
    
    func testPathBounds3() {
        
        let path = MoveTo(x: 25, y: 49.5)
            .C(38.5309764, 49.5, 49.5, 38.5309764, 49.5, 25)
            .C(49.5, 11.4690236, 38.5309764, 0.5, 25, 0.5)
            .C(11.4690236, 0.5, 0.5, 11.4690236, 0.5, 25)
            .C(0.5, 38.5309764, 11.4690236, 49.5, 25, 49.5).Z().build()
        
        let shape = Shape(form: path)
        let stroke = Stroke(fill: Color.black, width: 1.0, cap: .butt, join: .miter, miterLimit: 4.0, dashes: [], offset: 0.0)
        shape.stroke = stroke
        
        let targetRect = Rect(x: 0.0, y: 0.0, w: 50, h: 50)
        validate(node: shape, referenceBounds: targetRect)
    }
    
    func testPathBounds4() {
        
        let path = MoveTo(x: 10, y: 80)
            .C(40, 10, 65, 10, 95, 80)
            .S(150, 150, 180, 80).build()
        
        let shape = Shape(form: path)
        
        let targetRect = Rect(x: 10, y: 10, w: 170, h: 140)
        validate(node: shape, referenceBounds: targetRect)
    }
    
    func testPolyline() {
        let polyline = Polyline(points: [270, 225, 300, 245, 320, 225, 340, 245, 280, 280, 390, 280, 420, 240, 280, 185])
        let stroke = Stroke(fill: Color(val: 30464), width: 8, cap: .butt, join: .miter, miterLimit: 4.0, dashes: [], offset: 0.0)
        let shape = Shape(form: polyline)
        shape.stroke = stroke
        
        let targetRect = Rect(x: 265.2, y: 181.3, w: 161.2, h: 102.7)
        validate(node: shape, referenceBounds: targetRect)
    }
}

#endif
