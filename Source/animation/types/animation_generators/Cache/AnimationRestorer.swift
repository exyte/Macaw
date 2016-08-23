import Foundation

let animationRestorer = AnimationRestorer()
class AnimationRestorer {
	typealias RestoreClosure = () -> ()
	var restoreClosures = [RestoreClosure]()

	init() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(restore), name: UIApplicationDidBecomeActiveNotification,
			object: .None)
	}

	func addRestoreClosure(closure: RestoreClosure) {
		restoreClosures.append(closure)
	}

	@objc func restore() {
		dispatch_async(dispatch_get_main_queue()) {
			self.restoreClosures.forEach { restoreClosure in
				restoreClosure()
			}
		}
	}
}