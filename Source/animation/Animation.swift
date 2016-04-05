import Foundation


public protocol Animatable {
    func animate(progress: Double)
    func getDuration() -> Double
}

public class Animation<T: Interpolable>: Animatable {
    
    let value: ObservableValue<T>
    
    let start:    T
    let final:    T
    let duration: Double
    
    public required init(observableValue: ObservableValue<T>, startValue: T, finalValue: T, animationDuration: Double) {
        value    = observableValue
        start    = startValue
        final    = finalValue
        duration = animationDuration
        
    }
    
    public convenience init(observableValue: ObservableValue<T>, finalValue: T, animationDuration: Double) {
        self.init(observableValue: observableValue, startValue: observableValue.get(), finalValue: finalValue, animationDuration: animationDuration )
    }
    
    public func animate(progress: Double) {
        
        value.set(start.interpolate(final, progress: progress))
    }
    
    public func getDuration() -> Double {
        return duration
    }
}
