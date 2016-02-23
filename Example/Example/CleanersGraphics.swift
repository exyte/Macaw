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
        return Group(contents: [circle(1), text("CLEANER", y), text("ON THE WAY", y + 35)])
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