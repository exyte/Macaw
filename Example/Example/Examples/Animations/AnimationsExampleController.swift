import UIKit

class AnimationsExampleController: UIViewController {
    
	@IBOutlet weak var animView: AnimationsView?
    @IBOutlet weak var actionButton: UIButton?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        actionButton?.layer.cornerRadius = 5
        setActionButtonState(startAction: true)
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		animView?.prepareAnimation()
	}

	func startAnimationAction() {
		animView?.prepareAnimation()
		animView?.startAnimation()
        setActionButtonState(startAction: false)
	}

	func stopAnimationAction() {
		animView?.stopAnimation()
        setActionButtonState(startAction: true)
	}
    
    fileprivate func setActionButtonState(startAction: Bool) {
        actionButton?.setTitle(startAction ? "Start" : "Stop", for: .normal)
        actionButton?.addTarget(
            self,
            action: startAction ? #selector(startAnimationAction) : #selector(stopAnimationAction),
            for: .touchUpInside
        )
    }
    
}
