//
//  SVGExampleViewController.swift
//  Example
//
//  Created by Alisa Mylnikova on 17/05/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Macaw

class SVGExampleViewController: UIViewController {
    
    @IBOutlet var svgView: SVGView!

    var fileName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        svgView.fileName = fileName
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
