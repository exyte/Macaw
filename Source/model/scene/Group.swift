import Foundation
import RxSwift

public class Group: Node {

	public var contents: ObservableArray<Node>

	public init(contents: [Node] = [], pos: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = [], bounds: Rect? = nil) {
		self.contents = ObservableArray<Node>(array: contents)
		super.init(
			pos: pos,
			opaque: opaque,
			opacity: opacity,
			clip: clip,
			effect: effect,
			visible: visible,
			tag: tag,
			bounds: bounds
		)
	}

	// GENERATED NOT
	override public func bounds() -> Rect? {

		guard let firstPos = contents.first?.pos else {
			return .None
		}

		guard var union = contents.first?.bounds()?.applyTransform(firstPos) else {

			return .None
		}

		contents.forEach { node in
			guard let nodeBounds = node.bounds() else {
				return
			}

			union = union.union(nodeBounds.applyTransform(node.pos))
		}

		return union
	}

}
