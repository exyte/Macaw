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
        let stroke = Stroke(width: 15.0, cap: .round)
		
		let contents1 = [
			Shape(form: Line(x1: 150.0, y1: 150.0, x2: 175.0, y2: 125.0), stroke: stroke),
			Shape(form: Line(x1: 150.0, y1: 150.0, x2: 225.0, y2: 150.0), stroke: stroke),
			Shape(form: Line( x1: 150.0, y1: 150.0, x2: 175.0, y2: 175.0), stroke: stroke),
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
	}
}
