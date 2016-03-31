import Foundation

public protocol CommonAnimation {
    func animate(progress: Double)
    func getDuration() -> Double
}

public class Animation<T: InterpolatingType>: CommonAnimation {
    
    var property: ObservableValue<T>?
    
    var start:    T?
    var final:    T?
    var duration: Double = 0
    
    public required init(observableProperty: ObservableValue<T>?, startValue: T?, finalValue: T?, animationDuration: Double) {
        property = observableProperty
        start    = startValue
        final    = finalValue
        duration = animationDuration
        
    }
    
    public convenience init(observableProperty: ObservableValue<T>?, finalValue: T, animationDuration: Double) {
        self.init(observableProperty: observableProperty, startValue: observableProperty?.get(), finalValue: finalValue, animationDuration: animationDuration )
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
