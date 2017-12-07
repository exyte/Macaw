import Foundation

let animationRestorer = AnimationRestorer()

open class AnimationRestorer {

    typealias RestoreClosure = () -> Void

    var restoreClosures = [RestoreClosure]()

    func addRestoreClosure(_ closure: @escaping RestoreClosure) {
        restoreClosures.append(closure)
    }

    open class func restore() {
        DispatchQueue.main.async {
            animationRestorer.restoreClosures.forEach { restoreClosure in
                restoreClosure()
            }

            animationRestorer.restoreClosures.removeAll()
        }
    }
}
