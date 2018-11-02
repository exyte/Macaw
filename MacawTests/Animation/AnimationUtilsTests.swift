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
        let a = Shape(form: Locus())
        rootGroup.contents.append(a)
        
        let bGroup = Group()
        let c = Shape(form: Locus())
        let d = Shape(form: Locus())
        bGroup.contents.append(c)
        bGroup.contents.append(d)
        rootGroup.contents.append(bGroup)
        
        let e = Shape(form: Locus())
        let f = Shape(form: Locus())
        rootGroup.contents.append(e)
        rootGroup.contents.append(f)

        let view = MacawView()
        view.node = rootGroup
        view.draw(CGRect(x: 0, y: 0, width: 100, height: 100))
        let rootRenderer = view.renderer as? GroupRenderer
        let aRenderer = rootRenderer?.renderers[0]
        let bRenderer = rootRenderer?.renderers[1] as? GroupRenderer
        let cRenderer = bRenderer?.renderers[0]
        let dRenderer = bRenderer?.renderers[1]
        let eRenderer = rootRenderer?.renderers[2]
        let fRenderer = rootRenderer?.renderers[3]
        
        XCTAssert(rootRenderer?.zPosition == 0)
        XCTAssert(aRenderer?.zPosition == 1)
        XCTAssert(bRenderer?.zPosition == 2)
        XCTAssert(cRenderer?.zPosition == 3)
        XCTAssert(dRenderer?.zPosition == 4 )
        XCTAssert(eRenderer?.zPosition == 5 )
        XCTAssert(fRenderer?.zPosition == 6 )
    }
}
