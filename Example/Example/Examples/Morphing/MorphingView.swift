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
        let rectangle = Rect(x: 50.0, y: 50.0, w: 100.0, h: 100.0)
        let circle = Circle(cx: 100.0, cy: 100.0, r: 50.0)
        
        let shape = Shape(form: rectangle)
        shape.formVar.animate(to: circle, during:5.0)
        
        return shape
    }
}
