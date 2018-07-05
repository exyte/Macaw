//
//  SVGCanvas.swift
//  Macaw
//
//  Created by Yuri Strot on 4/11/18.
//

class SVGCanvas: Group {

    let layout: NodeLayout

    public init(layout: NodeLayout, contents: [Node] = []) {
        self.layout = layout
        super.init(contents: contents)
    }

    public func layout(size: Size) -> Size {
        let size = layout.computeSize(parent: size)
        layout.layout(node: self, in: size)
        return size
    }

    override var bounds: Rect? {
        let size = layout.computeSize(parent: .zero)
        if size.w == 0 || size.h == 0 {
            return .none
        }
        return size.rect(at: .origin)
    }

}
