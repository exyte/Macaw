import Foundation

#if os(iOS)
import UIKit
#endif

class RenderContext {
    weak var view: MView?
    weak var cgContext: CGContext?

    init(view: MView?) {
        self.view = view
        self.cgContext = nil
    }
}
