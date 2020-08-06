//
//  PathAnimationView.swift
//  Example
//
//  Created by Alisa Mylnikova on 29/05/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import UIKit
import Macaw

class PathAnimationView: MacawView {

    required init?(coder aDecoder: NSCoder) {
        super.init(node: Group(), coder: aDecoder)

        newScene()
    }

    func newScene() {
        let side = Double(150)
        let x = Double(self.bounds.width/2) - side/2
        let y = Double(self.bounds.height/2) - side/2
        let initialTriangle = Shape(form: makeInitialTriangle(side: side).cgPath.toMacaw(), stroke: Stroke(fill: randomEmeraldColor(), width: 1), place: .move(x, y))

        self.node = [initialTriangle].group()
        fractalStep(allTriangles: [initialTriangle], currentTier: [initialTriangle], side: side, depth: 0)
    }

    func fractalStep(allTriangles: [Shape], currentTier: [Shape], side: Double, depth: Int) {
        var tierAnimations = [Animation]()
        for shape in currentTier {
            tierAnimations.append(shape.strokeVar.end.animation(to: 1))
        }
        tierAnimations.combine().onComplete {
            if depth < 4 {
                let newTier = self.createTier(parentTier: currentTier, side: side/2)
                self.node = (allTriangles + newTier).group()
                self.fractalStep(allTriangles: allTriangles + newTier, currentTier: newTier, side: side/2, depth: depth+1)
            }
        }
        .play()
    }

    func createTier(parentTier: [Shape], side: Double) -> [Shape] {
        let a = sqrt(3)/2
        let pointLeft = CGPoint(x: 0, y: side*a)
        let pointRight = CGPoint(x: side, y: side*a)
        let pointUp = CGPoint(x: side/2, y: 0)

        let leftTriangle = makeTriangle(pointRight, pointUp, pointLeft)
        let rightTriangle = makeTriangle(pointLeft, pointRight, pointUp)
        let bottomTriangle = makeTriangle(pointUp, pointLeft, pointRight)

        var result: [Shape] = []
        for parent in parentTier {
            let left = Shape(form: leftTriangle.cgPath.toMacaw(), stroke: Stroke(fill: randomEmeraldColor(), width: 1), place: parent.place.move(-side/2, 0))
            let right = Shape(form: rightTriangle.cgPath.toMacaw(), stroke: Stroke(fill: randomEmeraldColor(), width: 1), place: parent.place.move(3*side/2, 0))
            let bottom = Shape(form: bottomTriangle.cgPath.toMacaw(), stroke: Stroke(fill: randomEmeraldColor(), width: 1), place: parent.place.move(side/2, side*sqrt(3)))
            result.append(contentsOf: [left, right, bottom])
        }

        return result
    }

    func makeTriangle(_ point1: CGPoint, _ point2: CGPoint, _ point3: CGPoint) -> MBezierPath {
        let path = MBezierPath()
        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.close()
        return path
    }

    func makeInitialTriangle(side: Double) -> MBezierPath {
        let a = sqrt(3)/2
        let pointLeft = CGPoint(x: 0, y: side*a)
        let pointRight = CGPoint(x: side, y: side*a)
        let pointUp = CGPoint(x: side/2, y: 0)

        return makeTriangle(pointRight, pointUp, pointLeft)
    }

    func randomEmeraldColor() -> Color {
        return Color.rgb(r: Int.random(in: 70...100), g: Int.random(in: 190...220), b: Int.random(in: 110...140))
    }

}
