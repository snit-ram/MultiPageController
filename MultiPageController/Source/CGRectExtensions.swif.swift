//
//  CGRectExtensions.swif.swift
//  Pods
//
//  Created by  Rafael Martins on 11/6/16.
//
//

import UIKit

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(
            origin: CGPoint(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2
            ),
            size: size
        )
    }
    
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
