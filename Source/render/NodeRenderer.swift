import Foundation
import UIKit

protocol NodeRenderer {
	var ctx: RenderContext { get }
	var node: Node { get }

	func render(force: Bool)
}