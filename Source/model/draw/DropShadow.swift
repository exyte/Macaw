import Foundation

public enum EffectSource: String {
    case SourceGraphic, SourceAlpha, BackgroundImage, BackgroundAlpha, FillPaint, StrokePaint
}

open class DropShadow: Effect {

    open var radius: Double
    open var offset: Point
    open var color: Color
    open var input: Effect?
    open var source: EffectSource

    public init(radius: Double = 0, offset: Point = Point.origin, color: Color = Color.black, input: Effect? = nil, source: EffectSource = .SourceGraphic) {
        self.radius = radius
        self.offset = offset
        self.color = color
        self.input = input
        self.source = source
    }
}
