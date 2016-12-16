import UIKit

class EasingExampleController: UIViewController {
    
    @IBOutlet weak var easingView: EasingView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        easingView.animation.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        easingView.animation.stop()
    }    
}
