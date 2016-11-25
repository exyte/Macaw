import UIKit

let animationProducer = AnimationProducer()

class AnimationProducer {

    
	var storedAnimations = [Node: BasicAnimation]()
    var displayLink: CADisplayLink?
    
    struct ContentAnimationDesc {
        let animation: ContentsAnimation
        let layer: CALayer
        let cache: AnimationCache
        let startDate: Date
        let finishDate: Date
        let completion: (()->())?
    }
    
    var contentsAnimations = [ContentAnimationDesc]()

	func addAnimation(_ animation: BasicAnimation, withoutDelay: Bool = false) {

		if animation.delay > 0.0 && !withoutDelay {

			let _ = Timer.schedule(delay: animation.delay, handler: { _ in
				self.addAnimation(animation, withoutDelay: true)
			})

			return
		}

		if animation.type == .empty {
			executeCompletion(animation)
			return
		}

		guard let node = animation.node else {
			return
		}

		guard let macawView = nodesMap.getView(node) else {
			storedAnimations[node] = animation
			return
		}

		guard let cache = macawView.animationCache else {
			return
		}

		switch animation.type {
		case .unknown:
			return
		case .affineTransformation:
			addTransformAnimation(animation, sceneLayer: macawView.layer, animationCache: cache, completion: {
				if let next = animation.next {
					self.addAnimation(next)
				}
			})

		case .opacity:
			addOpacityAnimation(animation, sceneLayer: macawView.layer, animationCache: cache, completion: {
				if let next = animation.next {
					self.addAnimation(next)
				}
			})
		case .sequence:
			addAnimationSequence(animation)
		case .combine:
			addCombineAnimation(animation)
        case .contents:
            addContentsAnimation(animation, cache: cache, completion: {
                if let next = animation.next {
                    self.addAnimation(next)
                }
            })
		case .empty:
			executeCompletion(animation)
		}
	}
    
    // MARK: - Sequence animation
	fileprivate func addAnimationSequence(_ animationSequnce: Animation) {
		guard let sequence = animationSequnce as? AnimationSequence else {
			return
		}
		// reversing
		if sequence.autoreverses {
			sequence.animations.forEach { animation in
				animation.autoreverses = !animation.autoreverses
			}
		}

		// Generating sequence
		var sequenceAnimations = [BasicAnimation]()
		if sequence.repeatCount > 0.0001 {
			for _ in 0..<Int(sequence.repeatCount) {
				sequenceAnimations.append(contentsOf: sequence.animations)
			}
		} else {
			sequenceAnimations.append(contentsOf: sequence.animations)
		}

		if sequence.autoreverses {
			sequenceAnimations = sequenceAnimations.reversed()
		}

		// Connecting animations
		for i in 0..<(sequenceAnimations.count - 1) {
			let animation = sequenceAnimations[i]
			animation.next = sequenceAnimations[i + 1]
		}

		// Completion
		if let completion = sequence.completion {
			let completionAnimation = EmptyAnimation(completion: completion)

			if let next = sequence.next {
				completionAnimation.next = next
			}

			sequenceAnimations.last?.next = completionAnimation
		} else {
			if let next = sequence.next {
				sequenceAnimations.last?.next = next
			}
		}

		// Launching
		if let firstAnimation = sequence.animations.first {
			self.addAnimation(firstAnimation)
		}
	}

