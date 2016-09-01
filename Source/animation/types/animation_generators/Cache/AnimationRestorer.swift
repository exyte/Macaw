import Foundation

let animationRestorer = AnimationRestorer()
public class AnimationRestorer {
	typealias RestoreClosure = () -> ()
	var restoreClosures = [RestoreClosure]()

	func addRestoreClosure(closure: RestoreClosure) {
		restoreClosures.append(closure)
	}

	public class func restore() {
		dispatch_async(dispatch_get_main_queue()) {
			animationRestorer.restoreClosures.forEach { restoreClosure in
				restoreClosure()
			}

			animationRestorer.restoreClosures.removeAll()
		}
	}
}