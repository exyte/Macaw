import Foundation

open class Stop {

    open let offset: Double
    open let color: Color

    public init(offset: Double = 0, color: Color) {
        self.color = color
        
        if offset < 0 {
            self.offset = 0
        } else if offset > 1 {
            self.offset = 1
        } else {
            self.offset = offset
        }
    }
}
