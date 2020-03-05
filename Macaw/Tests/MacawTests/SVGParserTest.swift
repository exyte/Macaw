//
//  SVGParserTest.swift
//  MacawTests
//
//  Created by Julius Lundang on 19/08/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import XCTest

@testable import Macaw

class SVGParserTest: XCTestCase {
    func testParseFromOtherBundle() {
        guard let bundleURL = TestUtils.getResource(group: "bundle", name: "BundleTest", type: "bundle"), let bundle = Bundle(url: bundleURL) else {
            XCTFail()
            return
        }
        
        do {
            let node = try SVGParser.parse(resource: "circle", fromBundle: bundle)
            XCTAssertNotNil(node)
            if let fullPath = bundle.path(forResource: "circle", ofType: "svg") {
                let node2 = try SVGParser.parse(fullPath: fullPath)
                XCTAssertNotNil(node2)
            } else {
                XCTFail("No circle.svg found")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testParseGivenInvalidPath() {
        let fullPath = "invalid fullPath"
        XCTAssertThrowsError(try SVGParser.parse(fullPath: fullPath)) { error in
            XCTAssertEqual(error as! SVGParserError, SVGParserError.noSuchFile(path: "invalid fullPath"))
        }
    }
    
    func testParseGiventEmptyPath() {
        XCTAssertThrowsError(try SVGParser.parse(fullPath: "")) { error in
            XCTAssertEqual(error as! SVGParserError, SVGParserError.noSuchFile(path: ""))
        }
    }
}
