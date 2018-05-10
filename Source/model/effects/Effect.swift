import Foundation

enum EffectSource: String {
    case SourceGraphic, SourceAlpha, BackgroundImage, BackgroundAlpha, FillPaint, StrokePaint
}

open class Filter {
    var source: EffectSource = .SourceGraphic
    var effects = [Effect]()
}

open class Effect {
    public init() {
    }
}
