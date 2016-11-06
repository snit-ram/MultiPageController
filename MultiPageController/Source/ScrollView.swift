//
//  ScrollView.swift
//  Pods
//
//  Created by  Rafael Martins on 11/6/16.
//
//

import UIKit

class TapRecognizer: UITapGestureRecognizer {}

class ScrollView: UIScrollView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == panGestureRecognizer && otherGestureRecognizer.isKind(of: TapRecognizer.self)
    }
}
