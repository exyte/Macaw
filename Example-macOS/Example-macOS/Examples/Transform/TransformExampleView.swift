//
//  TransformExampleView.swift
//  Example
//
//  Created by Yuri Strot on 9/10/16.
//  Copyright © 2016 Exyte. All rights reserved.
//

import Foundation
import Macaw

class TransformExampleView: MacawView {
  
  fileprivate static let transforms = [Transform.scale(sx: 2, sy: 2),
                                       Transform.move(dx: 100, dy: 30),
                                       Transform.rotate(angle: Double.pi / 4.0, x: 150, y: 80),
                                       Transform.rotate(angle: Double.pi / 4.0)]
  
  fileprivate static let titles = ["Transform.scale(sx: 2, sy: 2)",
                                   "Transform.move(dx: 100, dy: 30)",
                                   "Transform.rotate(angle: M_PI_4, x: 150, y: 80)",
                                   "Transform.rotate(angle: M_PI_4)"]
  
  required init?(coder aDecoder: NSCoder) {
    super.init(node: TransformExampleView.newScene(), coder: aDecoder)
  }
  
  fileprivate static func newScene() -> Node {
    let shape = Shape(form: Rect(x: 0, y: 0, w: 50, h: 50), fill: Color.blue)
    let textes = Group(place: .move(dx: 50, dy: 275))
    for (i, item) in titles.enumerated() {
      let place = Transform.move(dx: 0, dy: Double(i * 25))
      textes.contents.append(Text(text: item, baseline: .bottom, place: place, opacity: 0))
    }
    var combines: [Transform] = [Transform.identity]
    for transform in transforms {
      combines.append(GeomUtils.concat(t1: transform, t2: combines.last!))
    }
    var state = 0
    
    shape.onTap { _ in
      if (state < textes.contents.count) {
        textes.contents[state].opacityVar.animate(from: 0.0, to: 1.0, during: 0.6)
      } else {
        for item in textes.contents {
          item.opacityVar.animate(from: 1.0, to: 0.0, during: 0.6)
        }
      }
      state = (state + 1) % 5;
      shape.placeVar.animate(to: combines[state], during: 0.6)
    }
    
    let group = Group(contents: [newAxes(), shape, textes], place: .move(dx: 10, dy: 10))
    return group
  }
  
  fileprivate static func newAxes() -> Node {
    var items: [Node] = []
    
    for i in 1...20 {
      let shift = Double(i) * 50.0
      items.append(Line(x1: -50, y1: shift, x2: 1000, y2: shift).stroke(fill: Color.gray))
      items.append(Line(x1: shift, y1: -50, x2: shift, y2: 1000).stroke(fill: Color.gray))
    }
    
    items.append(Line(x1: -10, y1: 0, x2: 1000, y2: 0).stroke())
    items.append(Line(x1: 0, y1: -10, x2: 0, y2: 1000).stroke())
    return Group(contents: items)
  }
}
