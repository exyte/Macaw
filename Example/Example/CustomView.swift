//
//  CustomView.swift
//  Example
//
//  Created by Yuri Strot on 12/19/15.
//  Copyright © 2015 Exyte. All rights reserved.
//

import Foundation
import UIKit
import Macaw

class CustomView: MacawView {

    required init?(coder aDecoder: NSCoder) {
        let rect = Rect(x: 50, y: 50, w: 50, h: 100)
        let shape1 = Shape(
            form: rect,
            fill: Color.blue
        )

        let round = RoundRect(
            rect: Rect(x: 150, y: 50, w: 50, h: 100),
            rx: 10,
            ry: 10
        )
        let shape2 = Shape(
            form: round,
            fill: Color.navy
        )

        let circle = Circle(cx: 50, cy: 200, r: 30)
        let shape3 = Shape(
            form: circle,
            fill: Color.purple
        )

        let ellipse = Ellipse(cx: 150, cy: 200, rx: 50, ry: 30)
        let shape4 = Shape(
            form: ellipse,
            fill: Color.fuchsia
        )

        let polygon = Polygon(points: [280, 60, 240, 95, 330, 150, 330, 100])
        let shape5 = Shape(
            form: polygon,
            fill: Color.aqua
        )
    
        let polyline = Polyline(points: [260, 150, 220, 185, 310, 240, 310, 190])
        let shape6 = Shape(
            form: polyline,
            stroke: Stroke(
                fill: Color.olive,
                width: 5,
                cap: .round,
                join: .round
            )
        )

        let line = Line(x1: 30, y1: 290, x2: 130, y2: 290)
        let shape7 = Shape(
            form: line,
            stroke: Stroke(
                fill: Color.lime,
                width: 10,
                cap: .round,
                join: .round
            )
        )

        let arc = Arc(ellipse: Ellipse(cx: 250, cy: 250, rx: 50, ry: 50), shift: M_PI / 2, extent: M_PI / 2)
        let shape8 = Shape(
            form: arc,
            stroke: Stroke(
                fill: Color.green,
                cap: .round,
                join: .round,
                dashes: [3, 3]
            )
        )

        let point = Point(x: 300, y: 290)
        let shape9 = Shape(
            form: point,
            stroke: Stroke(
                fill: Color.gray,
                width: 7,
                cap: .round,
                join: .round
            )
        )

        let triangle = Polygon(points: [50, 350, 20, 390, 80, 390])
        let shape10 = Shape(
            form: triangle,
            fill: LinearGradient(
                userSpace: false,
                stops: [
                    Stop(offset: 0, color: Color(val: 0xC02425)),
                    Stop(offset: 1, color: Color(val: 0xF0CB35))
                ],
                x1: 50,
                y1: 350,
                x2: 50,
                y2: 390
            )
        )

        let box = Rect(w: 40, h: 40)
        let shape11 = Shape(
            form: box,
            pos: Transform().move(120, my: 350),
            fill: LinearGradient(
                userSpace: true,
                stops: [
                    Stop(offset: 0, color: Color.black),
                    Stop(offset: 0.5, color: Color.red),
                    Stop(offset: 1, color: Color.black)
                ],
                x1: 0,
                y1: 0,
                x2: 1,
                y2: 1
            )
        )
        
        let line2 = Line(x1: 30, y1: 450, x2: 450, y2: 450)
        let textLine = Shape(
            form: line2,
            stroke: Stroke(
                fill: Color.black,
                width: 1,
                cap: .round,
                join: .round
            )
        )
        
        let text = Text(
            text: "Toy top",
            font: Font(),
            fill: Fill(),
            align: Align.min,
            baseline: Baseline.top,
            pos: Transform().move(10, my: 450)
        )
        
        let text2 = Text(
            text: "Toy alphabetic",
            font: Font(),
            fill: Fill(),
            align: Align.min,
            baseline: Baseline.alphabetic,
            pos: Transform().move(80, my: 450)
        )

        let text3 = Text(
            text: "Toy bottom",
            font: Font(),
            fill: Fill(),
            align: Align.min,
            baseline: Baseline.bottom,
            pos: Transform().move(180, my: 450)
        )
        
        let text4 = Text(
            text: "Toy middle",
            font: Font(),
            fill: Fill(),
            align: Align.min,
            baseline: Baseline.mid,
            pos: Transform().move(250, my: 450)
        )
        
        let line3 = Line(x1: 50, y1: 470, x2: 50, y2: 600)
        let textLine2 = Shape(
            form: line3,
            stroke: Stroke(
                fill: Color.black,
                width: 1,
                cap: .round,
                join: .round
            )
        )
        
        let text5 = Text(
            text: "text",
            font: Font(),
            fill: Color.fuchsia,
            align: Align.min,
            baseline: Baseline.top,
            pos: Transform().move(50, my: 480)
        )
        
        let text6 = Text(
            text: "text",
            font: Font(),
            fill: Color.blue,
            align: Align.mid,
            baseline: Baseline.top,
            pos: Transform().move(50, my: 500)
        )
        
        let text7 = Text(
            text: "text",
            font: Font(),
            fill: Color.aqua,
            align: Align.max,
            baseline: Baseline.top,
            pos: Transform().move(50, my: 520)
        )
        
        func cloudExample() -> Group {
            func cloud1() -> Path {
                return Path(segments: [
                    Move(x: 441.953, y: 142.352, absolute: true),
                    Cubic(x1: -4.447, y1: -68.872, x2: -61.709, y2: -123.36, x: -131.705, y: -123.36, absolute: false),
                    Cubic(x1: -59.481, y1: 0, x2: -109.766, y2: 39.346, x: -126.264, y: 93.429, absolute: false),
                    Cubic(x1: -9.244, y1: -3.5, x2: -19.259, y2: -5.431, x: -29.729, y: -5.431, absolute: false),
                    Cubic(x1: -42.84, y1: 0, x2: -78.164, y2: 32.08, x: -83.322, y: 73.523, absolute: false),
                    Cubic(x1: -0.309, y1: -0.004, x2: -0.614, y2: -0.023, x: -0.924, y: -0.023, absolute: false),
                    Cubic(x1: -36.863, y1: 0, x2: -66.747, y2: 29.883, x: -66.747, y: 66.747, absolute: false),
                    SCubic(x2: 29.883, y2: 66.746, x: 66.747, y: 66.746, absolute: false),
                    Cubic(x1: 4.386, y1: 0, x2: 8.669, y2: -0.436, x: 12.819, y: -1.243, absolute: false),
                    Cubic(x1: 20.151, y1: 27.069, x2: 52.394, y2: 44.604, x: 88.734, y: 44.604, absolute: false),
                    Cubic(x1: 31.229, y1: 0, x2: 59.429, y2: -12.952, x: 79.533, y: -33.772, absolute: false),
                    Cubic(x1: 15.071, y1: 15.091, x2: 35.901, y2: 24.428, x: 58.913, y: 24.428, absolute: false),
                    Cubic(x1: 31.43, y1: 0, x2: 58.783, y2: -17.42, x: 72.955, y: -43.127, absolute: false),
                    Cubic(x1: 11.676, y1: 5.824, x2: 24.844, y2: 9.106, x: 38.777, y: 9.106, absolute: false),
                    Cubic(x1: 48.047, y1: 0, x2: 86.998, y2: -38.949, x: 86.998, y: -86.996, absolute: false),
                    Cubic(x1: 508.738, y1: 185.895, x2: 480.252, y2: 151.465, x: 441.953, y: 142.352, absolute: true),
                    Close()
                ])
            }
            
            func cloud2() -> Path {
                return Path(segments: [
                    Move(x: 431.357, y: 266.878, absolute: true),
                    Cubic(x1: 0.058, y1: -1.449, x2: 0.187, y2: -2.878, x: 0.187, y: -4.333, absolute: false),
                    Cubic(x1: 0, y1: -74.304, x2: -60.587, y2: -134.545, x: -135.315, y: -134.545, absolute: false),
                    Cubic(x1: -54.09, y1: 0, x2: -100.571, y2: 31.647, x: -122.229, y: 77.266, absolute: false),
                    Cubic(x1: -11.06, y1: -7.422, x2: -24.343, y2: -11.812, x: -38.686, y: -11.812, absolute: false),
                    Cubic(x1: -36.586, y1: 0, x2: -66.518, y2: 28.14, x: -69.214, y: 63.836, absolute: false),
                    Cubic(x1: 27.625, y1: 270.685, x2: 0, y2: 306.991, x: 0, y: 349.819, absolute: true),
                    Cubic(x1: 0, y1: 404.045, x2: 44.2, y2: 448, x: 98.743, y: 448, absolute: true),
                    HLine(x: 321.828, absolute: false),
                    Cubic(x1: 471.057, y1: 448, x2: 512, y2: 407.29, x: 512, y: 357.091, absolute: true),
                    Cubic(x1: 512, y1: 310.514, x2: 476.757, y2: 272.184, x: 431.357, y: 266.878, absolute: true),
                    Close()
                ])
            }
            
            func lightning() -> Path {
                return Path(segments: [
                    Move(x: 0, y: 0),
                    PLine(x: 23, y: 23, absolute: true),
                    PLine(x: 11, y: 27, absolute: true),
                    PLine(x: 55, y: 70, absolute: true),
                    PLine(x: 31, y: 31, absolute: true),
                    PLine(x: 42, y: 27, absolute: true),
                    PLine(x: 20, y: 0, absolute: true),
                    Close()
                ])
            }
            
            let cloud2Shape = Shape(
                form: cloud2(),
                pos: Transform.scale(1.5, sy: 1.5).move(0, my: -100),
                fill: Color(val: 0x60636e),
                stroke: Stroke(
                    fill: Color(val: 0x7e8087),
                    width: 2,
                    cap: .round,
                    join: .round
                )
            )

            let lightningShape = Shape(
                form: lightning(),
                pos: Transform.move(375, my: 390).scale(3, sy: 3),
                fill: LinearGradient(
                    userSpace: true,
                    stops: [
                        Stop(offset: 0, color: Color.rgb(250, g: 220, b: 0)),
                        Stop(offset: 1, color: Color(val: 0xeb6405))
                    ],
                    y2: 1
                )
            )
            
            let cloud1Shape = Shape(
                form: cloud1(),
                pos: Transform.move(120, my: 120),
                fill: LinearGradient(
                    userSpace: false,
                    stops: [
                        Stop(offset: 0, color: Color(val: 0x2f3036)),
                        Stop(offset: 1, color: Color.rgba(47, g: 48, b: 54, a: 0.1))
                    ],
                    y2: 1
                )
            )

            let cloud1Shape2 = Shape(
                form: cloud1(),
                pos: Transform.move(120, my: 100),
                fill: Color(val: 0x7b808c),
                stroke: Stroke(
                    fill: Color(val: 0xaaacb3),
                    width: 1,
                    cap: .round,
                    join: .round
                )
            )
            
            return Group(
                contents: [cloud2Shape, lightningShape, cloud1Shape, cloud1Shape2],
                pos: Transform.move(220, my: 320).scale(0.15, sy: 0.15)
            )
        }
        
        let group = Group(
            contents: [
                shape1,
                shape2,
                shape3,
                shape4,
                shape5,
                shape6,
                shape7,
                shape8,
                shape9,
                shape10,
                shape11,
                textLine,
                text,
                text2,
                text3,
                text4,
                textLine2,
                text5,
                text6,
                text7,
                cloudExample()
            ]
        )
        
        super.init(node: group, coder: aDecoder)
    }

    required init?(node: Node, coder aDecoder: NSCoder) {
        super.init(node: node, coder: aDecoder)
    }

}
