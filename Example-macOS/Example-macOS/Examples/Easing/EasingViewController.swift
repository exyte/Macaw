//
//  EasingViewController.swift
//  Example-macOS
//
//  Created by Daniil Manin on 8/15/17.
//
//

import Cocoa

class EasingViewController: NSViewController {
  @IBOutlet weak var easingView: EasingView!
  
  override func viewDidAppear() {
    super.viewDidAppear()
    easingView.animation.play()
  }
  
  override func viewWillDisappear() {
    super.viewDidDisappear()
    easingView.animation.stop()
  }
}
