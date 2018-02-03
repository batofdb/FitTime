//
//  FTAnimation.swift
//  FitTime
//
//  Created by Francis Bato on 1/28/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import Foundation
import UIKit

class FTBaseAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let operationType : UINavigationControllerOperation
    private let transitionDuration : TimeInterval

    init(operation: UINavigationControllerOperation) {
        operationType = operation
        transitionDuration = 0.4
    }

    init(operation: UINavigationControllerOperation, andDuration duration: TimeInterval) {
        operationType = operation
        transitionDuration = duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if operationType == .push {
            performPushTransition(transitionContext)
        } else if operationType == .pop {
            performPopTransition(transitionContext)
        }
    }

    func animationEnded(_ transitionCompleted: Bool) {

    }

    func performPushTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
                // Something really bad happend and it is not possible to perform the transition
                print("ERROR: Transition impossible to perform since either the destination view or the conteiner view are missing!")
                return
        }


        let container = transitionContext.containerView

        guard let fromViewController = transitionContext.viewController(forKey: .from) as? CollectionPushAndPoppable,
            let fromView = fromViewController.collectionView,
            let currentCell = fromViewController.sourceCell else {
                // There are not enough info to perform the animation but it is still possible
                // to perform the transition presenting the destination view
                container.addSubview(toView)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }

        // Add to container the destination view
        container.addSubview(toView)


        // Prepare the screenshot of the destination view for animation
        //let screenshotToView =  UIImageView(image: UIImage(view: toView.snapshotView(afterScreenUpdates: true)!))
        let screenshotToView =  UIImageView(image: toView.screenshot)
        // set the frame of the screenshot equals to the cell's one
        screenshotToView.frame = currentCell.frame
        // Now I get the coordinates of screenshotToView inside the container
        let containerCoord = fromView.convert(screenshotToView.frame.origin, to: container)
        // set a new origin for the screenshotToView to overlap it to the cell
        screenshotToView.frame.origin = containerCoord


        // Prepare the screenshot of the source view for animation
        //let screenshotFromView = UIImageView(image: UIImage(view: currentCell.snapshotView(afterScreenUpdates: true)!))
        let screenshotFromView = UIImageView(image: currentCell.screenshot)
        screenshotFromView.frame = screenshotToView.frame

        // Add screenshots to transition container to set-up the animation
        container.addSubview(screenshotToView)
        container.addSubview(screenshotFromView)

        // Set views initial states
        toView.isHidden = true
        screenshotToView.isHidden = true

        // Delay to guarantee smooth effects
        let delayTime = DispatchTime.now() + Double(Int64(0.08 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            screenshotToView.isHidden = false
        }

        UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: { () -> Void in

            screenshotFromView.alpha = 0.0
            screenshotToView.frame = UIScreen.main.bounds
            screenshotToView.frame.origin = CGPoint(x: 0.0, y: 0.0)
            screenshotFromView.frame = screenshotToView.frame

        }) { _ in

            screenshotToView.removeFromSuperview()
            screenshotFromView.removeFromSuperview()
            toView.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

        }
    }

    internal func performPopTransition(_ transitionContext: UIViewControllerContextTransitioning) {

        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            // Something really bad happend and it is not possible to perform the transition
            print("ERROR: Transition impossible to perform since either the destination view or the conteiner view are missing!")
            return
        }

        let container = transitionContext.containerView

        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? CollectionPushAndPoppable,
            let toCollectionView = toViewController.collectionView,
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromViewController.view,
            let currentCell = toViewController.sourceCell else {
                // There are not enough info to perform the animation but it is still possible
                // to perform the transition presenting the destination view
                container.addSubview(toView)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }

        // Add destination view to the container view
        container.addSubview(toView)

        // Prepare the screenshot of the source view for animation
        let screenshotFromView = UIImageView(image: fromView.screenshot)
        screenshotFromView.frame = fromView.frame

        // Prepare the screenshot of the destination view for animation
        let screenshotToView = UIImageView(image: currentCell.screenshot)
        screenshotToView.frame = screenshotFromView.frame

        // Add screenshots to transition container to set-up the animation
        container.addSubview(screenshotToView)
        container.insertSubview(screenshotFromView, belowSubview: screenshotToView)

        // Set views initial states
        screenshotToView.alpha = 0.0
        fromView.isHidden = true
        currentCell.isHidden = true

        let containerCoord = toCollectionView.convert(currentCell.frame.origin, to: container)

        UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: { () -> Void in

            screenshotToView.alpha = 1.0
            screenshotFromView.frame = currentCell.frame
            screenshotFromView.frame.origin = containerCoord
            screenshotToView.frame = screenshotFromView.frame

        }) { _ in

            currentCell.isHidden = false
            screenshotFromView.removeFromSuperview()
            screenshotToView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

        }
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}

extension UIView {
    var screenshot: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        if let tableView = self as? UITableView {
            tableView.superview!.layer.render(in: UIGraphicsGetCurrentContext()!)
        } else {
            layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}
