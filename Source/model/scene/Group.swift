import Foundation
import RxSwift

public class Group: Node {

	public var contentsVar: Variable<[Node]>

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

	override public func bounds() -> Rect? {
		guard let firstPos = contentsVar.value.first?.pos else {
			return .None
		}

		guard var union = contentsVar.value.first?.bounds()?.applyTransform(firstPos) else {
			return .None
		}

		contentsVar.value.forEach { node in
			guard let nodeBounds = node.bounds() else {
				return
			}

			union = union.union(nodeBounds.applyTransform(node.pos))
		}

		return union // .applyTransform(pos)
	}
}
