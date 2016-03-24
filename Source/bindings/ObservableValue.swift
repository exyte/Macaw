public class ObservableValue<T> {
    
    private var listeners: [ObservableValueListener<T>] = []
    private var value: T
    
    init(value: T) {
        self.value = value
    }
    
    func get() -> T {
        return value
    }
    
    func set(newValue: T) {
        let oldValue = value
        value = newValue
        valueChanged(oldValue, newValue: value)
    }
    
    public func addListener(listener: (oldValue: T, newValue: T) -> ()) -> Disposable {
        let observableListener = ObservableValueListener<T>(onChange: listener)
        listeners.append(observableListener)
        return Disposable {
            let index = self.listeners.indexOf { $0 === observableListener }
            if let indexVal = index {
                self.listeners.removeAtIndex(indexVal)
            }
        }
    }
    
    func valueChanged(oldValue: T, newValue: T) {
        for listener in listeners {
            listener.onChange(oldValue: oldValue, newValue: newValue)
        }
    }
}

class ObservableValueListener<T> {
    let onChange: (oldValue: T, newValue: T) -> ()
    
    init(onChange: (oldValue: T, newValue: T) -> ()) {
        self.onChange = onChange
    }
}