import Foundation
import UIKit

protocol NodeRenderer {
    var ctx: CGContext { get }
    func render()
}