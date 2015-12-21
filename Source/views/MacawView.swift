//
//  MacawView.swift
//  Macaw
//
//  Created by Yuri Strot on 12/19/15.
//  Copyright © 2015 Exyte. All rights reserved.
//

import Foundation
import UIKit

public class MacawView: UIView {

    let node: Node

    public required init?(node: Node, coder aDecoder: NSCoder) {
        self.node = node
        super.init(coder: aDecoder)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init(node: Group(), coder: aDecoder)
    }

    override public func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext();
        if let shape = node as? Shape {
            setGeometry(shape.form!, ctx: ctx)
            setFill(shape.fill!, ctx: ctx)
        } else {
            print("Unsupported node: \(node)")
        }

        CGContextFillPath(ctx);
    }

    private func setGeometry(locus: Locus, ctx: CGContext?) {
        if let rect = locus as? Rect {
            CGContextAddRect(ctx, CGRect(x: CGFloat(rect.x), y: CGFloat(rect.y), width: CGFloat(rect.w), height: CGFloat(rect.h)))
        } else {
            print("Unsupported locus: \(locus)")
        }
    }

    private func setFill(fill: Fill, ctx: CGContext?) {
        if let color = fill as? Color {
            let red = CGFloat(Double(color.r()) / 255.0);
            let green = CGFloat(Double(color.g()) / 255.0);
            let blue = CGFloat(Double(color.b()) / 255.0);
            let alpha = CGFloat(Double(color.a()) / 255.0);
            CGContextSetRGBFillColor(ctx, red, green, blue, alpha);
        } else {
            print("Unsupported fill: \(fill)")
        }
    }

}
