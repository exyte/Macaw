import Foundation
import RxSwift

public class Group: Node {

	public var contents: ObservableArray<Node>

	public init(contents: [Node] = [], place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
		self.contents = ObservableArray<Node>(array: contents)
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

	// GENERATED NOT
	override internal func bounds() -> Rect? {

		guard let firstPos = contents.first?.place else {
			return .None
		}

		guard var union = contents.first?.bounds()?.applyTransform(firstPos) else {

			return .None
		}

		contents.forEach { node in
			guard let nodeBounds = node.bounds() else {
				return
			}

			union = union.union(rect: nodeBounds.applyTransform(node.place))
		}

		return union.applyTransform(self.place)
	}

}
