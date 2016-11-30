import Foundation

open class Group: Node {

	open var contentsVar: AnimatableVariable<[Node]>
    open var contents: [Node] {
        get { return contentsVar.value }
        set(val) { contentsVar.value = val }
    }


	public init(contents: [Node] = [], place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
		self.contentsVar = AnimatableVariable<[Node]>(contents)
		super.init(
			place: place,
			opaque: opaque,
			opacity: opacity,
			clip: clip,
			effect: effect,
			visible: visible,
			tag: tag
		)
        
        self.contentsVar.node = self
	}

	// GENERATED NOT
	override internal func bounds() -> Rect? {

		guard let firstPos = contents.first?.place else {
			return .none
		}

		guard var union = contents.first?.bounds()?.applyTransform(firstPos) else {

			return .none
		}

		contents.forEach { node in
			guard let nodeBounds = node.bounds() else {
				return
			}

			union = union.union(rect: nodeBounds.applyTransform(node.place))
		}

		return union
	}

}

public extension Array where Element: Node {
    public func group( place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) -> Group {
        return Group(contents: self, place: place, opaque: opaque, opacity: opacity, clip: clip, effect: effect, visible: visible, tag: tag)
    }
}
