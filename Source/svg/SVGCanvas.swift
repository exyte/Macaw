//
//  SVGCanvas.swift
//  Macaw
//
//  Created by Yuri Strot on 4/11/18.
//

class SVGCanvas: Group {
    
    let contentLayout: ContentLayout

    public init(contentLayout: ContentLayout, contents: [Node] = []) {
        self.contentLayout = contentLayout
        super.init(contents: contents)
    }

}
