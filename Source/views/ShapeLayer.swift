import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

class ShapeLayer: CAShapeLayer {
    weak var renderer: NodeRenderer?
    var shouldRenderContent = true
    var isForceRenderingEnabled = true

    override func draw(in ctx: CGContext) {
        if !shouldRenderContent {
            super.draw(in: ctx)
            return
        }

        renderer?.directRender(in: ctx, force: isForceRenderingEnabled)
    }
}

extension ShapeLayer {

    func setupStrokeAndFill(_ shape: Shape) {

        // Stroke
        if let stroke = shape.stroke {
            if let color = stroke.fill as? Color {
                strokeColor = color.toCG()
            } else {
                strokeColor = MColor.black.cgColor
            }

            lineWidth = CGFloat(stroke.width)
            lineCap = MCAShapeLayerLineCap.mapToGraphics(model: stroke.cap)
            lineJoin = MCAShapeLayerLineJoin.mapToGraphics(model: stroke.join)
            lineDashPattern = stroke.dashes.map { NSNumber(value: $0) }
            lineDashPhase = CGFloat(stroke.offset)
        } else if shape.fill == nil {
            strokeColor = MColor.black.cgColor
            lineWidth = 1.0
        }

        // Fill
        if let color = shape.fill as? Color {
            fillColor = color.toCG()
        } else {
            fillColor = MColor.clear.cgColor
        }
    }

}
