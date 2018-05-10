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

}
