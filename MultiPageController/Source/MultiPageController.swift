//
//  MultiPageController.swift
//  MultiPageController
//
//  Created by Rafael Martins on 10/2/16.
//  Copyright © 2016 Snit. All rights reserved.
//

import UIKit

let TransformIdentity: CATransform3D = {
    var identity = CATransform3DIdentity
    identity.m34 = 1.0 / 200
    return identity
}()

struct LayoutAttributes {
    var frame: CGRect
    var alpha: CGFloat
    var transform3D: CATransform3D
    var transformRatio: CGFloat
    var isHidden: Bool
}

public protocol MultiPageControllerDataSource : class {
    func numberOfItems(in: MultiPageController) -> Int
    func multiPageController(_ multiPageController: MultiPageController, viewControllerAt index: Int) -> UIViewController
    func multiPageController(_ multiPageController: MultiPageController, previewViewAt index: Int) -> UIView
}

enum State {
    case expanded
    case collapsed
    case transitioning
}

open class MultiPageController: UIViewController {
    var viewControllerIndex = 0
    
    open var sideScale: CGFloat = 0.6
    open var sideAlpha: CGFloat = 0.8
    open var autoSelectionDelay: TimeInterval = 0.6
    
    public weak var dataSource: MultiPageControllerDataSource!
    
    var pageViewControllers : [UIViewController?] = []
    
    var previewViews : [UIView] = []
    var containerViews : [UIView] = []
    var state = State.expanded {
        didSet {
            if state == .expanded {
                timer?.invalidate()
            }
        }
    }
    
    func createViewController(at index: Int) -> UIViewController {
        if let controller = pageViewControllers[index] {
            return controller
        }
        
        let container = containerViews[index]
        let viewController = dataSource.multiPageController(self, viewControllerAt: index)
        pageViewControllers[index] = viewController
        
        addChildViewController(viewController)
        container.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        viewController.view.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        return viewController
    }
    
    private var itemCount = 0
    
    let scrollView : ScrollView = {
        let scrollView = ScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.scrollsToTop = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.delegate = self
    }
    
    private func reset() {
        itemCount = 0
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        pageViewControllers = []
        viewControllerIndex = 0
    }
    
    var itemSize : CGSize {
        return itemSize(in: view.bounds)
    }

    func itemSize(in containerRect: CGRect) -> CGSize {
        let side = containerRect.width / 2
        return CGSize(width: side, height: side)
    }
    
    var sideItemSize : CGSize {
        return itemSize.applying(CGAffineTransform(scaleX: sideScale, y: sideScale))
    }
    
    var spacing : CGFloat {
        return 0
    }
    
    var visibleRect : CGRect {
        return CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
    }
    
    
    func layoutAttributes(forIndex index: Int) -> LayoutAttributes {
        let visibleCenter = visibleRect.center
        let maxDistance = view.bounds.width / 2
        let size = itemSize
        let frame = CGRect(
            origin: CGPoint(x: itemSize.width / 2 + itemSize.width * CGFloat(index), y: view.bounds.midY - size.height / 2),
            size: size
        )
        
        let distance = min(abs(frame.center.x - visibleCenter.x), maxDistance)
        let ratio = 1 - (distance / maxDistance)
        let scale = sideScale + (1 - sideScale) * ratio
        
        return LayoutAttributes(
            frame: frame,
            alpha: sideAlpha + (1 - sideAlpha) * ratio,
            transform3D: CATransform3DScale(TransformIdentity, scale, scale, 1.0),
            transformRatio: ratio,
            isHidden: false
        )
    }
    
