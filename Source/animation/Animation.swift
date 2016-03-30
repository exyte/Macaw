import Foundation

public protocol Animation {
    func animate(progress: Double)
    func getDuration() -> Double
}

public class LinearAnimation<T: InterpolatingType>: Animation {
    
    var property: ObservableValue<T>?
    
    var start:    T?
    var final:    T?
    var duration: Double = 0
    
    public init(observableProperty: ObservableValue<T>?, startValue: T, finalValue: T, animationDuration: Double) {
        property = observableProperty
        start    = startValue
        final    = finalValue
        duration = animationDuration
        
    }
    
    public func animate(progress: Double) {
        
        guard let start = start else {
            return
        }
        
        guard let final = final else {
            return
        }
        
        property?.set(start.interpolate(final, progress: progress))
    }
    
    public func getDuration() -> Double {
        return duration
    }
}
