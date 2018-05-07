//
//  SVGCanvas.swift
//  Macaw
//
//  Created by Yuri Strot on 4/11/18.
//

class SVGCanvas: Group {
    
    let layout: ContentLayout

    public init(layout: ContentLayout, contents: [Node] = []) {
        self.layout = layout
        super.init(contents: contents)
    }

}
