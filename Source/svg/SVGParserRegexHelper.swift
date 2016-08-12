class SVGParserRegexHelper {
    
    private static let transformAttributePattern = "([a-z]+)\\(((\\-?\\d+\\.?\\d*\\s*,?\\s*)+)\\)"
    private static let transformPattern = "\\-?\\d+\\.?\\d*"
    private static let textElementPattern = "<text.*?>((?s:.*))<\\/text>"
    
    private static var transformMatcher: NSRegularExpression?
    private static var transformAttributeMatcher: NSRegularExpression?
    private static var textElementMatcher: NSRegularExpression?
    
    class func getTransformAttributeMatcher() -> NSRegularExpression? {
        if self.transformAttributeMatcher == nil {
            do {
                self.transformAttributeMatcher = try NSRegularExpression(pattern: transformAttributePattern, options: .CaseInsensitive)
            } catch {
                
            }
        }
        return self.transformAttributeMatcher
    }
    
    class func getTransformMatcher() -> NSRegularExpression? {
        if self.transformMatcher == nil {
            do {
                self.transformMatcher = try NSRegularExpression(pattern: transformPattern, options: .CaseInsensitive)
            } catch {
                
            }
        }
        return self.transformMatcher
    }
    
    class func getTextElementMatcher() -> NSRegularExpression? {
        if self.textElementMatcher == nil {
            do {
                self.textElementMatcher = try NSRegularExpression(pattern: textElementPattern, options: .CaseInsensitive)
            } catch {
                
            }
        }
        return self.textElementMatcher
    }
    
}