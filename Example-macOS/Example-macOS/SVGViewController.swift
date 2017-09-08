//
//  SVGViewController.swift
//  Example-macOS
//
//  Created by Simon Corsin on 9/8/17.
//
//

import Foundation
import AppKit
import Macaw

class SVGViewController: NSViewController {

    @IBOutlet weak var svgView: SVGView!

    override func viewDidLoad() {
        super.viewDidLoad()

        svgView.contentMode = .scaleAspectFit
    }

    @IBAction func openSVGDidClick(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["svg"]
        openPanel.allowsMultipleSelection = false
        openPanel.begin { (result) in
            if result == NSModalResponseOK {
                guard let url = openPanel.url else { return }
                self.loadSVG(at: url)
            }
        }
    }

    private func loadSVG(at url: URL) {
        svgView.url = url
    }

}
