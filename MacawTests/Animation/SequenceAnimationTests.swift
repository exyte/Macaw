//
//  SequenceAnimationTests.swift
//  Macaw
//
//  Created by Victor Sukochev on 21/02/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

#if os(iOS)

import XCTest
@testable import Macaw

class SequenceAnimationTests: XCTestCase {
    
    var testView: MacawView!
    var testGroup: Group!
    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        
        testGroup = [Shape(form:Rect(x: 0.0, y: 0.0, w: 0.0, h: 0.0))].group()
        testView = MacawView(node: testGroup, frame: CGRect.zero)
        
        window = UIWindow()
        window.addSubview(testView)
    }
    
    func testStates() {
        let anim1 = testGroup.placeVar.animation(to: Transform.move(dx: 1.0, dy: 1.0), during: 1000.0) as! TransformAnimation
        let anim2 = testGroup.opacityVar.animation(to: 0.0, during: 1000.0) as! OpacityAnimation
        let anim3 = testGroup.contentsVar.animation ({ t -> [Node] in
            return [Shape(form:Rect(x: 0.0, y: 0.0, w: t, h: t))]
        }, during: 1000.0) as! ContentsAnimation
        
        let sequence1 = [
            anim1,
            anim2,
            anim3
            ].sequence() as! AnimationSequence
        
        sequence1.play()
        
        // PAUSE
        let pauseExpectation = expectation(description: "pause expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            pauseExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Async test failed")
        }
        
        sequence1.pause()
        
        let pauseEffectExpectation = expectation(description: "pause effect expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            pauseEffectExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Async test failed")
        }
        
        XCTAssert(sequence1.paused && anim1.paused && !anim2.paused && !anim3.paused, "Inner animations incorrect state: pause")
        XCTAssert(!sequence1.manualStop && !anim1.manualStop && !anim2.manualStop && !anim3.manualStop, "Inner animations incorrect state: pause")
         XCTAssert(testGroup.place.dx != 0.0 && testGroup.place.dx != 1.0, "Transform animation wrong node state on pause")
        
        sequence1.play()
        
        XCTAssert(!sequence1.paused && !anim1.paused && !anim2.paused && !anim3.paused, "Inner animations incorrect state: play")
        XCTAssert(!sequence1.manualStop && !anim1.manualStop && !anim2.manualStop && !anim3.manualStop, "Inner animations incorrect state: play")
        
        sequence1.stop()
        
        //STOP
    }
    
}

#endif
