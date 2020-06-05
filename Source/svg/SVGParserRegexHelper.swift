import Foundation

class SVGParserRegexHelper {

    fileprivate static let textElementPattern = "<text.*?>((?s:.*))<\\/text>"
    fileprivate static var textElementMatcher: NSRegularExpression?

    class func getTextElementMatcher() -> NSRegularExpression? {
        if self.textElementMatcher == nil {
            do {
                self.textElementMatcher = try NSRegularExpression(pattern: textElementPattern, options: .caseInsensitive)
            } catch {

            }
        }
        return self.textElementMatcher
    }
}
