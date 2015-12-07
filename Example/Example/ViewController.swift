//
//  ViewController.swift
//  Example
//
//  Created by Igor Zapletnev on 12/8/15.
//  Copyright © 2015 Exyte. All rights reserved.
//

import UIKit
import Macaw

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let helloWorld = HelloWorld()
        helloWorld.say()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

