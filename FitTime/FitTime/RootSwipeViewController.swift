//
//  RootSwipeViewController.swift
//  FitTime
//
//  Created by Francis Bato on 2/13/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit

class RootSwipeViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    var rootViewControllers: [UIViewController] = [UIViewController]()
    var rootNavigationControllers: [UINavigationController] = [UINavigationController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self


        let vc1 = storyboard?.instantiateViewController(withIdentifier: "ExercisesViewController")
        let vc2 = storyboard?.instantiateViewController(withIdentifier: "WorkoutsViewController")
        let vc3 = storyboard?.instantiateViewController(withIdentifier: "ExercisesViewController")

        addRootViewController(vc: vc1!)
        addRootViewController(vc: vc2!)
        addRootViewController(vc: vc3!)

        layoutRootViewControllersInScrollView()

        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(rootNavigationControllers.count), height: view.frame.height)
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
}
