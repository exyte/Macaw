//
//  NodeBoundsTests.swift
//  Macaw
//
//  Created by Daniil Manin on 5/10/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

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
        let shape = Shape(form: Ellipse(cx: 100.0, cy: 50.0, rx: 3.0, ry: 7.0))
        let targetRect = Rect(x: 97.0, y: 43.0, w: 6.0, h: 14.0)
        
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
    }
    
    func testShapePath() {
        // TODO 
    }
    
    func testShapeLine() {
        let shape = Shape(form: Line(x1: 10.0, y1: 15.0, x2: 1.0, y2: 1.0))
        let targetRect = Rect(x: 1.0, y: 1.0, w: 9.0, h: 14.0)
        
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
    }
    
    func testShapePolyline() {
        // Polyline / Polygon

        let points: [Double] = [ 0, 2,
                                 1, 7,
                                 8, 8,
                                 100, 10,
                                 -5, 3]
        
        let shape = Shape(form: Polyline(points: points))
        let targetRect = Rect(x: -5.0, y: 2.0, w: 105.0, h: 8.0)
        
        checkBounds(rect1: shape.bounds(), rect2: targetRect)
    }
    
    func testSimpleImageZeroBounds() {
        let image = Image(src: "")
        
        XCTAssertNil(image.bounds(), "Image bounds not nil")
    }

    func testSimpleTextZeroBounds() {
        let text = Text(text: "")
        
        let stringAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        let size = text.text.size(attributes: stringAttributes)
        let targetRect = Rect(x: 0.0, y: 0.0, w: 0.0, h: Double(size.height))
        
        checkBounds(rect1: text.bounds(), rect2: targetRect)
    }
    
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
