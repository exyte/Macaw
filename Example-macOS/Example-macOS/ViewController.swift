//
//  ViewController.swift
//  Example-macOS
//
//  Created by Daniil Manin on 8/11/17.
//
//

import Cocoa
import Macaw

class ViewController: NSViewController {

  @IBOutlet weak var svgView: SVGView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    
    svgView.updateLayer()
    
    svgView.contentMode = .scaleAspectFit
    svgView.fileName = "tiger"
  }
}

