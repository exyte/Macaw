import Macaw

class AnimationsView: MacawView {
  
  var animation: Animation?
  var ballNodes = [Group]()
  var onComplete: (() -> ()) = {}
  
  let n = 100
  let speed = 20.0
  let r = 10.0
  
  let ballColors = [
    Color(val: 0x1abc9c),
    Color(val: 0x2ecc71),
    Color(val: 0x3498db),
    Color(val: 0x9b59b6),
    Color(val: 0xf1c40f),
    Color(val: 0xe67e22),
    Color(val: 0xe67e22),
    Color(val: 0xe74c3c)
  ]
  
  required init?(coder aDecoder: NSCoder) {
    super.init(node: Group(), coder: aDecoder)
  }
  
  func startAnimation() {
    if let animation = self.animation {
      animation.play()
    }
  }
  
  func prepareAnimation() {
    ballNodes.removeAll()
    
    var animations = [Animation]()
    
    let screenBounds = self.bounds
    let startPos = Transform.move(
      dx: Double(screenBounds.width / 2) - r,
      dy: Double(screenBounds.height / 2) - r
    )
    
    var velocities = [Point]()
    var positions = [Point]()
    
    func posForTime(_ t: Double, index: Int) -> Point {
      
      let prevPos = positions[index]
      var velocity = velocities[index]
      
      var pos = prevPos.add(velocity)
      
      // Borders
      if pos.x < Double(self.bounds.width) / -2.0 || pos.x > Double(self.bounds.width) / 2.0 {
        velocity = Point(x: -1.0 * velocity.x, y: velocity.y)
        velocities[index] = velocity
        pos = prevPos.add(velocity)
      }
      
      if pos.y < Double(self.bounds.height) / -2.0 || pos.y > Double(self.bounds.height) / 2.0 {
        velocity = Point(x: velocity.x, y: -1.0 * velocity.y)
        velocities[index] = velocity
        pos = prevPos.add(velocity)
      }
      
      return pos
    }
    
    for i in 0 ... (n - 1) {
      // Node
      let circle = Circle(cx: r, cy: r, r: r)
      let shape = Shape(
        form: circle,
        fill: ballColors[Int(arc4random() % 7)]
      )
      
      let ballGroup = Group(contents: [shape])
      ballNodes.append(ballGroup)
      
      // Animation
      let velocity = Point(
        x: -0.5 * speed + speed * Double(arc4random() % 1000) / 1000.0,
        y: -0.5 * speed + speed * Double(arc4random() % 1000) / 1000.0)
      velocities.append(velocity)
      positions.append(Point(x: 0.0, y: 0.0))
      
      let anim = ballGroup.placeVar.animation({ (t) -> Transform in
        let pos = posForTime(t, index: i)
        positions[i] = pos
        return Transform().move(
          dx: pos.x,
          dy: pos.y)
      }, during: 3.0)
      
      animations.append([
        anim,
        ballGroup.opacityVar.animation((0.1 >> 1.0).t(3.0))
        ].combine())
    }
    
    animation = animations.combine().autoreversed().onComplete {
      self.completeAnimation()
    }
    
    let node = Group(contents: ballNodes)
    node.place = Transform().move(dx: startPos.dx, dy: startPos.dy)
    self.node = node
  }
  
  func completeAnimation() {
    self.node = Group()
    self.prepareAnimation()
    self.onComplete()
  }
  
}
