//
//  EventsExampleController.swift
//  Example
//
//  Created by Victor Sukochev on 02/03/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Macaw

class EventsExampleController: UIViewController {
    
    @IBOutlet weak var macawView: MacawView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        macawView?.node = loadScene()
    }
    
    private func loadScene() -> Node {
        let shape1 = Shape(form: Rect(x: 10.0, y: 10.0, w: 100.0, h: 100.0), fill: Color.red)
        let shape2 = Shape(form: Rect(x: 10.0, y: 150.0, w: 100.0, h: 100.0), fill: Color.green)
        let shape3 = Shape(form: Rect(x: 150.0, y: 10.0, w: 100.0, h: 100.0), fill: Color.blue)
        
        
//        shape1.onPan { event in
//            shape1.place = shape1.place.move(dx: event.dx, dy: event.dy)
//        }
//        
//        shape2.onPan { event in
//            shape2.place = shape2.place.move(dx: event.dx, dy: event.dy)
//        }
//        
//        shape3.onPan { event in
//            shape3.place = shape3.place.move(dx: event.dx, dy: event.dy)
//        }
//
        shape1.onTouchMoved { event in
            if event.points.count < 2 {
                return
            }
            
            guard let point = event.points.first else {
                return
            }
            
            shape1.place = Transform.move(dx: point.location.x, dy: point.location.y)
        }
        
        return [
            shape1,
            shape2,
            shape3
            ].group()
    }
}
