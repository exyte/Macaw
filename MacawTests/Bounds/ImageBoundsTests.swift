//
//  ImageBoundsTests.swift
//  Macaw
//
//  Created by Victor Sukochev on 06/06/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

#if os(iOS)

import XCTest
@testable import Macaw

class ImageBoundsTests: XCTestCase {
    
    var context: RenderContext!
    
    override func setUp() {
        context = RenderContext(view: .none)
        
        UIGraphicsBeginImageContext(CGSize(width: 1500.0, height: 1500.0))
        let cgContext = UIGraphicsGetCurrentContext()
        context.cgContext = cgContext
        
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        UIGraphicsEndImageContext()
    }
    
    func testSrcAsPath() {
        let bundle = Bundle(for: type(of: TestUtils()))
        guard let path = bundle.path(forResource: "logo", ofType: "png") else {
            XCTFail()
            return
        }
        
        let image = Image(src: path)
        
        let renderer = ImageRenderer(image: image, ctx: context, animationCache: .none)
        renderer.render(force: false, opacity: 1.0)
        guard let bounds = image.bounds() else {
            XCTFail("Bounds not available")
            return
        }
        
        XCTAssert(bounds.w == 1174.0 && bounds.h == 862.0, "Wrong bounds for path src")
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
        
        let renderer = ImageRenderer(image: image, ctx: context, animationCache: .none)
        renderer.render(force: false, opacity: 1.0)
        guard let bounds = image.bounds() else {
            XCTFail("Bounds not available")
            return
        }
        
        XCTAssert(bounds.w == 1174.0 && bounds.h == 862.0, "Wrong bounds for base64 src")
    }
    
    func testInMemoryImage() {
        let bundle = Bundle(for: type(of: TestUtils()))
        guard let mImage = MImage(named: "logo.png", in: bundle, compatibleWith: .none) else {
            XCTFail()
            return
        }
        
        let image = Image(image: mImage)
        
        let renderer = ImageRenderer(image: image, ctx: context, animationCache: .none)
        renderer.render(force: false, opacity: 1.0)
        guard let bounds = image.bounds() else {
            XCTFail("Bounds not available")
            return
        }
        
        XCTAssert(bounds.w == 1174.0 && bounds.h == 862.0, "Wrong bounds for in-memory image")
    }
    
}

#endif
