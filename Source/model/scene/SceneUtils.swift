//
//  SceneUtils.swift
//  Pods
//
//  Created by Victor Sukochev on 01/03/2017.
//
//

class SceneUtils {
  static func shapeCopy(from: Shape) -> Shape {
    return  Shape(form: from.form,
                  fill: from.fill,
                  stroke: from.stroke,
                  place: from.place,
                  opaque: from.opaque,
                  opacity: from.opacity,
                  clip: from.clip,
                  effect: from.effect,
                  visible: from.visible,
                  tag: from.tag)
  }
}
