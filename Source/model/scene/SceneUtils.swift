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

    static func copyNode(_ referenceNode: Node) -> Node? {
        let pos = referenceNode.place
        let opaque = referenceNode.opaque
        let visible = referenceNode.visible
        let clip = referenceNode.clip
        let tag = referenceNode.tag

        if let shape = referenceNode as? Shape {
            return Shape(form: shape.form, fill: shape.fill, stroke: shape.stroke, place: pos, opaque: opaque, clip: clip, visible: visible, tag: tag)
        }
        if let text = referenceNode as? Text {
            return Text(text: text.text, font: text.font, fill: text.fill, stroke: text.stroke, align: text.align, baseline: text.baseline, place: pos, opaque: opaque, clip: clip, visible: visible, tag: tag)
        }
        if let image = referenceNode as? Image {
            return Image(src: image.src, xAlign: image.xAlign, yAlign: image.yAlign, aspectRatio: image.aspectRatio, w: image.w, h: image.h, place: pos, opaque: opaque, clip: clip, visible: visible, tag: tag)
        }
        if let group = referenceNode as? Group {
            var contents = [Node]()
            group.contents.forEach { node in
                if let copy = copyNode(node) {
                    contents.append(copy)
                }
            }
            return Group(contents: contents, place: pos, opaque: opaque, clip: clip, visible: visible, tag: tag)
        }
        return .none
    }
}
