//
//  ViewController.swift
//  MultiPageController
//
//  Created by Rafael Martins on 11/05/2016.
//  Copyright (c) 2016 Rafael Martins. All rights reserved.
//

import UIKit
import MultiPageController

class ViewController: MultiPageController {
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = self
        reloadData()
    }
}

extension ViewController : MultiPageControllerDataSource {
    func multiPageController(_ multiPageController: MultiPageController, previewViewAt index: Int) -> UIView {
        let label = UILabel()
        label.text = "Item \(index)"
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }

    func numberOfItems(in: MultiPageController) -> Int {
        return 5
    }
    
    func multiPageController(_ multiPageController: MultiPageController, viewControllerAt index: Int) -> UIViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentVC")
        return viewController
    }
}
