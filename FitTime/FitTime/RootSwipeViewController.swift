//
//  RootSwipeViewController.swift
//  FitTime
//
//  Created by Francis Bato on 2/13/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import ChameleonFramework


class RootSwipeViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var footerView: UIView!

    var currentIndex: Int = 0 {
        didSet {
            previousIndex = oldValue
            //print("current index\(currentIndex)")
        }
    }

    var previousIndex: Int = 0

    var imageViews: [UIImageView] = [UIImageView]()

    var rootViewControllers: [UIViewController] = [UIViewController]()
    var rootNavigationControllers: [UINavigationController] = [UINavigationController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self

        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        imageViews.append(thirdImageView)

        processImageViews()

        let vc1 = storyboard?.instantiateViewController(withIdentifier: "ExercisesViewController")
        let vc2 = storyboard?.instantiateViewController(withIdentifier: "WorkoutsViewController")
        let vc3 = storyboard?.instantiateViewController(withIdentifier: "ExercisesViewController")

        addRootViewController(vc: vc1!)
        addRootViewController(vc: vc2!)
        addRootViewController(vc: vc3!)

        layoutRootViewControllersInScrollView()

        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(rootNavigationControllers.count), height: view.frame.height)

        animateSelectedButon()

        scrollView.setContentOffset(CGPoint(x:375,y:0), animated: false)
    }

    func processImageViews() {
        for im in imageViews {
            let templateImage = im.image?.withRenderingMode(.alwaysTemplate)
            im.image = templateImage
            im.tintColor = UIColor.flatBlack
        }
    }

    func addRootViewController(vc: UIViewController) {
        let nav = UINavigationController(rootViewController: vc)
        addChildViewController(nav)
        rootViewControllers.append(vc)
        rootNavigationControllers.append(nav)
        scrollView.addSubview(nav.view)
        nav.didMove(toParentViewController: self)
    }

    func layoutRootViewControllersInScrollView() {
        for (idx, vc) in rootNavigationControllers.enumerated() {
            if idx > 0 {
                var vcFrame: CGRect = vc.view.frame
                vcFrame.origin.x = self.view.frame.width * CGFloat((idx))
                vc.view.frame = vcFrame
            }
        }
    }
}

extension RootSwipeViewController: UIScrollViewDelegate {
    enum SwipeDirection {
        case next
        case previous
        case none
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        func animateGrow(progress: CGFloat, withImage icon: UIImageView, scrollView: UIScrollView) {
            print("offset grow: \(progress)")
            let width = scrollView.frame.width
            let scale = max((progress) + 1, 1)
            icon.transform = CGAffineTransform(scaleX: scale, y: scale)
        }

        func animateShrink(progress: CGFloat, withImage icon: UIImageView, scrollView: UIScrollView) {
            print("offset shrink: \(progress)")
            let width = scrollView.frame.width
            let scale1 = max(1 + ((progress) * 1/width), 1)
            icon.transform = CGAffineTransform(scaleX: scale1, y: scale1)
        }

        let width = scrollView.frame.width
        let startingOffset: CGFloat = CGFloat(currentIndex) * width
        var destinationOffset: CGFloat = 0.0
        var direction: SwipeDirection = .none

        if scrollView.contentOffset.x < startingOffset {
            direction = .previous
        } else {
            direction = .next
        }

        if direction == .previous {
            destinationOffset = min(CGFloat(currentIndex - 1), 0.0) * width
        } else {
            destinationOffset = min(CGFloat(currentIndex + 1), CGFloat(rootViewControllers.count - 1)) * width
        }

        let delta: CGFloat = (CGFloat(width) - CGFloat(abs(scrollView.contentOffset.x - destinationOffset)))/CGFloat(width)
        print("delta \(delta)")
        let progress: CGFloat = max(min(1.0, delta),0)

        if currentIndex == 0 {
            animateGrow(progress: progress, withImage: imageViews[0], scrollView: scrollView)

            if direction == .next {
                animateShrink(progress: progress, withImage: imageViews[1], scrollView: scrollView)
            }
        } else if currentIndex == 1 {
            animateShrink(progress: progress, withImage: imageViews[0], scrollView: scrollView)
            if direction == .previous {
            } else if direction == .next {
                animateGrow(progress: progress, withImage: imageViews[2], scrollView: scrollView)
            }
        } else if currentIndex == 2 {
            animateGrow(progress: progress, withImage: imageViews[2], scrollView: scrollView)

        }
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = false
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = true
        currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
}

extension RootSwipeViewController {
    func animateSelectedButon() {
        var selectedImageView = imageViews[currentIndex]

    }
}
