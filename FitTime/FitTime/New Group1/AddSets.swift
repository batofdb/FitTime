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

    var checkboxTapped: ((Bool, UITableViewCell)->Void)?
    var checkboxSelected: Bool = false
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {

    }

    var tapGesture: UITapGestureRecognizer?
    @objc func onCheckboxTapped() {
        checkboxSelected = !checkboxSelected

        if checkboxSelected {
            checkboxImageView.image = UIImage(named: "selected_checkbox")
        } else {
            checkboxImageView.image = UIImage(named: "checkbox")
        }

        checkboxTapped?(checkboxSelected, self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.isUserInteractionEnabled = false
        if tapGesture == nil {
            checkboxImageView.isUserInteractionEnabled = true
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(onCheckboxTapped))
            checkboxImageView.addGestureRecognizer(tapGesture!)
        }
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
        contentView.isUserInteractionEnabled = false
        contentView.backgroundColor = .clear
        repsTextField.autocorrectionType = .no
        repsTextField.keyboardType = .numberPad

        weightTextField.autocorrectionType = .no
        weightTextField.keyboardType = .numberPad
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

extension UIView {
    @discardableResult   // 1
    func fromNib<T : UIView>() -> T? {   // 2
        guard let contentView = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {    // 3
            // xib not loaded, or its top view is of the wrong type
            return nil
        }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)     // 4
        contentView.translatesAutoresizingMaskIntoConstraints = false   // 5
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        return contentView   // 7
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

    required init?(coder aDecoder: NSCoder) {   // 2 - storyboard initializer
        super.init(coder: aDecoder)
        fromNib()   // 5.
    }
    init() {   // 3 - programmatic initializer
        super.init(frame: CGRect.zero)  // 4.
        fromNib()  // 6.
    }
}
