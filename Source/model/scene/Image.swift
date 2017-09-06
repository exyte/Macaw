import Foundation

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

  /**
     Whether the underlying image source is external and will require
     to be explicitly set through the setImage(_) method.
  */
  open var isSourceExternal: Bool {
    get { return src.hasPrefix("http://") || src.hasPrefix("https://") }
  }
  
  private var mImage: MImage?
  
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
  
  public init(image: MImage, xAlign: Align = .min, yAlign: Align = .min, aspectRatio: AspectRatio = .none, w: Int = 0, h: Int = 0, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
    
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
    
    mImage = image()
    
    guard let mImage = mImage else {
      return .none
    }
    
    return Rect(x: 0.0, y: 0.0,
                w: Double(mImage.size.width),
                h: Double(mImage.size.height))
    
  }

  public func setImage(_ image: MImage?) {
    mImage = image
    // Notify consumers that we now have an image for our source.    
    srcVar.value = src
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
    if src.hasPrefix("data:image/png;base64,") {
      src = src.replacingOccurrences(of: "data:image/png;base64,", with: "")
      guard let decodedData = Data(base64Encoded: src, options: .ignoreUnknownCharacters) else {
        return .none
      }
      
      return MImage(data: decodedData)
    }

    if isSourceExternal {
        return nil
    }
    
    // General case
    return MImage(named: src)
  }
}
