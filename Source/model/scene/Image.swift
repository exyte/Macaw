import UIKit

open class Image: Node {

	open let srcVar: Variable<String>
	open var src: String {
		get { return srcVar.value }
		set(val) { srcVar.value = val }
	}

	open let xAlignVar: Variable<Align>
	open var xAlign: Align {
		get { return xAlignVar.value }
		set(val) { xAlignVar.value = val }
	}

	open let yAlignVar: Variable<Align>
	open var yAlign: Align {
		get { return yAlignVar.value }
		set(val) { yAlignVar.value = val }
	}

	open let aspectRatioVar: Variable<AspectRatio>
	open var aspectRatio: AspectRatio {
		get { return aspectRatioVar.value }
		set(val) { aspectRatioVar.value = val }
	}

	open let wVar: Variable<Int>
	open var w: Int {
		get { return wVar.value }
		set(val) { wVar.value = val }
	}

	open let hVar: Variable<Int>
	open var h: Int {
		get { return hVar.value }
		set(val) { hVar.value = val }
	}
    
    private var uiImage: UIImage?

	public init(src: String, xAlign: Align = .min, yAlign: Align = .min, aspectRatio: AspectRatio = .none, w: Int = 0, h: Int = 0, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
		self.srcVar = Variable<String>(src)
		self.xAlignVar = Variable<Align>(xAlign)
		self.yAlignVar = Variable<Align>(yAlign)
		self.aspectRatioVar = Variable<AspectRatio>(aspectRatio)
		self.wVar = Variable<Int>(w)
		self.hVar = Variable<Int>(h)
		super.init(
			place: place,
			opaque: opaque,
			opacity: opacity,
			clip: clip,
			effect: effect,
			visible: visible,
			tag: tag
		)
	}
    
    override func bounds() -> Rect? {
        if w != 0 && h != 0 {
            return Rect(x: 0.0, y: 0.0, w: Double(w), h: Double(h))
        }
        
        if uiImage == nil {
            uiImage = UIImage(named: src)
        }
        
        guard let uiImage = uiImage else {
            return .none
        }
        
        return Rect(x: 0.0, y: 0.0,
                    w: Double(uiImage.size.width),
                    h: Double(uiImage.size.width))
        
    }

}
