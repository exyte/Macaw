import Foundation
import RxSwift

public class Group: Node  {

	public var contents: ObservableArray<Node>

	public init(contents: [Node] = [], pos: Transform = Transform(), opaque: NSObject = true, visible: NSObject = true, clip: Locus? = nil, tag: [String] = []) {
		self.contents = ObservableArray<Node>(array: contents)	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
