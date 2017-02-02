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
        
        
        /*
        let form1 = Rect(x: 50.0, y: 50.0, w: 200.0, h: 200.0)
        let form2 = Circle(cx: 150.0, cy: 150.0, r: 100.0)
        
        let shape = Shape(form: form1)
        let animation = shape.formVar.animation(to: form2, during:1.5, delay: 2.0)
        animation.autoreversed().play()//.cycle().play()
        
        return shape
 */
        
        /*
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
        
        group1.contentsVar.animate(to: group2)
        
        return group1
 */
 
        
   
        let stroke = Stroke(width: 15.0, cap: .round)
        
        let group1 = [
            Shape(form: Line(x1: 90.0, y1: 110.0, x2: 210.0, y2: 110.0), stroke: stroke),
            [Shape(form: Line(x1: 90.0, y1: 150.0, x2: 210.0, y2: 150.0), stroke: stroke),
            Shape(form: Line(x1: 90.0, y1: 190.0, x2: 210.0, y2: 190.0), stroke: stroke)].group(),
            ].group()
        
        let group2 = [
            [Shape(form: Line(x1: 110.0, y1: 150.0, x2: 135.0, y2: 125.0), stroke: stroke),
            Shape(form: Line(x1: 110.0, y1: 150.0, x2: 190.0, y2: 150.0), stroke: stroke)].group(),
            Shape(form: Line( x1: 110.0, y1: 150.0, x2: 135.0, y2: 175.0), stroke: stroke),
            ].group()
        
        let presentedGroup = [
            Shape(form: Line(x1: 90.0, y1: 110.0, x2: 210.0, y2: 110.0), stroke: stroke),
            Shape(form: Line(x1: 90.0, y1: 150.0, x2: 210.0, y2: 150.0), stroke: stroke),
            Shape(form: Line(x1: 90.0, y1: 190.0, x2: 210.0, y2: 190.0), stroke: stroke),
            ].group()
        
        [
            presentedGroup.contentsVar.animation(to: group2, during: 10.0, delay: 5.0),
            //presentedGroup.contentsVar.animation(to: group1, during: 0.5, delay: 2.0),
        ].sequence().play()
        
        return presentedGroup
 
 
 
        
    }
}
