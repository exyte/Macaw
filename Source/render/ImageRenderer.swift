import Foundation

#if os(OSX)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

class ImageRenderer: NodeRenderer {
    var image: Image

    var renderedPaths: [CGPath] = [CGPath]()

    override var node: Node {
        return image
    }

    init(image: Image, view: DrawingView?, parentRenderer: GroupRenderer? = nil) {
        self.image = image
        super.init(node: image, view: view, parentRenderer: parentRenderer)
    }

    deinit {
        dispose()
    }

    override func doAddObservers() {
        super.doAddObservers()

        observe(image.srcVar)
        observe(image.xAlignVar)
        observe(image.yAlignVar)
        observe(image.aspectRatioVar)
        observe(image.wVar)
        observe(image.hVar)
    }

    override func doRender(in context: CGContext, force: Bool, opacity: Double, coloringMode: ColoringMode = .rgb) {

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

        if let mImage = MImage(named: image.src),
           let rect = BoundsUtils.getRect(of: image, mImage: mImage) {

            if rect.contains(path.location) {
                return path
            }
        }
        return .none
    }
}
