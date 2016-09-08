import Foundation
import UIKit

class ImageRenderer: NodeRenderer {
	let image: Image

	var renderedPaths: [CGPath] = [CGPath]()

	init(image: Image, ctx: RenderContext) {
		self.image = image
		super.init(node: image, ctx: ctx)
	}

	override func node() -> Node {
		return image
	}

	override func addObservers() {
		super.addObservers()
		observe(image.srcVar)
		observe(image.xAlignVar)
		observe(image.yAlignVar)
		observe(image.aspectRatioVar)
		observe(image.wVar)
		observe(image.hVar)
	}

	override func render(force: Bool, opacity: Double) {
		if let uiimage = UIImage(named: image.src) {
			let imageSize = uiimage.size
			var w = CGFloat(image.w)
			var h = CGFloat(image.h)
			var rect: CGRect
			if ((w == 0 || w == imageSize.width) && (h == 0 || h == imageSize.height)) {
				rect = CGRectMake(0, 0, imageSize.width, imageSize.height)
			} else {
				if (w == 0) {
					w = imageSize.width * h / imageSize.height
				} else if (h == 0) {
					h = imageSize.height * w / imageSize.width
				}
				switch (image.aspectRatio) {
				case AspectRatio.meet:
					rect = calculateMeetAspectRatio(image, size: imageSize)
				case AspectRatio.slice:
					rect = calculateSliceAspectRatio(image, size: imageSize)
					CGContextClipToRect(ctx.cgContext, CGRectMake(0, 0, w, h))
				default:
					rect = CGRectMake(0, 0, w, h)
				}
			}

			CGContextScaleCTM(ctx.cgContext, 1.0, -1.0)
			CGContextTranslateCTM(ctx.cgContext, 0.0, -1.0 * rect.height)

			CGContextSetAlpha(ctx.cgContext, CGFloat(opacity))
			CGContextDrawImage(ctx.cgContext, rect, uiimage.CGImage)
		}
	}

	override func detectTouches(location: CGPoint) -> [Shape] {
		return []
	}

	private func calculateMeetAspectRatio(image: Image, size: CGSize) -> CGRect {
		let w = CGFloat(image.w)
		let h = CGFloat(image.h)
		// destination and source aspect ratios
		let destAR = w / h
		let srcAR = size.width / size.height
		var resultW = w
		var resultH = h
		var destX = CGFloat(0)
		var destY = CGFloat(0)
		if (destAR < srcAR) {
			// fill all available width and scale height
			resultH = size.height * w / size.width
		} else {
			// fill all available height and scale width
			resultW = size.width * h / size.height
		}
		let xalign = image.xAlign
		switch (xalign) {
		case Align.min:
			destX = 0
		case Align.mid:
			destX = w / 2 - resultW / 2
		case Align.max:
			destX = w - resultW
		}
		let yalign = image.yAlign
		switch (yalign) {
		case Align.min:
			destY = 0
		case Align.mid:
			destY = h / 2 - resultH / 2
		case Align.max:
			destY = h - resultH
		}
		return CGRectMake(destX, destY, resultW, resultH)
	}

	private func calculateSliceAspectRatio(image: Image, size: CGSize) -> CGRect {
		let w = CGFloat(image.w)
		let h = CGFloat(image.h)
		var srcX = CGFloat(0)
		var srcY = CGFloat(0)
		var totalH: CGFloat = 0
		var totalW: CGFloat = 0
		// destination and source aspect ratios
		let destAR = w / h
		let srcAR = size.width / size.height
		if (destAR > srcAR) {
			// fill all available width and scale height
			totalH = size.height * w / size.width
			totalW = w
			switch (image.yAlign) {
			case Align.min:
				srcY = 0
			case Align.mid:
				srcY = -(totalH / 2 - h / 2)
			case Align.max:
				srcY = -(totalH - h)
			}
		} else {
			// fill all available height and scale width
			totalW = size.width * h / size.height
			totalH = h
			switch (image.xAlign) {
			case Align.min:
				srcX = 0
			case Align.mid:
				srcX = -(totalW / 2 - w / 2)
			case Align.max:
				srcX = -(totalW - w)
			}
		}
		return CGRectMake(srcX, srcY, totalW, totalH)
	}
}