    func containerLayoutAttributes(forIndex index: Int) -> LayoutAttributes {
        var attributes = layoutAttributes(forIndex: index)
        
        attributes.frame = CGRect(center: attributes.frame.center, size: view.bounds.size)
        
        switch state {
        case .collapsed:
            attributes.isHidden = true
        case .expanded, .transitioning:
            attributes.isHidden = index != viewControllerIndex
        }
        
        let targetScaleX = sideItemSize.width / attributes.frame.width
        let targetScaleY = sideItemSize.height / attributes.frame.height
        
        let scaleX = targetScaleX + (1 - targetScaleX) * attributes.transformRatio
        let scaleY = targetScaleY + (1 - targetScaleY) * attributes.transformRatio
        
        attributes.alpha = 1 * attributes.transformRatio
        attributes.transform3D = CATransform3DScale(TransformIdentity, scaleX, scaleY, 1)
        
        return attributes
    }
    
    @objc fileprivate func tapPreview(_ recognizer: UIGestureRecognizer) {
        guard let tappedView = recognizer.view,
            let index = previewViews.index(of: tappedView) else {
                return
        }
        
        expand(at: index)
    }
    
    open func reloadData() {
        reset()
        itemCount = dataSource.numberOfItems(in: self)
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.contentInset = .zero
        pageViewControllers = Array(repeating: nil, count: itemCount)
        
        scrollView.contentOffset = .zero
        
        (0..<itemCount).forEach { index in
            let previewView = UIView()
            let recognizer = TapRecognizer()
            recognizer.addTarget(self, action: #selector(tapPreview(_:)))
            previewView.isUserInteractionEnabled = true
            previewView.addGestureRecognizer(recognizer)
            previewViews.append(previewView)
            
            let previewContent = dataSource.multiPageController(self, previewViewAt: index)
            previewView.addSubview(previewContent)
            previewContent.translatesAutoresizingMaskIntoConstraints = false
            previewContent.topAnchor.constraint(equalTo: previewView.topAnchor).isActive = true
            previewContent.rightAnchor.constraint(equalTo: previewView.rightAnchor).isActive = true
            previewContent.bottomAnchor.constraint(equalTo: previewView.bottomAnchor).isActive = true
            previewContent.leftAnchor.constraint(equalTo: previewView.leftAnchor).isActive = true
            
            let containerView = UIView()
            containerView.backgroundColor = .white
            containerViews.append(containerView)
            
            scrollView.addSubview(previewView)
        }
        
        containerViews.forEach {
            scrollView.addSubview($0)
        }
        
        if itemCount > 0 {
            let controller = createViewController(at: viewControllerIndex)
            controller.didMove(toParentViewController: self)
        }
    }
    
    func apply(attributes: LayoutAttributes, to view: UIView){
        view.alpha = attributes.alpha
        view.layer.transform = attributes.transform3D
        view.isHidden = attributes.isHidden
    }
    
    func applyTransform(_ index: Int){
        apply(attributes: layoutAttributes(forIndex: index), to: previewViews[index])
    }
    
    func applyContainerTransform(_ index: Int){
        if state == .transitioning {
            return
        }
        
        let attributes = containerLayoutAttributes(forIndex: index)
        let targetView = containerViews[index]
        
        apply(attributes: attributes, to: targetView)
        
        if index == viewControllerIndex && attributes.transformRatio < 0.6 && state == .expanded {
            var finalAttributes = attributes
            finalAttributes.alpha = 0
            let targetScaleX = sideItemSize.width / attributes.frame.width
            let targetScaleY = sideItemSize.height / attributes.frame.height
            
            finalAttributes.transform3D = CATransform3DScale(TransformIdentity, targetScaleX, targetScaleY, 1)
            finalAttributes.isHidden = false
            
            state = .transitioning
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: [], animations: {
                self.apply(attributes: finalAttributes, to: targetView)
            }, completion: { completed in
                self.state = .collapsed
            })
        }
    }
    
    func visibleRange() -> Range<Int> {
        let midItem = max(Int(floor((scrollView.contentOffset.x + itemSize.width / 2) / itemSize.width)), 0)
        return max(midItem - 1, 0)..<min(midItem + 2, previewViews.count)
    }
    
    
    func visibleViews() -> ArraySlice<UIView> {
        return previewViews[visibleRange()]
    }
    
