import UIKit
import Macaw

class EasingView: MacawView {
    
    var animations = [Animation]()
    var circlesNodes = [Group]()
    var animation: Animation!
    
    required init?(coder aDecoder: NSCoder) {
        let screenSize: CGRect = UIScreen.main.bounds
        let centerX = Double(screenSize.width / 2)
        
        let fromStroke = Stroke(fill: Color.black, width: 3)
        let toStroke = Stroke(fill: Color.black, width: 1, dashes: [3, 3])
        
        let all = [Easing.ease, Easing.linear, Easing.easeIn, Easing.easeOut, Easing.easeInOut, Easing.elasticInOut]
        
        for (i, easing) in all.enumerated() {
            let y = Double(150 + i * 75)
            let title = String(describing: type(of: easing))
            let titleText = Text(text: title, align: .mid, place: .move(dx: centerX, dy: y - 45))

            let fromCircle = Circle(cx: centerX - 100, cy: y, r: 25).stroke(with: fromStroke)
            let toCircle = Circle(cx: centerX + 100, cy: y, r: 25).stroke(with: toStroke)
            let toPlace = fromCircle.place.move(dx: 200, dy: 0)

            let toAnimation = fromCircle.placeVar.animation(to: toPlace).easing(easing)
            
            animations.append([toAnimation.autoreversed()].sequence())
            circlesNodes.append(Group(contents: [titleText, fromCircle, toCircle]))
        }
        
        animation = animations.combine().cycle()
        super.init(node: circlesNodes.group(), coder: aDecoder)
    }
}