    // MARK: - Combine animation
	fileprivate func addCombineAnimation(_ combineAnimation: Animation) {
		guard let combine = combineAnimation as? CombineAnimation else {
			return
		}

		// Reversing
		if combine.autoreverses {
			combine.animations.forEach { animation in
				animation.autoreverses = !animation.autoreverses
			}
		}

		// repeat count
		if combine.repeatCount > 0.00001 {
			var sequence = [Animation]()

			for _ in 0..<Int(combine.repeatCount) {
				sequence.append(combine)
			}

			combine.repeatCount = 0.0
			addAnimationSequence(sequence.sequence())
			return
		}

		// Looking for longest animation
		var longestAnimation: BasicAnimation?
		combine.animations.forEach { animation in
			guard let longest = longestAnimation else {
				longestAnimation = animation
				return
			}

			if longest.getDuration() < animation.getDuration() {
				longestAnimation = animation
			}
		}

		// Attaching completion empty animation and potential next animation
		if let completion = combine.completion {
			let completionAnimation = EmptyAnimation(completion: completion)
			if let next = combine.next {
				completionAnimation.next = next
			}

			longestAnimation?.next = completionAnimation

		} else {
			if let next = combine.next {
				longestAnimation?.next = next
			}

		}

		combine.removeFunc = {
			combine.animations.forEach { animation in
				animation.removeFunc?()
			}
		}

		// Launching
		combine.animations.forEach { animation in
			self.addAnimation(animation)
		}
	}

    // MARK: - Empty Animation
	fileprivate func executeCompletion(_ emptyAnimation: BasicAnimation) {
		emptyAnimation.completion?()
	}
    
    // MARK: - Stored animation
	func addStoredAnimations(_ node: Node) {
		if let animation = storedAnimations[node] {
			addAnimation(animation)
			storedAnimations.removeValue(forKey: node)
		}

		guard let group = node as? Group else {
			return
		}

		group.contents.forEach { child in
			addStoredAnimations(child)
		}
	}
    
    // MARK: - Contents animation
    
    func addContentsAnimation(_ animation: BasicAnimation, cache: AnimationCache, completion: @escaping (() -> ())) {
        guard let contentsAnimation = animation as? ContentsAnimation else {
            return
        }
        
        guard let node = contentsAnimation.node else {
            return
        }
        
        if animation.autoreverses {
            animation.autoreverses = false
            addAnimation([animation, animation.reverse()].sequence() as! BasicAnimation)
            return
        }
        
        if animation.repeatCount > 0.0001 {
            animation.repeatCount = 0.0
            var animSequence = [Animation]()
            for i in 0...Int(animation.repeatCount) {
                animSequence.append(animation)
            }
            
            addAnimation(animSequence.sequence() as! BasicAnimation)
            return
        }
        
        let startDate = Date(timeInterval: contentsAnimation.delay, since: Date())
        
        var unionBounds: Rect? = .none
        if let startBounds = contentsAnimation.getVFunc()(0.0).group().bounds(),
           let endBounds = contentsAnimation.getVFunc()(1.0).group().bounds() {
            unionBounds = startBounds.union(rect: endBounds)
        }
        
        let animationDesc = ContentAnimationDesc(
            animation: contentsAnimation,
            layer: cache.layerForNode(node, animation: contentsAnimation, customBounds: unionBounds),
            cache: cache,
            startDate: Date(),
            finishDate: Date(timeInterval: contentsAnimation.duration, since: startDate),
            completion: completion
        )
        
        contentsAnimations.append(animationDesc)
        
        if displayLink == .none {
            displayLink = CADisplayLink(target: self, selector: #selector(updateContentAnimations))
            displayLink?.frameInterval = 1
            displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        }
    }
    
    @objc func updateContentAnimations() {
        if contentsAnimations.count == 0 {
            displayLink?.invalidate()
            displayLink = .none
        }
        
        let currentDate = Date()
        for (index, animationDesc) in contentsAnimations.enumerated() {
            
            let animation = animationDesc.animation
            guard let group = animation.node as? Group else {
                continue
            }
            
            let progress = currentDate.timeIntervalSince(animationDesc.startDate) / animation.duration
            if progress >= 1.0 {
                animation.completion?()
                contentsAnimations.remove(at: index)
                animationDesc.cache.freeLayer(group)
                
                animationDesc.completion?()
                continue
            }
            
           let t = progressForTimingFunction(animation.easing, progress: progress)
           group.contents = animation.getVFunc()(t)
            animationDesc.layer.setNeedsDisplay()
            animationDesc.layer.displayIfNeeded()
            animation.onProgressUpdate?(progress)
        }
    }
}
