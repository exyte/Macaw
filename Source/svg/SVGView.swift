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
    get { return innerFileName }
    set {
      innerFileName = newValue
      innerUrl = nil
      reload()
    }
  }

  open var url: URL? {
    get { return innerUrl }
    set {
      innerUrl = newValue
      innerFileName = nil
      reload()
    }
  }

  private var innerUrl: URL?
  private var innerFileName: String?
  
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

  private func reload() {
    parseSVG()
    render()
  }
  
  fileprivate func parseSVG() {
    do {
        if let fileName = fileName {
            svgNode = try SVGParser.parse(path: fileName)
        } else if let url = url {
            let text = try String(contentsOf: url)
            svgNode = try SVGParser.parse(text: text)
        } else {
            svgNode = nil
        }
    } catch let error {
        Swift.print("Failed to load SVG: \(error)")
    }
  }
  
  fileprivate func render() {
    guard let svgNode = self.svgNode else {
      return
    }
    let viewBounds = self.bounds
    if let nodeBounds = svgNode.bounds()?.cgRect() {
      let svgWidth = nodeBounds.origin.x + nodeBounds.width
      let svgHeight = nodeBounds.origin.y + nodeBounds.height
      
      let viewAspectRatio = viewBounds.width / viewBounds.height
      let svgAspectRatio = svgWidth / svgHeight
      
      let scaleX = viewBounds.width / svgWidth
      let scaleY = viewBounds.height / svgHeight
      
      switch self.contentMode {
      case .scaleToFill:
        svgNode.place = Transform.scale(
          sx: Double(scaleX),
          sy: Double(scaleY)
        )
      case .scaleAspectFill:
        let scaleX, scaleY: CGFloat
        if viewAspectRatio > svgAspectRatio {
          scaleX = viewBounds.width / svgWidth
          scaleY = viewBounds.width / (svgWidth / svgAspectRatio)
        } else {
          scaleX = viewBounds.height / (svgHeight / svgAspectRatio)
          scaleY = viewBounds.height / svgHeight
        }
        let calculatedWidth = svgWidth * scaleX
        let calculatedHeight = svgHeight * scaleY
        svgNode.place = Transform.move(
          dx: (viewBounds.width / 2 - calculatedWidth / 2).doubleValue,
          dy: (viewBounds.height / 2 - calculatedHeight / 2).doubleValue
          ).scale(
            sx: scaleX.doubleValue,
            sy: scaleX.doubleValue
        )
      case .scaleAspectFit:
        let calculatedXWidth = scaleX * svgWidth
        let calculatedXHeight = scaleX * svgHeight
        let calculatedYWidth = scaleY * svgWidth
        let calculatedYHeight = scaleY * svgHeight
        
        if calculatedXWidth <= viewBounds.width && calculatedXHeight <= viewBounds.height {
          svgNode.place = Transform.move(
            dx: (viewBounds.midX - calculatedXWidth / 2).doubleValue,
            dy: (viewBounds.midY - calculatedXHeight / 2).doubleValue
            ).scale(
              sx: scaleX.doubleValue,
              sy: scaleX.doubleValue
          )
        } else if calculatedYWidth <= viewBounds.width && calculatedYHeight <= viewBounds.height {
          svgNode.place = Transform.move(
            dx: (viewBounds.midX - calculatedYWidth / 2).doubleValue,
            dy: (viewBounds.midY - calculatedYHeight / 2).doubleValue
            ).scale(
              sx: scaleY.doubleValue,
              sy: scaleY.doubleValue
          )
        }
      case .center:
        svgNode.place = Transform.move(
          dx: getMidX(viewBounds, nodeBounds).doubleValue,
          dy: getMidY(viewBounds, nodeBounds).doubleValue
        )
      case .top:
        svgNode.place = Transform.move(
          dx: getMidX(viewBounds, nodeBounds).doubleValue,
          dy: 0
        )
      case .bottom:
        svgNode.place = Transform.move(
          dx: getMidX(viewBounds, nodeBounds).doubleValue,
          dy: getBottom(viewBounds, nodeBounds).doubleValue
        )
      case .left:
        svgNode.place = Transform.move(
          dx: 0,
          dy: getMidY(viewBounds, nodeBounds).doubleValue
        )
      case .right:
        svgNode.place = Transform.move(
          dx: getRight(viewBounds, nodeBounds).doubleValue,
          dy: getMidY(viewBounds, nodeBounds).doubleValue
        )
      case .topLeft:
        break
      case .topRight:
        svgNode.place = Transform.move(
          dx: getRight(viewBounds, nodeBounds).doubleValue,
          dy: 0
        )
      case .bottomLeft:
        svgNode.place = Transform.move(
          dx: 0,
          dy: getBottom(viewBounds, nodeBounds).doubleValue
        )
      case .bottomRight:
        svgNode.place = Transform.move(
          dx: getRight(viewBounds, nodeBounds).doubleValue,
          dy: getBottom(viewBounds, nodeBounds).doubleValue
        )
      case .redraw:
        break
      }
    }
    
    rootNode.contents = [svgNode]
    self.node = rootNode
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
