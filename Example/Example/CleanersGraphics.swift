import Foundation
import UIKit
import Macaw

enum CleanState {
    case PICKUP_REQUESTED
    case CLEANER_ON_WAY
    case NOW_CLEANING
    case CLOTHES_CLEAN
    case DONE
}

class CleanersGraphics {
    let activeColor = Color(val: 8375023)
    let disableColor = Color(val: 13421772)
    let buttonColor = Color(val: 1745378)
    let textColor = Color(val: 5940171)
    let size = 0.7
    let delta = 0.06
    let fontName = "MalayalamSangamMN"
    
    let x: Double
    let y: Double
    let r: Double

    init() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        x = Double(screenSize.size.width / 2)
        y = Double(screenSize.size.height / 2)
        r = Double(screenSize.size.width / 2) * size
    }
    
    func graphics(state: CleanState) -> Group {
        switch state {
        case .PICKUP_REQUESTED:
            return pickupRequested()
        case .CLEANER_ON_WAY:
            return cleanerOnTheWay()
        default:
            return pickupRequested()
        }
    }
    
    func pickupRequested() -> Group {
        return Group(contents: [circle(), text("PICK UP", y), text("REQUESTED", y + 35)])
    }
    
    func cleanerOnTheWay() -> Group {
        let circleShape = Circle(cx: x, cy: y, r: r * 0.9)
        let shape3 = Shape(
            form: circleShape,
            fill: buttonColor
        )
        
        let clip = Rect(x: x - r, y: y + r * 0.4, w: r * 2, h: r * 2)
        
        let circleGroup = Group(
            contents: [shape3],
            clip: clip
        )
        
        let cancel = Text(
            text: "CANCEL",
            font: Font(name: fontName, size: 16),
            fill: Color.white,
            align: Align.mid,
            baseline: Baseline.bottom,
            pos: Transform().move(0, my: 0)
        )
        
        let cancelCross = Path(
            segments: [
                Move(x: 0, y: 0, absolute: true),
                PLine(x: 6, y: 6),
                Move(x: 6, y: 0, absolute: true),
                PLine(x: -6, y: 6)
            ]
        )
        let cancelGroup = Group(contents: [
            Shape(
                form: cancelCross,
                stroke: Stroke(fill: Color.white, width: 1.3),
                pos: Transform().scale(3, sy: 3).move(-20, my: -7)
            )
        ])
        
        let g = Group(contents: [cancel, cancelGroup], pos: Transform().move(x + 20, my: y + r * 0.7))
        return Group(contents: [circle(1), circleGroup, g, text("CLEANER", y), text("ON THE WAY", y + 35)])
    }

    func circle(count: Int = 0) -> Group {
        func arc(extent: Double, shift: Double, color: Macaw.Color) -> Shape {
            let ellipse = Ellipse(cx: x, cy: y, rx: r, ry: r)
            let arc = Arc(ellipse: ellipse, shift: shift, extent: extent)
            return Shape(
                form: arc,
                stroke: Stroke(
                    fill: color,
                    width: 6,
                    cap: .round,
                    join: .round
                )
            )
        }
        
        func getColor(index: Int = 0) -> Color {
            if index < count {
                return activeColor
            }
            return disableColor
        }
        
        return Group(
            contents: [
                arc(M_PI + M_PI_2 + delta, shift: M_PI_2 - delta, color: getColor(0)),
                arc(delta, shift: M_PI_2 - delta, color: getColor(1)),
                arc(M_PI_2 + delta, shift: M_PI_2 - delta, color: getColor(2)),
                arc(M_PI + delta, shift: M_PI_2 - delta, color: getColor(3))
            ]
        )
    }
    
    func text(text: String, _ y: Double) -> Text {
        return Text(
            text: text,
            font: Font(name: fontName, size: 32),
            fill: textColor,
            align: Align.mid,
            baseline: Baseline.bottom,
            pos: Transform().move(x, my: y)
        )
    }
}