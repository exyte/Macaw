//
//  ImageBoundsTests.swift
//  Macaw
//
//  Created by Victor Sukochev on 06/06/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import XCTest

@testable import Macaw

class ImageBoundsTests: XCTestCase {
    
    func testSrcAsPath() {
        guard let url = TestUtils.getResource(group: "bounds", name: "logo", type: "png") else {
            XCTFail()
            return
        }
        
        print(url.path)
        
        let image = Image(src: url.path)
        guard let bounds = image.bounds else {
            XCTFail("Bounds not available")
            return
        }
        
        #if os(iOS)
            XCTAssert(bounds.w == 1174.0 && bounds.h == 862.0, "Wrong bounds for path src")
        #elseif os(OSX)
            XCTAssert(bounds.w == 587.0 && bounds.h == 431.0, "Wrong bounds for path src")
        #endif
    }
    
    func testSrcAsBase64() {
        guard let url = TestUtils.getResource(group: "bounds", name: "logo_base64", type: "txt") else {
            XCTFail()
            return
        }
        
        guard let base64Content = try? String(contentsOf: url) else {
            XCTFail()
            return
        }
        
        let image = Image(src: base64Content)
        guard let bounds = image.bounds else {
            XCTFail("Bounds not available")
            return
        }
        
        #if os(iOS)
            XCTAssert(bounds.w == 1174.0 && bounds.h == 862.0, "Wrong bounds for base64 src")
        #elseif os(OSX)
            XCTAssert(bounds.w == 587.0 && bounds.h == 431.0, "Wrong bounds for base64 src")
        #endif
    }
    
    func testInMemoryImage() {
        guard let url = TestUtils.getResource(group: "bounds", name: "logo", type: "png") else {
            XCTFail()
            return
        }
        
        let mImage = MImage(contentsOf: url)!
        
        let image = Image(image: mImage)
        guard let bounds = image.bounds else {
            XCTFail("Bounds not available")
            return
        }
        
        #if os(iOS)
            XCTAssert(bounds.w == 1174.0 && bounds.h == 862.0, "Wrong bounds for in-memory image")
        #elseif os(OSX)
            XCTAssert(bounds.w == 587.0 && bounds.h == 431.0, "Wrong bounds for in-memory image")
        #endif
    }
    
}
