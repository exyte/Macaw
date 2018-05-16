import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

open class SVGView: MacawView {

    fileprivate let rootNode = Group()
    fileprivate var svgNode: Node?

    @IBInspectable open var fileName: String? {
        didSet {
            parseSVG()
            render()
        }
    }

    public init(node: Node = Group(), frame: CGRect) {
        super.init(frame: frame)
        svgNode = node
    }

    override public init?(node: Node = Group(), coder aDecoder: NSCoder) {
        super.init(node: Group(), coder: aDecoder)
        svgNode = node
    }

    required public convenience init?(coder aDecoder: NSCoder) {
        self.init(node: Group(), coder: aDecoder)
    }

    open override var contentMode: MViewContentMode {
        didSet {
            render()
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        render()
    }

    fileprivate func parseSVG() {
        svgNode = try? SVGParser.parse(path: fileName ?? "")
    }

    fileprivate func render() {
        guard let svgNode = svgNode else {
            return
        }
        guard let nodeBounds = svgNode.bounds() else {
            return
        }

        var scalingMode = AspectRatio.meet
        var xAligningMode = Align.mid
        var yAligningMode = Align.mid

        switch contentMode {
        case .scaleToFill:
            scalingMode = .none
        case .scaleAspectFill:
            scalingMode = .slice
        case .scaleAspectFit:
            scalingMode = .meet
        case .center:
            break
        case .top:
            yAligningMode = .min
        case .bottom:
            yAligningMode = .max
        case .left:
            xAligningMode = .min
        case .right:
            xAligningMode = .max
        case .topLeft:
            xAligningMode = .min
            yAligningMode = .min
        case .topRight:
            xAligningMode = .max
            yAligningMode = .min
        case .bottomLeft:
            xAligningMode = .min
            yAligningMode = .max
        case .bottomRight:
            xAligningMode = .max
            yAligningMode = .max
        case .redraw:
            break
        }

        let contentLayout = SVGContentLayout(scalingMode: scalingMode, xAligningMode: xAligningMode, yAligningMode: yAligningMode)
        svgNode.place = contentLayout.layout(rect: nodeBounds, into: bounds.toMacaw())

        rootNode.contents = [svgNode]
        node = rootNode
    }

    fileprivate func getMidX(_ viewBounds: CGRect, _ nodeBounds: CGRect) -> CGFloat {
        let viewMidX = viewBounds.midX
        let nodeMidX = nodeBounds.midX + nodeBounds.origin.x
        return viewMidX - nodeMidX
    }

    fileprivate func getMidY(_ viewBounds: CGRect, _ nodeBounds: CGRect) -> CGFloat {
        let viewMidY = viewBounds.midY
        let nodeMidY = nodeBounds.midY + nodeBounds.origin.y
        return viewMidY - nodeMidY
    }

    fileprivate func getBottom(_ viewBounds: CGRect, _ nodeBounds: CGRect) -> CGFloat {
        return viewBounds.maxY - nodeBounds.maxY + nodeBounds.origin.y
    }

    fileprivate func getRight(_ viewBounds: CGRect, _ nodeBounds: CGRect) -> CGFloat {
        return viewBounds.maxX - nodeBounds.maxX + nodeBounds.origin.x
    }

}
