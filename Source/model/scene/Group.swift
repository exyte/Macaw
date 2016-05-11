import Foundation
import RxSwift

public class Group: Node  {

	public let contentsVar: Variable<[Node]>
	public var contents: [Node] {
		get { return contentsVar.value }
		set(val) { contentsVar.value = val }
	}

	public init(contents: [Node] = [], pos: Transform = Transform(), opaque: NSObject = true, visible: NSObject = true, clip: Locus? = nil, tag: [String] = []) {
		self.contentsVar = Variable<[Node]>(contents)	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
