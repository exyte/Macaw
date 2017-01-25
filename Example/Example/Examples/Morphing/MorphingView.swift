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
        let form1 = Rect(x: 100.0, y: 100.0, w: 100.0, h: 100.0)
        //let form1 = Circle(cx: 150.0, cy: 150.0, r: 50.0)
        let form2 = Circle(cx: 150.0, cy: 150.0, r: 25.0)
        //let form1 = Line(x1: 100.0, y1: 100.0, x2: 200.0, y2: 200.0)
        //let form2 = Line(x1: 100.0, y1: 200.0, x2: 200.0, y2: 100.0)
        
        let shape = Shape(form: form1)
        shape.formVar.animate(to: form2, during:5.0)
        
        return shape
    }
}
