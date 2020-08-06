//
//  MBezierPath+Extension_macOS.swift
//  Macaw
//
//  Created by Daniil Manin on 8/17/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

#if os(OSX)
import AppKit

public struct MRectCorner: OptionSet {
    public let rawValue: UInt

    public static let none = MRectCorner([])
    public static let topLeft = MRectCorner(rawValue: 1 << 0)
    public static let topRight = MRectCorner(rawValue: 1 << 1)
    public static let bottomLeft = MRectCorner(rawValue: 1 << 2)
    public static let bottomRight = MRectCorner(rawValue: 1 << 3)
    public static var allCorners: MRectCorner {
        return [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

extension MBezierPath {

    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)

            switch type {
            case .moveTo:
                path.move(to: CGPoint(x: points[0].x, y: points[0].y))

            case .lineTo:
                path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))

            case .curveTo:
                path.addCurve(
                    to: CGPoint(x: points[2].x, y: points[2].y),
                    control1: CGPoint(x: points[0].x, y: points[0].y),
                    control2: CGPoint(x: points[1].x, y: points[1].y))

            case .closePath:
                path.closeSubpath()
            @unknown default:
                fatalError("Type of element undefined")
            }
        }

        return path
    }

    public convenience init(arcCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        self.init()
        self.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
    }

    public convenience init(roundedRect rect: NSRect, byRoundingCorners corners: MRectCorner, cornerRadii: NSSize) {
        self.init()

        let kappa: CGFloat = 1.0 - 0.552228474

        let topLeft = rect.origin
        let topRight = NSPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = NSPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = NSPoint(x: rect.minX, y: rect.maxY)

        if corners.contains(.topLeft) {
            move(to: CGPoint(x: topLeft.x + cornerRadii.width, y: topLeft.y))

        } else {
            move(to: topLeft)
        }

        if corners.contains(.topRight) {
            line(to: CGPoint(x: topRight.x - cornerRadii.width, y: topRight.y))

            curve(to: CGPoint(x: topRight.x, y: topRight.y + cornerRadii.height),
                  controlPoint1: CGPoint(x: topRight.x - cornerRadii.width * kappa, y: topRight.y),
                  controlPoint2: CGPoint(x: topRight.x, y: topRight.y + cornerRadii.height * kappa))

        } else {
            line(to: topRight)
        }

        if corners.contains(.bottomRight) {
            line(to: CGPoint(x: bottomRight.x, y: bottomRight.y - cornerRadii.height))

            curve(to: CGPoint(x: bottomRight.x - cornerRadii.width, y: bottomRight.y),
                  controlPoint1: CGPoint(x: bottomRight.x, y: bottomRight.y - cornerRadii.height * kappa),
                  controlPoint2: CGPoint(x: bottomRight.x - cornerRadii.width * kappa, y: bottomRight.y))

        } else {
            line(to: bottomRight)
        }

        if corners.contains(.bottomLeft) {
            line(to: CGPoint(x: bottomLeft.x + cornerRadii.width, y: bottomLeft.y))

            curve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - cornerRadii.height),
                  controlPoint1: CGPoint(x: bottomLeft.x + cornerRadii.width * kappa, y: bottomLeft.y),
                  controlPoint2: CGPoint(x: bottomLeft.x, y: bottomLeft.y - cornerRadii.height * kappa))

        } else {
            line(to: bottomLeft)
        }

        if corners.contains(.topLeft) {
            line(to: CGPoint(x: topLeft.x, y: topLeft.y + cornerRadii.height))

            curve(to: CGPoint(x: topLeft.x + cornerRadii.width, y: topLeft.y),
                  controlPoint1: CGPoint(x: topLeft.x, y: topLeft.y + cornerRadii.height * kappa),
                  controlPoint2: CGPoint(x: topLeft.x + cornerRadii.width * kappa, y: topLeft.y))

        } else {
            line(to: topLeft)
        }

        close()
    }

    func addLine(to: NSPoint) {
        self.line(to: to)
    }

    func addCurve(to: NSPoint, controlPoint1: NSPoint, controlPoint2: NSPoint) {
        self.curve(to: to, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }

    func addQuadCurve(to: NSPoint, controlPoint: NSPoint) {
        let QP0 = self.currentPoint
        let CP3 = to

        let CP1 = CGPoint(
            x: QP0.x + ((2.0 / 3.0) * (controlPoint.x - QP0.x)),
            y: QP0.y + ((2.0 / 3.0) * (controlPoint.y - QP0.y))
        )

        let CP2 = CGPoint(
            x: to.x + (2.0 / 3.0) * (controlPoint.x - to.x),
            y: to.y + (2.0 / 3.0) * (controlPoint.y - to.y)
        )

        self.addCurve(to: CP3, controlPoint1: CP1, controlPoint2: CP2)
    }

    func addArc(withCenter: NSPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        let startAngleRadian = ((startAngle) * (180.0 / .pi))
        let endAngleRadian = ((endAngle) * (180.0 / .pi))
        self.appendArc(withCenter: withCenter, radius: radius, startAngle: startAngleRadian, endAngle: endAngleRadian, clockwise: !clockwise)
    }

    func addPath(path: NSBezierPath!) {
        self.append(path)
    }
}

#endif
