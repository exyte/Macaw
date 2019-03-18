//
//  TextsExampleView.swift
//  Example
//
//  Created by Andrew Romanov on 28/02/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import Macaw

class TextsExampleView: MacawView {
  
  required init?(coder aDecoder: NSCoder) {
    let text1 = TextsExampleView.newText("Font", .move(dx: 100, dy: 40))
    text1.font = Font(name: "Helvetica", size: 20, weight: "normal")
    
    let text2 = TextsExampleView.newText("Stroke", .move(dx: 100, dy: 200))
    text2.font = Font(name: "Helvetica", size: 40, weight: "normal")
    text2.fill = Color(val: 0xFF0000);
    text2.stroke = Stroke(fill: Color(val: 0x00FF00), width: 20.0);
    
    let text4 = TextsExampleView.newText("Stroke", .move(dx: 100, dy: 200))
    text4.font = Font(name: "Helvetica", size: 40, weight: "normal")
    text4.fill = Color(val: 0xFF0000);
    
    let text3 = TextsExampleView.newText("Kern inc", .move(dx: 100, dy: 250))
    text3.kerning = 3.0
    
    let text5 = TextsExampleView.newText("Kern dec", .move(dx: 100, dy: 300))
    text5.kerning = -1.0
    
    let group = Group(
      contents: [
        text1, text2, text3, text4, text5
      ]
    )
    
    super.init(node: group, coder: aDecoder)
  }
  
  fileprivate static func newText(_ text: String, _ place: Transform, baseline: Baseline = .bottom) -> Text {
    return Text(text: text, fill: Color.black, align: .mid, baseline: baseline, place: place)
  }
  
}

