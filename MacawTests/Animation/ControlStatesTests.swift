//
//  ControlStatesTests.swift
//  Macaw
//
//  Created by Victor Sukochev on 20/02/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import XCTest
@testable import Macaw

class ControlStatesTests: XCTestCase {
    
    var testNode: Node!
    
    override func setUp() {
        super.setUp()
        
        testNode = Shape(form:Rect(x: 0.0, y: 0.0, w: 0.0, h: 0.0))
    }
    
    func testTransformAnimation() {
        let animation = testNode.placeVar.animation(to: .identity) as! TransformAnimation
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
        
        animation.pause()
        XCTAssert( animation.paused && !animation.manualStop, "Wrong animation state: pause")
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
        
        animation.stop()
        XCTAssert( !animation.paused && animation.manualStop, "Wrong animation state: pause")
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
    }
    
    func testOpacityAnimation() {
        let animation = testNode.opacityVar.animation(to: 0.0) as! OpacityAnimation
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
        
        animation.pause()
        XCTAssert( animation.paused && !animation.manualStop, "Wrong animation state: pause")
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
        
        animation.stop()
        XCTAssert( !animation.paused && animation.manualStop, "Wrong animation state: pause")
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
    }
    
    func testContentsAnimation() {
        let group = [testNode].group()
        let animation = group.contentsVar.animation {  t -> [Node] in
            return [self.testNode]
        } as! ContentsAnimation
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
        
        animation.pause()
        XCTAssert( animation.paused && !animation.manualStop, "Wrong animation state: pause")
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
        
        animation.stop()
        XCTAssert( !animation.paused && animation.manualStop, "Wrong animation state: pause")
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
    }
    
    func testCombineAnimation() {
        let animation = [
            testNode.placeVar.animation(to: .identity),
            testNode.opacityVar.animation(to: 0.0)
        ].combine() as! CombineAnimation
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
        
        animation.pause()
        XCTAssert( animation.paused && !animation.manualStop, "Wrong animation state: pause")
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
        
        animation.stop()
        XCTAssert( !animation.paused && animation.manualStop, "Wrong animation state: pause")
        
        animation.play()
        XCTAssert(!(animation.paused || animation.manualStop), "Wrong animation state: play")
    }
    
}
