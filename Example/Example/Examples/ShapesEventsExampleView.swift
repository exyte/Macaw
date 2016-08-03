//
//  CustomView.swift
//  Example
//
//  Created by Yuri Strot on 12/19/15.
//  Copyright © 2015 Exyte. All rights reserved.
//

import UIKit
import Macaw
import RxSwift

class ShapesEventsExampleView: MacawView {
    
    required init?(coder aDecoder: NSCoder) {
        
        let rect = Rect(x: 50, y: 50, w: 50, h: 100)
        let shape1 = Shape(
            form: rect,
            fill: Color.blue
        )
        
        let colors = [Color.red, Color.aqua, Color.black, Color.blue, Color.fuchsia, Color.silver, Color.teal]
        
        _ = shape1.onTap.subscribeNext { tap in
            let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
            shape1.fill = colors[randomIndex]
        }
        
        _ = shape1.onPan.subscribeNext { pan in
            let node = shape1 as Node
            let newPos = node.pos.move(Double(pan.dx), my: Double(pan.dy))
            node.pos = newPos
        }
        
        _ = shape1.onRotate.subscribeNext { rotate in
            let node = shape1 as Node
            var newPos = node.pos.move(75, my: 105)
            newPos = newPos.rotate(Double(rotate.radians))
            newPos = newPos.move(-75, my: -105)
            node.pos = newPos
        }
        
        _ = shape1.onPinch.subscribeNext { pinch in
            let node = shape1 as Node
            let scale = Double(pinch.scale)
            let newPos = node.pos.scale(scale, sy: scale)
            node.pos = newPos
        }
        
                let group = Group(
            contents: [
                shape1
            ]
        )
        
        super.init(node: group, coder: aDecoder)
    }
    
    required init?(node: Node?, coder aDecoder: NSCoder) {
        super.init(node: node, coder: aDecoder)
    }
}
