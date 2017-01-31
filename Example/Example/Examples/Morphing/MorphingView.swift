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
                
        let group1 = [
            Shape(form: Line(x1: 90.0, y1: 110.0, x2: 210.0, y2: 110.0), stroke: Stroke(width: 6.0, cap: .round)),
            Shape(form: Line(x1: 90.0, y1: 150.0, x2: 210.0, y2: 150.0), stroke: Stroke(width: 6.0, cap: .round)),
            Shape(form: Line(x1: 90.0, y1: 190.0, x2: 210.0, y2: 190.0), stroke: Stroke(width: 6.0, cap: .round))
        ].group()
        
        let group2 = [
            Shape(form: Line(x1: 90.0, y1: 90.0, x2: 210.0, y2: 210.0), stroke: Stroke(width: 6.0, cap: .round)),
            Shape(form: Circle(cx: 150.0, cy: 150.0, r: 100.0), stroke: Stroke(width: 6.0, cap: .round)),
            Shape(form: Line(x1: 90.0, y1: 210.0, x2: 210.0, y2: 90.0), stroke: Stroke(width: 6.0, cap: .round))
            ].group()
        
        group1.contentsVar.animate(to: group2, during: 2.0, delay: 2.0)
        
        return group1
        
    }
}
