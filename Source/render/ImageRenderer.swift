import Foundation

#if os(OSX)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

class ImageRenderer: NodeRenderer {
    weak var image: Image?

    var renderedPaths: [CGPath] = [CGPath]()

    init(image: Image, view: MacawView?, animationCache: AnimationCache?) {
        self.image = image
        super.init(node: image, view: view, animationCache: animationCache)
    }

    deinit {
        dispose()
    }

    override func node() -> Node? {
        return image
    }

    override func doAddObservers() {
        super.doAddObservers()

        guard let image = image else {
            return
        }

        observe(image.srcVar)
        observe(image.xAlignVar)
        observe(image.yAlignVar)
        observe(image.aspectRatioVar)
        observe(image.wVar)
        observe(image.hVar)
    }

    override func doRender(in context: CGContext, force: Bool, opacity: Double, coloringMode: ColoringMode = .rgb) {
        guard let image = image else {
            return
        }

        var mImage: MImage?
        if image.src.contains("memory") {
            let id = image.src.replacingOccurrences(of: "memory://", with: "")
            mImage = imagesMap[id]
        } else {
            mImage = image.image()
        }

        if let mImage = mImage,
            let rect = BoundsUtils.getRect(of: image, mImage: mImage) {
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: 0.0, y: -1.0 * rect.height)
            context.setAlpha(CGFloat(opacity))
            context.draw(mImage.cgImage!, in: rect)
        }
    }

    override func doFindNodeAt(path: NodePath, ctx: CGContext) -> NodePath? {
        guard let image = image else {
            return .none
        }

        if let mImage = MImage(named: image.src),
            let rect = BoundsUtils.getRect(of: image, mImage: mImage) {

            if rect.contains(path.location) {
                return path
            }
        }
        return .none
    }

    override func replaceNode(with replacementNode: Node) {
        super.replaceNode(with: replacementNode)

        if let node = replacementNode as? Image {
            image = node
        }
    }
}