    func transformVisibleItems(){
        let midItem = max(Int(floor((scrollView.contentOffset.x + itemSize.width / 2) / itemSize.width)), 0)
        let affectedRange = max(midItem - 1, 0)..<min(midItem + 2, itemCount)
        
        affectedRange.forEach(applyTransform)
        previewViews.indices.forEach(applyContainerTransform)
    }
    
    func contentOffset(for index: Int, in containerRect: CGRect) -> CGPoint {
        return CGPoint(x: CGFloat(index) * itemSize(in: containerRect).width, y: 0)
    }
    
    func contentOffset(for index: Int) -> CGPoint {
        return contentOffset(for: index, in: view.bounds)
    }
    
    func contentSize(in containerRect: CGRect) -> CGSize {
        return CGSize(width: (itemSize(in: containerRect).width) * CGFloat(itemCount + 1), height: containerRect.height)
    }
    
    var contentSize : CGSize {
        return contentSize(in: view.bounds)
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        scrollView.contentSize = contentSize
        scrollView.setContentOffset(contentOffset(for: viewControllerIndex), animated: false)
        
        previewViews.enumerated().forEach { (index, view) in
            let attributes = layoutAttributes(forIndex: index)
            view.layer.transform = CATransform3DIdentity
            view.frame = attributes.frame
            view.center = attributes.frame.center
        }
        
        containerViews.enumerated().forEach { (index, view) in
            let attributes = containerLayoutAttributes(forIndex: index)
            view.layer.transform = CATransform3DIdentity
            view.frame = attributes.frame
            view.center = attributes.frame.center
        }
        
        previewViews.indices.forEach(applyTransform)
        containerViews.indices.forEach(applyContainerTransform)
    }
    
    var timer: Timer?
    
    open func expand(at index: Int){
        // makes sure we stop scrolling when expanding
        scrollView.panGestureRecognizer.isEnabled = false
        scrollView.panGestureRecognizer.isEnabled = true
        
        let currentContentOffset = scrollView.contentOffset
        let targetContentOffset = CGPoint(x: CGFloat(index) * self.itemSize.width, y: 0)
        
        timer?.invalidate()
        viewControllerIndex = index
        scrollView.setContentOffset(currentContentOffset, animated: false)
        let targetView = containerViews[index]
        
        var finalAttributes = containerLayoutAttributes(forIndex: index)
        finalAttributes.isHidden = false
        finalAttributes.alpha = 1
        finalAttributes.transform3D = TransformIdentity
        var attributes = finalAttributes
        
        let scaleX = itemSize.width / finalAttributes.frame.width
        let scaleY = itemSize.height / finalAttributes.frame.height
        attributes.transform3D = CATransform3DScale(TransformIdentity, scaleX, scaleY, 1)
        attributes.isHidden = false
        attributes.alpha = 0
        
        apply(attributes: attributes, to: targetView)
        
        let isNewViewController = pageViewControllers[index] == nil
        let viewController = createViewController(at: index)
        
        state = .transitioning
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: [], animations: {
            self.scrollView.setContentOffset(targetContentOffset, animated: false)
            self.apply(attributes: finalAttributes, to: targetView)
        }, completion: { completed in
            self.state = .expanded
            if isNewViewController {
                viewController.didMove(toParentViewController: self)
            }
        })
    }
}

extension MultiPageController : UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        timer?.invalidate()
        transformVisibleItems()
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var position = targetContentOffset.pointee
        position.x = round(position.x / itemSize.width) * itemSize.width
        targetContentOffset.pointee = position
    }
    
    @objc private func handleTimer(_ timer: Timer){
        guard let index = timer.userInfo as? Int else {
            return
        }
        
        if state == .collapsed {
            expand(at: index)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / itemSize.width))
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: autoSelectionDelay, target: self, selector: #selector(handleTimer(_:)), userInfo: index, repeats: false)
    }
}
