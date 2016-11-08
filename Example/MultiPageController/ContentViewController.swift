//
//  ContentViewController.swift
//  MultiPageController
//
//  Created by  Rafael Martins on 11/7/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    var text = "Some Content"
    
    override func viewDidLoad() {
        label.text = text
    }
}
