import Foundation

#if os(iOS)
  import UIKit
#elseif os(OSX)
  import AppKit
#endif

class TextRenderer: NodeRenderer {
  weak var text: Text?
  
  init(text: Text, ctx: RenderContext, animationCache: AnimationCache?) {
    self.text = text
    super.init(node: text, ctx: ctx, animationCache: animationCache)
  }
  
  override func node() -> Node? {
    return text
  }
  
  override func doAddObservers() {
    super.doAddObservers()
    
    guard let text = text else {
      return
    }
    
    observe(text.textVar)
    observe(text.fontVar)
    observe(text.fillVar)
    observe(text.alignVar)
    observe(text.baselineVar)
  }
  
  override func doRender(_ force: Bool, opacity: Double) {
    guard let text = text else {
      return
    }
    
    let message = text.text
    let font = getMFont()
    // positive NSBaselineOffsetAttributeName values don't work, couldn't find why
    // for now move the rect itself
    if var color = text.fill as? Color {
      color = RenderUtils.applyOpacity(color, opacity: opacity)
      MGraphicsPushContext(ctx.cgContext!)
        message.draw(in: getBounds(font), withAttributes: [NSAttributedStringKey.font: font,
                                                           NSAttributedStringKey.foregroundColor: getTextColor(color)])
      MGraphicsPopContext()
    }
  }
  
  override func doFindNodeAt(location: CGPoint, ctx: CGContext) -> Node? {
    guard let contains = node()?.bounds()?.cgRect().contains(location) else {
      return .none
    }
    
    if contains {
      return node()
    }
    
    return .none
  }
  
  fileprivate func getMFont() -> MFont {
    guard let text = text else {
      return MFont.systemFont(ofSize: 18.0)
    }
    
    if let textFont = text.font {
      if let customFont = RenderUtils.loadFont(name: textFont.name, size: textFont.size) {
        return customFont
      } else {
        return MFont.systemFont(ofSize: CGFloat(textFont.size))
      }
    }
    return MFont.systemFont(ofSize: MFont.mSystemFontSize)
  }
  
  fileprivate func getBounds(_ font: MFont) -> CGRect {
    guard let text = text else {
      return .zero
    }
    
    let textAttributes = [NSAttributedStringKey.font: font]
    let textSize = NSString(string: text.text).size(withAttributes: textAttributes)
    return CGRect(x: calculateAlignmentOffset(text, font: font),
                  y: calculateBaselineOffset(text, font: font),
                  width: CGFloat(textSize.width), height: CGFloat(textSize.height))
  }
  
  fileprivate func calculateBaselineOffset(_ text: Text, font: MFont) -> CGFloat {
    var baselineOffset = CGFloat(0)
    switch text.baseline {
    case Baseline.alphabetic:
      baselineOffset = font.ascender
    case Baseline.bottom:
      baselineOffset = font.ascender - font.descender
    case Baseline.mid:
      baselineOffset = (font.ascender - font.descender) / 2
    default:
      break
    }
    return -baselineOffset
  }
  
  fileprivate func calculateAlignmentOffset(_ text: Text, font: MFont) -> CGFloat {
    let textAttributes = [
        NSAttributedStringKey.font: font
    ]
    let textSize = NSString(string: text.text).size(withAttributes: textAttributes)
    var alignmentOffset = CGFloat(0)
    switch text.align {
    case Align.mid:
      alignmentOffset = textSize.width / 2
    case Align.max:
      alignmentOffset = textSize.width
    default:
      break
    }
    return -alignmentOffset
  }
  
  fileprivate func getTextColor(_ fill: Fill) -> MColor {
    if let color = fill as? Color {
      
      #if os(iOS)
        return MColor(cgColor: RenderUtils.mapColor(color))
      #elseif os(OSX)
        return MColor(cgColor: RenderUtils.mapColor(color)) ?? .black
      #endif
    
    }
    return MColor.black
  }
}
