import Foundation


public class Animatable {
    func animate(progress: Double) {}
    func getDuration() -> Double{ return 0}
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
    
    public override func animate(progress: Double) {
        
        value.set(start.interpolate(final, progress: progress))
    }
    
    public override func getDuration() -> Double {
        return duration
    }
}
