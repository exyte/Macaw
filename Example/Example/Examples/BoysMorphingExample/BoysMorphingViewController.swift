//
//  BoysMorphingViewController.swift
//  Example
//
//  Created by Alisa Mylnikova on 29/04/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import UIKit
import Macaw

class BoysMorphingViewController: UIViewController {

    @IBOutlet weak var macawView: MacawView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let boyShort = try! SVGParser.parse(resource: "boy_1_short") as! Group
        let boyLong = try! SVGParser.parse(resource: "boy_1_long") as! Group

        boyShort.contentsVar.animation(to: boyLong.contents, during: 2.0).autoreversed().cycle().play()

        macawView.invalidateIntrinsicContentSize()
        macawView.layoutIfNeeded()
        macawView.contentMode = .topRight
        macawView.node = boyShort
    }

}
