import Foundation
import UIKit

protocol NodeRenderer {
    var ctx: RenderContext { get }
    func render()
}