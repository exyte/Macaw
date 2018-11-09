import Foundation

#if os(iOS)
import UIKit
#endif

class RenderContext {
    weak var view: MacawView?
    var cgContext: CGContext?

    init(view: MacawView?) {
        self.view = view
        self.cgContext = nil
    }
}
