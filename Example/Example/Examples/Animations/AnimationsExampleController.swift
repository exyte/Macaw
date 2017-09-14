import UIKit

class AnimationsExampleController: UIViewController {
    
	@IBOutlet weak var animView: AnimationsView?
    @IBOutlet weak var actionButton: UIButton?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        actionButton?.layer.cornerRadius = 5
        
        animView?.onComplete = {
            self.actionButton?.isEnabled = true
        }
        animView?.prepareAnimation()
        actionButton?.addTarget(self, action: #selector(startAnimationAction), for: .touchUpInside)
    }
    
    @objc func startAnimationAction() {
		animView?.startAnimation()
        actionButton?.isEnabled = false
	}
    
}
