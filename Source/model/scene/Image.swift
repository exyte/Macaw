#if os(OSX)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

open class Image: Node {

    public let srcVar: Variable<String>
    open var src: String {
        get { return srcVar.value }
        set(val) { srcVar.value = val }
    }

    public let xAlignVar: Variable<Align>
    open var xAlign: Align {
        get { return xAlignVar.value }
        set(val) { xAlignVar.value = val }
    }

    public let yAlignVar: Variable<Align>
    open var yAlign: Align {
        get { return yAlignVar.value }
        set(val) { yAlignVar.value = val }
    }

    public let aspectRatioVar: Variable<AspectRatio>
    open var aspectRatio: AspectRatio {
        get { return aspectRatioVar.value }
        set(val) { aspectRatioVar.value = val }
    }

    public let wVar: Variable<Int>
    open var w: Int {
        get { return wVar.value }
        set(val) { wVar.value = val }
    }

    public let hVar: Variable<Int>
    open var h: Int {
        get { return hVar.value }
        set(val) { hVar.value = val }
    }

    private var mImage: MImage?

    public init(src: String, xAlign: Align = .min, yAlign: Align = .min, aspectRatio: AspectRatio = .none, w: Int = 0, h: Int = 0, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, mask: Node? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
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
            mask: mask,
            effect: effect,
            visible: visible,
            tag: tag
        )
    }

    public init(image: MImage, xAlign: Align = .min, yAlign: Align = .min, aspectRatio: AspectRatio = .none, w: Int = 0, h: Int = 0, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {

        var oldId: String?
        for key in imagesMap.keys where image === imagesMap[key] {
            oldId = key
        }

        let id = oldId ?? UUID().uuidString
        imagesMap[id] = image

        self.srcVar = Variable<String>("memory://\(id)")
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

    override open var bounds: Rect? {

        mImage = image()

        guard let mImage = mImage else {
            return .none
        }

        guard let rect = BoundsUtils.getRect(of: self, mImage: mImage) else {
            return .none
        }

        return rect.toMacaw()
    }

    internal enum ImageRepresentationType {
        case JPEG
        case PNG
    }

    internal func base64encoded(type: ImageRepresentationType) -> String? {
        if let image = self.image() {
            switch type {
            case .JPEG:
                if let data = MImageJPEGRepresentation(image) {
                    return data.base64EncodedString()
                }
            case .PNG:
                if let data = MImagePNGRepresentation(image) {
                    return data.base64EncodedString()
                }
            }
        }
        return .none
    }

    func image() -> MImage? {

        // image already loaded
        if let _ = mImage {
            return mImage
        }

        // In-memory image
        if src.contains("memory") {
            let id = src.replacingOccurrences(of: "memory://", with: "")
            return imagesMap[id]
        }

        // Base64 image
        let decodableFormat = ["image/png", "image/jpg"]
        for format in decodableFormat {
            let prefix = "data:\(format);base64,"
            if src.hasPrefix(prefix) {
                let src = String(self.src.suffix(from: prefix.endIndex))
                guard let decodedData = Data(base64Encoded: src, options: .ignoreUnknownCharacters) else {
                    return .none
                }

                return MImage(data: decodedData)
            }
        }

        // General case
        #if os(iOS)
        return MImage(named: src)
        #elseif os(OSX)
        return MImage(named: src)
        #endif
    }
}
