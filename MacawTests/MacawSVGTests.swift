import XCTest
@testable import Macaw

class MacawSVGTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    @available(iOS 10.0, *)
    func testSVGFromList() {
        let bundle = Bundle(for: type(of: TestUtils()))
        var count = 0
        if let path = bundle.path(forResource: "svglist", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let myStrings = data.components(separatedBy: .newlines)
                for name in myStrings {
                    count += 1
                    print ("PROCESSING ", count, " -- ", name)
                    let dst = "/Users/ykashnikov/exyte/svg-test-suite/macaw-svg/" + name + ".svg"
                    do {
                        let rootNode = try SVGParser.parse(bundle:bundle, path: name)
                        let svgContent = SVGSerializer.serialize(node: rootNode, indent: 1)
                        do {
                            try svgContent.write(toFile: dst, atomically: false, encoding:String.Encoding.utf8)
                        }
                        catch let error as NSError {
                            print("Write failed for:\(name) error:\(error)")
                        }
                        print (count, name, " PASSED")
                    } catch _ {
                        print (count, name, " FAILED")
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
}
