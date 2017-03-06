//
//  SVGExampleController.swift
//  Example
//
//  Created by Khoren Markosyan on 3/6/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import UIKit
import Macaw

let EditableColorId = "EditableColorShape"

class SVGExampleController: UIViewController {

    @IBOutlet weak var svgView: SVGView!

    var fillColor = Color.red

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        replaceColors(node: svgView.node)
    }

    private func replaceColors(node: Node) {
        if let group = node as? Group {
            group.contents.forEach { node in
                if let shape = node as? Shape {
                    if (group.id == EditableColorId) {
                        shape.fill = fillColor
                    }
                } else {
                    replaceColors(node: node)
                }
            }
        }
    }

}
