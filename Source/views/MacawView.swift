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
        drawNode(node, ctx: ctx)
    }

    private func drawNode(node: Node, ctx: CGContext?) {
        CGContextSaveGState(ctx)
        if let shape = node as? Shape {
            setGeometry(shape.form!, ctx: ctx)
            setFill(shape.fill, ctx: ctx)
            setStroke(shape.stroke, ctx: ctx)
        } else if let group = node as? Group {
            for content in group.contents {
                drawNode(content, ctx: ctx)
            }
        } else {
            print("Unsupported node: \(node)")
        }
        CGContextRestoreGState(ctx)
    }

    private func setGeometry(locus: Locus, ctx: CGContext?) {
        if let rect = locus as? Rect {
            CGContextAddRect(ctx, newCGRect(rect))
        } else if let round = locus as? RoundRect {
            let corners = CGSizeMake(CGFloat(round.rx), CGFloat(round.ry))
            let path = UIBezierPath(roundedRect: newCGRect(round.rect!), byRoundingCorners:
                UIRectCorner.AllCorners, cornerRadii: corners).CGPath
            CGContextAddPath(ctx, path)
        } else if let circle = locus as? Circle {
            let cx = circle.cx
            let cy = circle.cy
            let r = circle.r
            CGContextAddEllipseInRect(ctx, CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        } else if let ellipse = locus as? Ellipse {
            let cx = ellipse.cx
            let cy = ellipse.cy
            let rx = ellipse.rx
            let ry = ellipse.ry
            CGContextAddEllipseInRect(ctx, CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
        } else if let arc = locus as? Arc {
            CGContextAddPath(ctx, toBezierPath(arc).CGPath)
        } else if let point = locus as? Point {
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(CGFloat(point.x), CGFloat(point.y)))
            path.addLineToPoint(CGPointMake(CGFloat(point.x), CGFloat(point.y)))
            CGContextAddPath(ctx, path.CGPath)
        } else if let line = locus as? Line {
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(CGFloat(line.x1), CGFloat(line.y1)))
            path.addLineToPoint(CGPointMake(CGFloat(line.x2), CGFloat(line.y2)))
            CGContextAddPath(ctx, path.CGPath)
        } else if let polygon = locus as? Polygon {
            let path = toBezierPath(polygon.points)
            path.closePath()
            CGContextAddPath(ctx, path.CGPath)
        } else if let polygon = locus as? Polyline {
            CGContextAddPath(ctx, toBezierPath(polygon.points).CGPath)
        } else {
            print("Unsupported locus: \(locus)")
        }
    }

    private func toBezierPath(points: [Double]) -> UIBezierPath {
        let parts = 0.stride(to: points.count, by: 2).map { Array(points[$0..<$0 + 2]) }
        let path = UIBezierPath()
        var first = true
        for part in parts {
            let point = CGPointMake(CGFloat(part[0]), CGFloat(part[1]))
            if (first) {
                path.moveToPoint(point)
                first = false
            } else {
                path.addLineToPoint(point)
            }
        }
        return path
    }

    private func toBezierPath(arc: Arc) -> UIBezierPath {
        let extent = CGFloat(arc.extent)
        let end = CGFloat(arc.shift) + extent
        let ellipse = arc.ellipse!
        if (ellipse.rx == ellipse.ry) {
            let center = CGPointMake(CGFloat(ellipse.cx), CGFloat(ellipse.cy))
            return UIBezierPath(arcCenter: center, radius: CGFloat(ellipse.rx), startAngle: extent, endAngle: end, clockwise: true)
        }
        print("Only circle arc supported for now")
        return UIBezierPath()
    }

    private func newCGRect(rect: Rect) -> CGRect {
        return CGRect(x: CGFloat(rect.x), y: CGFloat(rect.y), width: CGFloat(rect.w), height: CGFloat(rect.h))
    }

    private func setFill(fill: Fill?, ctx: CGContext?) {
        if fill != nil {
            if let color = fill as? Color {
                CGContextSetFillColorWithColor(ctx, mapColor(color))
                CGContextFillPath(ctx);
            } else if let gradient = fill as? LinearGradient {
                var start = CGPointMake(CGFloat(gradient.x1), CGFloat(gradient.y1))
                var end = CGPointMake(CGFloat(gradient.x2), CGFloat(gradient.y2))
                if gradient.userSpace {
                    let bounds = CGContextGetPathBoundingBox(ctx)
                    start = CGPointMake(start.x * bounds.width + bounds.minX, start.y * bounds.height + bounds.minY)
                    end = CGPointMake(end.x * bounds.width + bounds.minX, end.y * bounds.height + bounds.minY)
                }
                var colors: [CGColor] = []
                var stops: [CGFloat] = []
                for stop in gradient.stops {
                    stops.append(CGFloat(stop.offset))
                    colors.append(mapColor(stop.color!))
                }
                let cgGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, stops)
                CGContextClip(ctx)
                CGContextDrawLinearGradient(ctx, cgGradient, start, end, CGGradientDrawingOptions.DrawsAfterEndLocation)
            } else {
                print("Unsupported fill: \(fill)")
            }
        }
    }

    private func mapColor(color: Color) -> CGColor {
        let red = CGFloat(Double(color.r()) / 255.0);
        let green = CGFloat(Double(color.g()) / 255.0);
        let blue = CGFloat(Double(color.b()) / 255.0);
        let alpha = CGFloat(Double(color.a()) / 255.0);
        return UIColor(red: red, green: green, blue: blue, alpha: alpha).CGColor
    }

    private func setStroke(stroke: Stroke?, ctx: CGContext?) {
        if stroke != nil {
            if let color = stroke!.fill as? Color {
                CGContextSetLineWidth(ctx, CGFloat(stroke!.width))
                CGContextSetLineJoin(ctx, mapLineJoin(stroke!.join))
                CGContextSetLineCap(ctx, mapLineCap(stroke!.cap))
                let dashes = stroke!.dashes
                if !dashes.isEmpty {
                    let dashPointer = mapDash(dashes)
                    CGContextSetLineDash(ctx, 0, dashPointer, dashes.count)
                    dashPointer.dealloc(dashes.count)
                }
                CGContextSetStrokeColorWithColor(ctx, mapColor(color))
                CGContextStrokePath(ctx)
            } else {
                print("Unsupported stroke fill: \(stroke!.fill)")
            }
        }
    }

    private func mapLineJoin(join: LineJoin?) -> CGLineJoin {
        switch join {
            case LineJoin.round?: return CGLineJoin.Round
            case LineJoin.bevel?: return CGLineJoin.Bevel
            default: return CGLineJoin.Miter
        }
    }

    private func mapLineCap(cap: LineCap?) -> CGLineCap {
        switch cap {
            case LineCap.round?: return CGLineCap.Round
            case LineCap.square?: return CGLineCap.Square
            default: return CGLineCap.Butt
        }
    }

    private func mapDash(dashes: [Double]) -> UnsafeMutablePointer<CGFloat> {
        let p = UnsafeMutablePointer<CGFloat>(calloc(dashes.count, sizeof(CGFloat)))
        for (index, item) in dashes.enumerate() {
            p[index] = CGFloat(item)
        }
        return p;
    }

}
