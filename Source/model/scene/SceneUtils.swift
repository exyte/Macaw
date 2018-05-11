//
//  SceneUtils.swift
//  Pods
//
//  Created by Victor Sukochev on 01/03/2017.
//
//

class SceneUtils {
    static func shapeCopy(from: Shape) -> Shape {
        let shape = Shape(form: from.form,
                          fill: from.fill,
                          stroke: from.stroke,
                          place: from.place,
                          opaque: from.opaque,
                          opacity: from.opacity,
                          clip: from.clip,
                          effect: from.effect,
                          visible: from.visible,
                          tag: from.tag)

        shape.touchPressedHandlers = from.touchPressedHandlers
        shape.touchMovedHandlers = from.touchMovedHandlers
        shape.touchReleasedHandlers = from.touchReleasedHandlers

        shape.tapHandlers = from.tapHandlers
        shape.longTapHandlers = from.longTapHandlers
        shape.panHandlers = from.panHandlers
        shape.rotateHandlers = from.rotateHandlers
        shape.pinchHandlers = from.pinchHandlers

        return shape
    }
}
