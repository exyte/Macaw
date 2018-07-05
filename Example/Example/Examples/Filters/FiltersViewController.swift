//
//  FiltersViewController.swift
//  Example
//
//  Created by Alisa Mylnikova on 04/06/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Macaw

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var macawView: MacawView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let yellowRect = Shape(form: Rect(x: 180, y: 30, w: 90, h: 90), fill: Color.yellow, stroke: Stroke(fill: Color.green, width: 3), effect: Effect.dropShadow())
        
        let stop1 = Stop(offset: 0, color: Color.blue.with(a: 0.3))
        let stop2 = Stop(offset: 1, color: Color.purple)
        let gradient = LinearGradient(stops: [stop1, stop2])
        let rect = Shape(form: Rect(x: 150, y: 200, w: 90, h: 90), fill: gradient, stroke: Stroke(fill: Color.green, width: 3))
        rect.effect = OffsetEffect(dx: 20, dy: 20).mapColor(
            with: ColorMatrix(values: [0.33, 0, 0, 0, 0.33,
                                       0.5, 0.5, 0, 0, 0,
                                       0.33, 0.33, 0.33, 0, 1,
                                       1, 1, 1, 1, 0])).blur(r: 4).blend()
        
        let circle = Shape(form: Circle(cx: 30, cy: 70, r: 50), fill: Color.navy, place: Transform(m11: 1, m12: 0, m21: 0, m22: 1, dx: 50, dy: 50))
        circle.effect = .dropShadow(dx: 10, dy: 10, r: 5, color: .teal)
        macawView.node = Group(contents: [yellowRect, rect, circle])

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
