#if os(iOS)
  import UIKit
#endif

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
    
    public init(image: UIImage, xAlign: Align = .min, yAlign: Align = .min, aspectRatio: AspectRatio = .none, w: Int = 0, h: Int = 0, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {

        var oldId: String?
        for key in imagesMap.keys {
            if image === imagesMap[key] {
                oldId = key
            }
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
    
    override func bounds() -> Rect? {
        if w != 0 && h != 0 {
            return Rect(x: 0.0, y: 0.0, w: Double(w), h: Double(h))
        }
        
        uiImage = image()
        
        guard let uiImage = uiImage else {
            return .none
        }
        
        return Rect(x: 0.0, y: 0.0,
                    w: Double(uiImage.size.width),
                    h: Double(uiImage.size.height))
        
    }
    
    func image() -> UIImage? {
        
        // image already loaded
        if let _ = uiImage {
            return uiImage
        }
        
        // In-memory image
        if src.contains("memory") {
            let id = src.replacingOccurrences(of: "memory://", with: "")
            return imagesMap[id]
        }
        
        // Base64 image
        if src.hasPrefix("data:image/png;base64,") {
            src = src.replacingOccurrences(of: "data:image/png;base64,", with: "")
            guard let decodedData = Data(base64Encoded: src, options: .ignoreUnknownCharacters) else {
                return .none
            }
            
            return UIImage(data: decodedData)
        }
        
        // General case
        return UIImage(named: src)
    }
}
