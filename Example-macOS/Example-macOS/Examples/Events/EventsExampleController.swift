//
//  EventsExampleController.swift
//  Example
//
//  Created by Victor Sukochev on 02/03/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Macaw

class EventsExampleController: NSViewController {
  
  @IBOutlet weak var macawView: MacawView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    macawView?.node = loadScene()
  }
  
  enum PanelTool {
    case ellipse
    case rectangle
  }
  
  var selectedTool: PanelTool?
  
  private func loadScene() -> Node {
    
    return [createCanvas(), createPanel()].group()
  }
  
  private func createPanel() -> Node {
    let panel = Shape(form: Rect(x: 10.0, y: 10.0, w: 80.0, h: 120.0), fill: Color.clear, stroke: Stroke(fill: Color.black, width: 1.0))
    let panelGroup = [panel, createTools()].group()
    
    panelGroup.onPan { event in
      panelGroup.place = panelGroup.place.move(dx: event.dx, dy: event.dy)
    }
    
    return panelGroup
  }
  
  private func createCanvas() -> Node {
    let canvas = Shape(form: Rect(x: 0.0, y: 0.0,
                                  w: Double(macawView!.bounds.width),
                                  h: Double(macawView!.bounds.height)),
                       fill: Color.clear)
    let objectsGroup = Group(contents:[])
    
    return [canvas, objectsGroup].group()
  }
  
  private func createTools() -> Node {
    let ellipseTool = Shape(form: Ellipse(cx: 50.0, cy: 50.0, rx: 25, ry: 15),
                            fill: Color.clear,
                            stroke: Stroke(fill: Color.black, width: 1.0))
    
    let rectTool = Shape(form: Rect(x: 25.0, y: 75.0, w: 50.0, h: 30.0),
                         fill: Color.clear,
                         stroke: Stroke(fill: Color.black, width: 1.0))
    
    ellipseTool.onTap { _ in
      self.selectedTool = .ellipse
      ellipseTool.stroke = Stroke(fill: Color.blue, width: 2.0)
      rectTool.stroke    = Stroke(fill: Color.black, width: 1.0)
    }
    
    rectTool.onTap { _ in
      self.selectedTool = .rectangle
      rectTool.stroke    = Stroke(fill: Color.blue, width: 2.0)
      ellipseTool.stroke = Stroke(fill: Color.black, width: 1.0)
    }
    
    return [ellipseTool, rectTool].group()
  }
}

