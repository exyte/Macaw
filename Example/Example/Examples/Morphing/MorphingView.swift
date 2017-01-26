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
        let form1 = Rect(x: 0.0, y: 0.0, w: 300.0, h: 300.0)
        // let form2 = Rect(x: 50.0, y: 50.0, w: 200.0, h: 200.0)
        // let form2 = Circle(cx: 150.0, cy: 150.0, r: 50.0)
        let form2 = Circle(cx: 150.0, cy: 150.0, r: 150.0).arc(shift: 0, extent: 2.0 * M_PI)
        //let form1 = Line(x1: 100.0, y1: 100.0, x2: 200.0, y2: 200.0)
        //let form2 = Line(x1: 100.0, y1: 200.0, x2: 200.0, y2: 100.0)
        
        let shape = Shape(form: form1)
        shape.place = Transform.move(dx: 50.0, dy: 50.0)
        shape.formVar.animate(to: form2, during:5.0)
        
        return shape
    }
}
