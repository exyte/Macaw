//
//  CustomView.swift
//  Example
//
//  Created by Yuri Strot on 12/19/15.
//  Copyright © 2015 Exyte. All rights reserved.
//

import UIKit
import Macaw

class ShapesEventsExampleView: MacawView {
    
    required init?(coder aDecoder: NSCoder) {
        
        let rect = Rect(x: 50, y: 50, w: 50, h: 100)
        let shape1 = Shape(
            form: rect,
            fill: Color.blue
        )
        
        let colors = [Color.red, Color.aqua, Color.black, Color.blue, Color.fuchsia, Color.silver, Color.teal]
        
        shape1.onTap { _ in
            let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
            shape1.fill = colors[randomIndex]
        }
        
        
        let group = Group(
            contents: [
                shape1
            ]
        )
        
        super.init(node: group, coder: aDecoder)
        
        shape1.onPan { pan in
            let node = shape1 as Node
            let newPos = node.place.move(dx: Double(pan.dx), dy: Double(pan.dy))
            node.place = newPos
        }
        
        shape1.onRotate { rotate in
            let node = shape1 as Node
            var newPos = node.place.move(dx: 75, dy: 105)
            newPos = newPos.rotate(angle: rotate.angle)
            newPos = newPos.move(dx: -75, dy: -105)
            node.place = newPos
        }
        
        shape1.onPinch { pinch in
            let node = shape1 as Node
            let scale = Double(pinch.scale)
            let newPos = node.place.scale(sx: scale, sy: scale)
            node.place = newPos
        }

    }
}
