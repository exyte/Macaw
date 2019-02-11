//
//  AnimationsViewController.swift
//  Example-macOS
//
//  Created by Daniil Manin on 8/15/17.
//
//

import Cocoa

class AnimationsViewController: NSViewController {
  
  @IBOutlet weak var animationsView: AnimationsView!
  @IBOutlet weak var actionButton: NSButton!
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    animationsView?.onComplete = {
      self.actionButton?.isEnabled = true
    }
    animationsView?.prepareAnimation()
    
    let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.blue.withAlphaComponent(0.5)]
    actionButton.attributedTitle = NSMutableAttributedString(string: actionButton.title, attributes: attributes)
  }
  
  override func viewDidDisappear() {
    super.viewDidDisappear()
    self.actionButton?.isHidden = false
  }
  
  @IBAction func startAnimationsAction(_ sender: Any) {
    actionButton?.isHidden = true
    animationsView?.startAnimation()
  }
}
