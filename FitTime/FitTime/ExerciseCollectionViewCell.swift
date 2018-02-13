//
//  ExerciseCollectionViewCell.swift
//  FitTime
//
//  Created by Francis Bato on 1/28/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import Hue
import ChameleonFramework

class ExerciseCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var primaryView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    lazy var gradient: CAGradientLayer = [
        UIColor(hex: "#FD4340"),
        UIColor(hex: "#CE2BAE")
        ].gradient { gradient in
            gradient.speed = 0
            gradient.timeOffset = 0

            return gradient
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureWith(exercise: Exercise, and indexPath: IndexPath) {
        titleLabel.text = exercise.name
        let color = Colors.colorFor(indexPath: indexPath)
        backgroundColor = color
        titleLabel.textColor = ContrastColorOf(color, returnFlat: true)
    }

    func roundCorner() {
        primaryView.layer.cornerRadius = 10.0
        primaryView.layer.borderWidth = 1.0
        primaryView.layer.borderColor = UIColor.clear.cgColor
        primaryView.layer.masksToBounds = true

        gradient.frame = gradientView.frame
        gradientView.layer.addSublayer(gradient)
    }
}
