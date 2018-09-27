class MorphingAnimation: AnimationImpl<Locus> {

    convenience init(animatedNode: Shape, startValue: Locus, finalValue: Locus, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {

        let interpolationFunc = { (t: Double) -> Locus in
            finalValue
        }

        self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, delay: delay, autostart: autostart, fps: fps)
    }

    init(animatedNode: Shape, valueFunc: @escaping (Double) -> Locus, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: animatedNode.formVar, valueFunc: valueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .morphing
        nodeId = animatedNode.id

        if autostart {
            self.play()
        }
    }

    init(animatedNode: Shape, factory: @escaping (() -> ((Double) -> Locus)), animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: animatedNode.formVar, factory: factory, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .morphing
        nodeId = animatedNode.id

        if autostart {
            self.play()
        }
    }

    // Pause state not available for discreet animation
    override public func pause() {
        stop()
    }
}

public typealias MorphingAnimationDescription = AnimationDescription<Locus>

public extension AnimatableVariable where T: LocusInterpolation {
    public func animate(_ desc: MorphingAnimationDescription) {
        _ = MorphingAnimation(animatedNode: node as! Shape, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: true)
    }

    public func animation(_ desc: MorphingAnimationDescription) -> Animation {
        return MorphingAnimation(animatedNode: node as! Shape, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: false)
    }

    public func animate(from: Locus? = nil, to: Locus, during: Double = 1.0, delay: Double = 0.0) {
        self.animate(((from ?? (node as! Shape).form) >> to).t(during, delay: delay))
    }

    public func animation(from: Locus? = nil, to: Locus, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        if let safeFrom = from {
            return self.animation((safeFrom >> to).t(during, delay: delay))
        }

        let origin = (node as! Shape).form
        let factory = { () -> (Double) -> Locus in { (t: Double) in
            if t == 0.0 {
                return origin
            }

            return to }
        }

        return MorphingAnimation(animatedNode: self.node as! Shape, factory: factory, animationDuration: during, delay: delay)
    }

    public func animation(_ f: @escaping (Double) -> Locus, during: Double, delay: Double = 0.0) -> Animation {
        return MorphingAnimation(animatedNode: node as! Shape, valueFunc: f, animationDuration: during, delay: delay)
    }

}

// MARK: - Group

public extension AnimatableVariable where T: ContentsInterpolation {
    public func animation(from: Group? = nil, to: [Node], during: Double = 1.0, delay: Double = 0.0) -> Animation {
        var fromNode = node as! Group
        if let passedFromNode = from {
            fromNode = passedFromNode
        }

        // Shapes on same hierarhy level
        let fromShapes = fromNode.contents.compactMap { $0 as? Shape }
        let toShapes = to.compactMap { $0 as? Shape }
        let minPathsNumber = min(fromShapes.count, toShapes.count)

        var animations = [Animation]()
        for i in 0..<minPathsNumber {
            let fromShape = fromShapes[i]
            let toShape = toShapes[i]

            let animation = ShapeAnimation(animatedNode: fromShape, finalValue: toShape, animationDuration: during, delay: delay)
            animations.append(animation)
        }

        if fromShapes.count > minPathsNumber {
            for i in minPathsNumber..<fromShapes.count {
                let shapeToHide = fromShapes[i]
                let animation = shapeToHide.opacityVar.animation(to: 0.0, during: during, delay: delay)
                animations.append(animation)
            }
        }

        if toShapes.count > minPathsNumber {
            for i in minPathsNumber..<toShapes.count {
                let shapeToShow = toShapes[i]
                shapeToShow.opacity = 0.0
                fromNode.contents.append(shapeToShow)

                let animation = shapeToShow.opacityVar.animation(to: 1.0, during: during, delay: delay)
                animations.append(animation)
            }
        }

        // Groups on same hierahy level
        let fromGroups = fromNode.contents.compactMap { $0 as? Group }
        let toGroups = to.compactMap { $0 as? Group }
        let minGroupsNumber = min(fromGroups.count, toGroups.count)
        for i in 0..<minGroupsNumber {
            let fromGroup = fromGroups[i]
            let toGroup = toGroups[i]
            let groupAnimation = fromGroup.contentsVar.animation(to: toGroup.contents, during: during, delay: delay)
            animations.append(groupAnimation)
        }

        for i in minGroupsNumber..<fromGroups.count {
            let groupToHide = fromGroups[i]
            let animation = groupToHide.opacityVar.animation(to: 0.0, during: during, delay: delay)
            animations.append(animation)
        }

        for i in minGroupsNumber..<toGroups.count {
            let groupToShow = toGroups[i]
            groupToShow.opacity = 0.0
            fromNode.contents.append(groupToShow)

            let animation = groupToShow.opacityVar.animation(to: 1.0, during: during, delay: delay)
            animations.append(animation)
        }

        // Rest nodes
        let fromNodes = fromNode.contents.filter {
            !($0 is Group || $0 is Shape)
        }

        let toNodes = to.filter {
            !($0 is Group || $0 is Shape)
        }

        fromNodes.forEach { node in
            let animation = node.opacityVar.animation(to: 0.0, during: during, delay: delay)
            animations.append(animation)
        }

        toNodes.forEach { node in
            node.opacity = 0.0
            fromNode.contents.append(node)

            let animation = node.opacityVar.animation(to: 1.0, during: during, delay: delay)
            animations.append(animation)
        }

        return animations.combine(node: fromNode)
    }

    public func animate(from: Group? = nil, to: [Node], during: Double = 1.0, delay: Double = 0.0) {
        animation(from: from, to: to, during: during, delay: delay).play()
    }
}
