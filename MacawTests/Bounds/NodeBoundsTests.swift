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
    
    // MARK: - Shapes
    
    func testSimpleShapeZeroBounds() {
        let shape = Shape(form: Rect.zero())
    
        checkBounds(rect1: shape.bounds(), rect2: Rect.zero())
    }
    
    func testSimpleShapeRect() {
        // Rect / RoundRect
        let shape = Shape(form: RoundRect(rect: Rect(x: 20.0, y: 15.0, w: 10.0, h: 10.0), rx: 8.0, ry: 1.0))
        let targetRect = Rect(x: 20.0, y: 15.0, w: 10.0, h: 10.0)
        
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
    }
    
    func testShapePoint() {
        let shape = Shape(form: Point(x: 10.0, y: 20.0))
        let targetRect = Rect(x: 10.0, y: 20.0, w: 0.0, h: 0.0)
        
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
    }
    
    func testShapeCircle() {
        let shape = Shape(form: Circle(cx: 10.0, cy: 15.0, r: 3.0))
        let targetRect = Rect(x: 7.0, y: 12.0, w: 6.0, h: 6.0)
        
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
    }
    
    func testShapeEllipse() {
        // Ellipse / Arc
        let targetRect = Rect(x: 97.0, y: 43.0, w: 6.0, h: 14.0)
        let ellipse = Ellipse(cx: 100.0, cy: 50.0, rx: 3.0, ry: 7.0)
        
        var shape = Shape(form: ellipse)
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
        
        shape = Shape(form: Arc(ellipse: ellipse, shift: 2.0, extent: 3.0))
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
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
        
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
    }
    
    func testShapeLine() {
        let shape = Shape(form: Line(x1: 10.0, y1: 15.0, x2: 1.0, y2: 1.0))
        let targetRect = Rect(x: 1.0, y: 1.0, w: 9.0, h: 14.0)
        
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
    }
    
    func testShapePoly(points: [Double], targetRect: Rect) {
        var shape = Shape(form: Polyline(points: points))
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
        
        shape = Shape(form: Polygon(points: points))
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
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
        
        XCTAssertNil(image.bounds(), "Image bounds not nil")
    }

    // MARK: - Text
    
    func testSimpleText() {
        let texts = ["", "Hello, World", "Hello,\nWorld", "\nHello\n,\nWorld"]
        
        texts.forEach { text in
            let text = Text(text: text)
            
            let stringAttributes = [NSAttributedStringKey.font: MFont.systemFont(ofSize: MFont.systemFontSize)]
            let size = text.text.size(withAttributes: stringAttributes)
            let targetRect = Rect(x: 0.0, y: 0.0, w: size.width.doubleValue, h: size.height.doubleValue)
            
            checkBounds(rect1: text.bounds(), rect2: targetRect)
        }
    }
    
    // MARK: - Group
    
    func testSimpleGroupZeroBounds() {
        let group = [].group()
        
        XCTAssertNil(group.bounds(), "Group bounds not nil")
    }
    
    func testGroupZeroBounds() {
        var shapes: [Node] = []
        for _ in 0...10 {
            let shape = Shape(form: Rect.zero())
            shapes.append(shape)
        }
        
        let group = shapes.group()
        checkBounds(rect1: group.bounds(), rect2: Rect.zero())
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
        checkBounds(rect1: group.bounds(), rect2: targetRect)
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
        checkBounds(rect1: group.bounds(), rect2: targetRect)
    }
}

#endif
