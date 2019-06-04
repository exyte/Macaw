//
//  ImageBoundsTests.swift
//  Macaw
//
//  Created by Victor Sukochev on 06/06/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import XCTest

#if os(OSX)
@testable import MacawOSX
#elseif os(iOS)
@testable import Macaw
#endif

class ImageBoundsTests: XCTestCase {
    
    func testSrcAsPath() {
        let bundle = Bundle(for: type(of: TestUtils()))
        guard let path = bundle.path(forResource: "logo", ofType: "png") else {
            XCTFail()
            return
        }
        
        let image = Image(src: path)
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
        let bundle = Bundle(for: type(of: TestUtils()))
        guard let path = bundle.path(forResource: "logo_base64", ofType: "txt") else {
            XCTFail()
            return
        }
        
        let url = URL(fileURLWithPath: path)
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
        let bundle = Bundle(for: type(of: TestUtils()))
        
        #if os(iOS)
        guard let mImage = MImage(named: "logo.png", in: bundle, compatibleWith: .none) else {
            XCTFail()
            return
        }
        
        #elseif os(OSX)
        guard let mImage = bundle.image(forResource: "logo.png") else {
            XCTFail()
            return
        }
        #endif
        
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
