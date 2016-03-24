import Foundation

public class Disposable {
    private let disposeAction: () -> ()
    
    init(disposeAction: () -> ()) {
        self.disposeAction = disposeAction
    }
    
    public func dispose() {
        disposeAction()
    }
}
