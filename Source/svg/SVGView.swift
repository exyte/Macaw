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
        guard let svgNode = svgNode else { return }
        guard let nodeBounds = svgNode.bounds()?.cgRect() else { return }

        let viewBounds = bounds
        let svgWidth = nodeBounds.width
        let svgHeight = nodeBounds.height

        let transformHelper = TransformHelper()
        transformHelper.scalingMode = .noScaling
        transformHelper.xAligningMode = .mid
        transformHelper.yAligningMode = .mid

        switch self.contentMode {
        case .scaleToFill:
            transformHelper.scalingMode = .scaleToFill
        case .scaleAspectFill:
            transformHelper.scalingMode = .aspectFill
        case .scaleAspectFit:
            transformHelper.scalingMode = .aspectFit
        case .center:
            break
        case .top:
            transformHelper.yAligningMode = .min
        case .bottom:
            transformHelper.yAligningMode = .max
        case .left:
            transformHelper.xAligningMode = .min
        case .right:
            transformHelper.xAligningMode = .max
        case .topLeft:
            transformHelper.xAligningMode = .min
            transformHelper.yAligningMode = .min
        case .topRight:
            transformHelper.xAligningMode = .max
            transformHelper.yAligningMode = .min
        case .bottomLeft:
            transformHelper.xAligningMode = .min
            transformHelper.yAligningMode = .max
        case .bottomRight:
            transformHelper.xAligningMode = .max
            transformHelper.yAligningMode = .max
        case .redraw:
            break
        }

        svgNode.place = transformHelper.getTransformOf(Rect(x: 0, y: 0, w: Double(svgWidth), h: Double(svgHeight)), into: Rect(cgRect: viewBounds))

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
