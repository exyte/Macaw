import Macaw

class EasingView: MacawView {
    
    var anims = [Animation]()
    var circlesNodes = [Group]()
    var animation: Animation!
    
    required init?(coder aDecoder: NSCoder) {
        let screenSize: CGRect = NSScreen.main()!.frame
        let centerX = Double(screenSize.width / 2)
        
        let fromStroke = Stroke(fill: Color.black, width: 3)
        
        let all = [Easing.ease, Easing.linear, Easing.easeIn, Easing.easeOut, Easing.easeInOut]
        
        for (i, easing) in all.enumerated() {
            let y = Double(150 + i * 120)
            let title = EasingView.title(easing: easing)
            let titleText = Text(text: title, align: .mid, place: .move(dx: centerX, dy: y - 70))

            let fromCircle = Circle(cx: centerX - 100, cy: y, r: 25).stroke(with: fromStroke)
            let toPlace = fromCircle.place.move(dx: 200, dy: 0)

            let toAnimation = fromCircle.placeVar.animation(to: toPlace).easing(easing)
            
            anims.append([toAnimation.autoreversed()].sequence())
            circlesNodes.append(Group(contents: [fromCircle, titleText]))
        }
        
        animation = anims.combine().cycle()
        super.init(node: circlesNodes.group(), coder: aDecoder)
    }
    
    fileprivate static func title(easing: Easing) -> String {
        switch easing {
        case .ease: return "Ease"
        case .linear: return "Linear"
        case .easeIn: return "Ease In"
        case .easeOut: return "Ease Out"
        case .easeInOut: return "Ease InOut"
        }
    }
}
