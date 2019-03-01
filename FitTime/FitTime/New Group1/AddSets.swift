//
//  AddSets.swift
//  FitTime
//
//  Created by Francis Bato on 2/28/19.
//  Copyright © 2019 LateRisers. All rights reserved.
//

import UIKit

class AddSetsHeaderTableviewCell: UITableViewCell {
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menuImageView: NSLayoutConstraint!

    @IBOutlet weak var muscleImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .clear
    }
}

class AddSetsRowTableviewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var weightTextField: UITextField!

    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var operatorLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var repsTextField: UITextField!
    @IBOutlet weak var weightLabel: UILabel!

    @IBOutlet weak var setLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .clear
    }
}

class AddSetsAddRemoveTableviewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var addSetButton: UIButton!
    @IBOutlet weak var removeSetButton: UIButton!


    @IBAction func removeTapped(_ sender: UIButton) {
    }
    @IBAction func addTapped(_ sender: UIButton) {
    }
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .clear
    }
}

class AddSetsKeyboardAccessoryView: UIView {
    @IBOutlet weak var firstButton: UIButton!

    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!

    @IBAction func firstTapped(_ sender: UIButton) {
    }
    @IBAction func secondTapped(_ sender: UIButton) {
    }
    @IBAction func thirdButton(_ sender: UIButton) {
    }

}
