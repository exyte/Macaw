import Macaw

class EasingView: MacawView {
  var mAnimations = [Animation]()
  var circlesNodes = [Group]()
  var animation: Animation!
  
  required init?(coder aDecoder: NSCoder) {
    let centerX = 250.0
    
    let fromStroke = Stroke(fill: Color.black, width: 3)
    let all = [Easing.ease, Easing.linear, Easing.easeIn, Easing.easeOut, Easing.easeInOut, Easing.elasticInOut]
    
    for (i, easing) in all.enumerated() {
      let y = Double(60 + i * 75)
      let title = EasingView.title(easing: easing)
      let titleText = Text(text: title, align: .mid, place: .move(dx: centerX, dy: y - 45))
      
      let fromCircle = Circle(cx: centerX - 100, cy: y, r: 20).stroke(with: fromStroke)
      let toPlace = fromCircle.place.move(dx: 200, dy: 0)
      
      let toAnimation = fromCircle.placeVar.animation(to: toPlace).easing(easing)
      
      mAnimations.append([toAnimation.autoreversed()].sequence())
      circlesNodes.append(Group(contents: [titleText]))
      circlesNodes.append(Group(contents: [fromCircle]))
    }
    
    animation = mAnimations.combine().cycle()
    super.init(node: circlesNodes.group(), coder: aDecoder)
  }
  
  private static func title(easing: Easing) -> String {

    return "test"
//
//    switch easing {
//
//    case let _ = easing as? :
//        return "Ease"
//    case .linear: return "Linear"
//    case .easeIn: return "Ease In"
//    case .easeOut: return "Ease Out"
//    case .easeInOut: return "Ease InOut"
//
//    default:
//        return ""
//    }
  }
}
