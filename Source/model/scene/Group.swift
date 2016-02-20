import Foundation

public class Group: Node  {

	public let contentsProperty: ObservableValue<[Node]>
	public var contents: [Node] {
		get { return contentsProperty.get() }
		set(val) { contentsProperty.set(val) }
	}

	public init(contents: [Node] = [], pos: Transform = Transform(), opaque: NSObject = true, visible: NSObject = true, clip: Locus? = nil, tag: [String] = []) {
		self.contentsProperty = ObservableValue<[Node]>(value: contents)	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
