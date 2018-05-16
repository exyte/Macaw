open class Group: Node {

    open var contentsVar: AnimatableVariable<[Node]>
    open var contents: [Node] {
        get { return contentsVar.value }
        set(val) {
            contentsVar.value = val

            if let view = nodesMap.getView(self) {
                val.forEach { subNode in
                    nodesMap.add(subNode, view: view)
                }
            }

            val.forEach { subNode in
                nodesMap.add(subNode, parent: self)
            }
        }
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

    // Searching

    override public func nodeBy(tag: String) -> Node? {
        if let node = super.nodeBy(tag: tag) {
            return node
        }

        for child in contents {
            if let node = child.nodeBy(tag: tag) {
                return node
            }
        }

        return .none
    }

    override public func nodesBy(tag: String) -> [Node] {
        var result = [Node]()
        contents.forEach { child in
            result.append(contentsOf: child.nodesBy(tag: tag))
        }

        if let node = super.nodeBy(tag: tag) {
            result.append(node)
        }

        return result
    }

    override internal func bounds() -> Rect? {
        var union: Rect?

        contents.forEach { node in
            guard let nodeBounds = node.bounds()?.applying(node.place) else {
                return
            }

            union = union?.union(rect: nodeBounds) ?? nodeBounds
        }

        return union
    }

    override func shouldCheckForPressed() -> Bool {
        var shouldCheck = super.shouldCheckForPressed()
        contents.forEach { node in
            shouldCheck = shouldCheck || node.shouldCheckForPressed()
        }

        return shouldCheck
    }

    override func shouldCheckForMoved() -> Bool {
        var shouldCheck = super.shouldCheckForMoved()
        contents.forEach { node in
            shouldCheck = shouldCheck || node.shouldCheckForMoved()
        }

        return shouldCheck
    }

    override func shouldCheckForReleased() -> Bool {
        var shouldCheck = super.shouldCheckForReleased()
        contents.forEach { node in
            shouldCheck = shouldCheck || node.shouldCheckForReleased()
        }

        return shouldCheck
    }

    override func shouldCheckForTap() -> Bool {
        var shouldCheck = super.shouldCheckForTap()
        contents.forEach { node in
            shouldCheck = shouldCheck || node.shouldCheckForTap()
        }

        return shouldCheck
    }

    override func shouldCheckForLongTap() -> Bool {
        var shouldCheck = super.shouldCheckForLongTap()
        contents.forEach { node in
            shouldCheck = shouldCheck || node.shouldCheckForLongTap()
        }

        return shouldCheck
    }

    override func shouldCheckForPan() -> Bool {
        var shouldCheck = super.shouldCheckForPan()
        contents.forEach { node in
            shouldCheck = shouldCheck || node.shouldCheckForPan()
        }

        return shouldCheck
    }

    override func shouldCheckForPinch() -> Bool {
        var shouldCheck = super.shouldCheckForPinch()
        contents.forEach { node in
            shouldCheck = shouldCheck || node.shouldCheckForPinch()
        }

        return shouldCheck
    }

    override func shouldCheckForRotate() -> Bool {
        var shouldCheck = super.shouldCheckForRotate()
        contents.forEach { node in
            shouldCheck = shouldCheck || node.shouldCheckForRotate()
        }

        return shouldCheck
    }
}

public extension Array where Element: Node {
    public func group( place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) -> Group {
        return Group(contents: self, place: place, opaque: opaque, opacity: opacity, clip: clip, effect: effect, visible: visible, tag: tag)
    }
}
