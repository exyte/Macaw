//
//  AnimationsHierarchyViewController.swift
//  Example
//
//  Created by Alisa Mylnikova on 29/04/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import UIKit
import Macaw

class AnimationsHierarchyViewController: UIViewController {

    @IBOutlet weak var animView: MacawView!

    var startCallbacks: [()->()] = []
    var stopCallbacks: [()->()] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        animView.node = createTree(height: 3)
        animView.zoom.enable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startCallbacks.forEach {
            $0()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopCallbacks.forEach {
            $0()
        }
    }

    func createTree(height: Int) -> Node {
        let rect = Rect(w: 10, h: 10)

        let root = createLeaf(childForm: rect, xDelta: Double(UIScreen.main.bounds.width/2), yDelta: 20)
        createLeavesRecursive(root, maxLevel: height, childForm: rect)
        return root
    }

    func createLeavesRecursive(_ root: Group, maxLevel: Int, _ level: Int = 0, childForm: Locus) {
        if level == maxLevel {
            return
        }
        let (left, right) = createLeaves(root, childForm: childForm, level: level)
        createLeavesRecursive(left, maxLevel: maxLevel, level + 1, childForm: childForm)
        createLeavesRecursive(right, maxLevel: maxLevel, level + 1, childForm: childForm)
    }

    func createLeaves(_ root: Group, childForm: Locus, level: Int) -> (Group, Group) {
        let delta = Double(90/(level+1))
        let height = Double(50)
        let inset = childForm.bounds().w / 2
        let left = createLeaf(childForm: childForm, xDelta: -delta, yDelta: height)
        let right = createLeaf(childForm: childForm, xDelta: delta, yDelta: height)
        let leftBranch = Shape(form: Line(x1: 0, y1: inset, x2: -delta, y2: height - inset), stroke: Stroke(fill: Color.purple, width: 2))
        let rightBranch = Shape(form: Line(x1: 0, y1: inset, x2: delta, y2: height - inset), stroke: Stroke(fill: Color.purple, width: 2))
        root.contents.append(contentsOf: [leftBranch, rightBranch, left, right])
        return (left, right)
    }

    func createLeaf(childForm: Locus, xDelta: Double, yDelta: Double) -> Group {
        let inset = childForm.bounds().w / 2
        let leaf = Shape(form: childForm, fill: Color.teal, place: .move(dx: -inset, dy: -inset))

        let animation = leaf.placeVar.animation(angle: 2 * .pi, during: 5).cycle()
        startCallbacks.append({
            animation.play()
        })
        stopCallbacks.append({
            animation.stop()
        })

        let leafGroup = [leaf].group(place: .move(dx: xDelta, dy: yDelta))
        leaf.onTap { _ in
            leafGroup.placeVar.animation(angle: .pi / 4, x: leaf.place.dx, y: leaf.place.dy, during: 2).easing(.elasticOut).autoreversed().play()
        }
        return leafGroup
    }

}
