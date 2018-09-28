//
//  ExampleViewController.swift
//  Example-macOS
//
//  Created by Daniil Manin on 9/28/18.
//

import Cocoa

class ExampleViewController: NSViewController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .white
    }
}
