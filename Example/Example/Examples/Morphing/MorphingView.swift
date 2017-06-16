//
//  MorphingView.swift
//  Example
//
//  Created by Victor Sukochev on 25/01/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Macaw

class MorphingView: MacawView {

    required init?(coder aDecoder: NSCoder) {
        super.init(node: MorphingView.newScene(), coder: aDecoder)
    }

    class func newScene() -> Node {
        let rect = Rect(x: 0.0, y: 0.0, w: 100.0, h: 100.0)
        let node = Shape(form: rect, fill: Color.green)
        node.place = .move(dx: 150.0, dy: 150.0)
        //let rotationTransform = Transform.move(dx: 150.0, dy: 150.0).rotate(angle: .pi * 3.0 / 4.0)
        node.placeVar.animate(centerAngle: .pi, during: 10.0)
        
        
        return node
        
	}
}
