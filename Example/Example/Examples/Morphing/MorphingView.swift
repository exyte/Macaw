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
        
        var offset = 0.0
        
        weak var someNode: Node?
        while true {
            //DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now(), execute: {
            
            let someNode = try? SVGParser.parse(path: "tiger")
            
                //weak var someNode = SVGParser(

            //})
            
            offset += 1
            if offset >= 20.0 {
                break
            }
        }
    }

    class func newScene() -> Node {
   
        /*
        let stroke = Stroke(width: 15.0, cap: .round)
		
		let contents1 = [
			Shape(form: Line(x1: 150.0, y1: 150.0, x2: 175.0, y2: 125.0), stroke: stroke),
			Shape(form: Line(x1: 150.0, y1: 150.0, x2: 225.0, y2: 150.0), stroke: stroke),
			Shape(form: Line(x1: 150.0, y1: 150.0, x2: 175.0, y2: 175.0), stroke: stroke),
		]

        let contents2 = [
			Shape(form: Line(x1: 130.0, y1: 110.0, x2: 245.0, y2: 110.0), stroke: stroke),
			Shape(form: Line(x1: 130.0, y1: 150.0, x2: 245.0, y2: 150.0), stroke: stroke),
			Shape(form: Line(x1: 130.0, y1: 190.0, x2: 245.0, y2: 190.0), stroke: stroke),
		]
		
		var switched = false
		let group = contents1.group()
		group.onTap { e in
			group.contentsVar.animate(to: switched ? contents1 : contents2)
			switched = !switched
		}
		return group
 */
 
        /*
        let forms = try! SVGParser.parse(path: "examples") as! Group
        let elephant = forms.nodeFor(tag: "elephant")!
        let hippo = forms.nodeFor(tag: "hippo")!
        let circle = forms.nodeFor(tag: "circle")!
        let star  = forms.nodeFor(tag: "star")!
        
        let contentGroup = [elephant].group()
        contentGroup.contentsVar.animation(to: [hippo], during: 3.0).autoreversed().cycle().play()
        
        return contentGroup
 */
        let form1 = Rect(x: 50.0, y: 50.0, w: 200.0, h: 200.0)
        let form2 = Circle(cx: 150.0, cy: 150.0, r: 100.0)
        
        let shape = Shape(form: form1, stroke: Stroke(width: 3.0))
        let animation = shape.formVar.animation(to: form2, during:1.5, delay: 2.0)
        animation.autoreversed().cycle().play()
        
        return shape
 
	}
}
