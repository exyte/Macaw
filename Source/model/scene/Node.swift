import Foundation

public class Node: Drawable  {

	public let posProperty: ObservableValue<Transform>
	public var pos: Transform {
		get { return posProperty.get() }
		set(val) { posProperty.set(val) }
	}

	public let opaqueProperty: ObservableValue<NSObject>
	public var opaque: NSObject {
		get { return opaqueProperty.get() }
		set(val) { opaqueProperty.set(val) }
	}

	public let visibleProperty: ObservableValue<NSObject>
	public var visible: NSObject {
		get { return visibleProperty.get() }
		set(val) { visibleProperty.set(val) }
	}

	public let clipProperty: ObservableValue<Locus?>
	public var clip: Locus? {
		get { return clipProperty.get() }
		set(val) { clipProperty.set(val) }
	}
    
    public var animating = false

	public init(pos: Transform, opaque: NSObject = true, visible: NSObject = true, clip: Locus? = nil, tag: [String] = []) {
		self.posProperty = ObservableValue<Transform>(value: pos)	
		self.opaqueProperty = ObservableValue<NSObject>(value: opaque)	
		self.visibleProperty = ObservableValue<NSObject>(value: visible)	
		self.clipProperty = ObservableValue<Locus?>(value: clip)	
		super.init(
			tag: tag
		)
        
//        self.posProperty.addListener { (oldValue, newValue) in
//            self.pos = newValue
//        }
	}

	// GENERATED NOT
	public func mouse() -> Mouse {
		return Mouse(pos: Point(), onEnter: Signal(), onExit: Signal(), onWheel: Signal())
	}
	// GENERATED NOT
	public func bounds() -> Rect? {
		return Rect()
	}

}
