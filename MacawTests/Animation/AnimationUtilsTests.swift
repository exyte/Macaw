//
//  AnimationUtilsTests.swift
//  Macaw
//
//  Created by Victor Sukochev on 28/04/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import XCTest
@testable import Macaw

class AnimationUtilsTests: XCTestCase {
    
    func testIndex() {
        let rootGroup = Group()
        let a = Node()
        rootGroup.contents.append(a)
        
        let aGroup = Group()
        let b = Node()
        let c = Node()
        aGroup.contents.append(b)
        aGroup.contents.append(c)
        rootGroup.contents.append(aGroup)
        
        let d = Node()
        let e = Node()
        rootGroup.contents.append(d)
        rootGroup.contents.append(e)
        
        XCTAssert(AnimationUtils.absoluteIndex(rootGroup) == 0)
        XCTAssert(AnimationUtils.absoluteIndex(a) == 1)
        XCTAssert(AnimationUtils.absoluteIndex(aGroup) == 2)
        XCTAssert(AnimationUtils.absoluteIndex(b) == 3)
        XCTAssert(AnimationUtils.absoluteIndex(c) == 4 )
        XCTAssert(AnimationUtils.absoluteIndex(d) == 5 )
        XCTAssert(AnimationUtils.absoluteIndex(e) == 6 )
    }
}
