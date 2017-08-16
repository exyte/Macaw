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
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    animationsView?.onComplete = {
      self.actionButton?.isEnabled = true
    }
    animationsView?.prepareAnimation()
  }
  
  override func viewDidDisappear() {
    super.viewDidDisappear()
    
    self.actionButton?.isEnabled = true
  }
  
  @IBAction func startAnimationsAction(_ sender: Any) {
    animationsView?.startAnimation()
    actionButton?.isEnabled = false
  }
}
