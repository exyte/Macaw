//
//  CustomView.swift
//  Example
//
//  Created by Yuri Strot on 12/19/15.
//  Copyright © 2015 Exyte. All rights reserved.
//

import Foundation
import UIKit
import Macaw

class CustomView: MacawView {

    required init?(coder aDecoder: NSCoder) {
        let rect = Rect(x: 50, y: 50, w: 200, h: 100)
        let shape = Shape(form: rect, fill: Color.purple)
        super.init(node: shape, coder: aDecoder)
    }

    required init?(node: Node, coder aDecoder: NSCoder) {
        super.init(node: node, coder: aDecoder)
    }

}
