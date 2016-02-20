//
//  ModelListenersViewController.swift
//  Example
//
//  Created by Igor Zapletnev on 20/02/16.
//  Copyright © 2016 Exyte. All rights reserved.
//

import Foundation
import UIKit

class ModelListenersViewController: UIViewController {
    @IBOutlet weak var macawView: FifthPageCustomView!

    @IBOutlet weak var heightStepper: UIStepper!
    @IBOutlet weak var widthSteppter: UIStepper!
    @IBOutlet weak var radiusStepper: UIStepper!

    @IBAction func onHeightChange(sender: AnyObject) {
        updateRect()
    }
    
    func updateRect() {
        print(macawView.roundedRect)
    }
}
