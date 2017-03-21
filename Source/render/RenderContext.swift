import Foundation
import UIKit

class RenderContext {
	weak var view: UIView?
	var cgContext: CGContext?

	init(view: UIView?) {
		self.view = view
		self.cgContext = nil
	}
}
