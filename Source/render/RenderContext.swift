import Foundation

#if os(iOS)
import UIKit
#endif

public class RenderContext {
    public weak var view: MView?
    public weak var cgContext: CGContext?

    public init(view: MView? = nil) {
        self.view = view
        self.cgContext = nil
    }
}
