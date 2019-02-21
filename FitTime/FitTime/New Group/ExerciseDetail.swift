//
//  Exercise.swift
//  FitTime
//
//  Created by Francis Bato on 2/20/19.
//  Copyright © 2019 LateRisers. All rights reserved.
//
import UIKit

class ExerciseDetailViewController: UIViewController {
    var navigationView: FitTimeNavigationBar = {
        let nav = FitTimeNavigationBar()
        nav.translatesAutoresizingMaskIntoConstraints = false
        nav.backgroundColor = .white
        nav.titleLabel.textColor = .black
        nav.subTitleLabel.isHidden = true
        nav.gradientLayer.removeFromSuperlayer()
        nav.update(type: .basic)
        nav.leftButton.setImage(UIImage(named: "back_button"), for: .normal)
        nav.rightButton.setImage(UIImage(named: "add"), for: .normal)
        nav.rightButton.setTitle(nil, for: .normal)
        return nav
    }()

    var exercise: String? {
        didSet {
            navigationView.titleLabel.text = self.exercise
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(navigationView)
        navigationView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navigationView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationView.heightAnchor.constraint(equalToConstant: 140).isActive = true

        navigationView.leftButtonTappedHandler = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        exercise = "Deadlift"
    }
}
