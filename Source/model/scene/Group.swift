import Foundation
import RxSwift

public class Group: Node  {

	public var contentsVar: ObservableArray<Node>

	public init(contents: [Node] = [], pos: Transform = Transform(), opaque: NSObject = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: NSObject = true, tag: [String] = [], bounds: Rect? = nil) {
		self.contentsVar = ObservableArray<Node>(array: contents)
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

		guard let firstPos = contentsVar.first?.pos else {
			return .None
		}

		guard var union = contentsVar.first?.bounds()?.applyTransform(firstPos) else {

			return .None
		}

		contentsVar.forEach { node in
			guard let nodeBounds = node.bounds() else {
				return
			}

			union = union.union(nodeBounds.applyTransform(node.pos))
		}

		return union
	}
}