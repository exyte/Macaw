//
//  DelayedAnimationTests.swift
//  Macaw
//
//  Created by Victor Sukochev on 21/02/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import XCTest

#if os(OSX)
@testable import MacawOSX
#elseif os(iOS)
@testable import Macaw
#endif

class DelayedAnimationTests: XCTestCase {
    
    var testView: MacawView!
    var testGroup: Group!
    var window: MWindow!
    
    override func setUp() {
        super.setUp()
        
        testGroup = [Shape(form:Rect(x: 0.0, y: 0.0, w: 0.0, h: 0.0))].group()
        testView = MacawView(node: testGroup, frame: .zero)
        
        window = MWindow()
        window.addSubview(testView)
    }
    
    func testStates() {
        let animation = testGroup.placeVar.animation(to: Transform.move(dx: 1.0, dy: 1.0), delay: 1000.0) as! TransformAnimation
        animation.play()
        
        let playExpectation = expectation(description: "play expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            playExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Async test failed")
        }
        
        animation.pause()
        let pauseExpectation = expectation(description: "pause expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            pauseExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Async test failed")
        }
        
        XCTAssert(animation.paused && !animation.manualStop, "Wrong animation state on pause")
    }
}
