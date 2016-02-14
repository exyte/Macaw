public class ObservableValue<T> {
    
    public typealias Listener = (oldValue: T, newValue: T) -> ()
    private var listeners: [Listener] = []
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
    
    public func addListener(handler: Listener) {
        listeners.append(handler)
    }
    
    func valueChanged(oldValue: T, newValue: T) {
        for handler in listeners {
            handler(oldValue: oldValue, newValue: newValue)
        }
    }
}