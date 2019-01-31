//
//  CreateWorkoutExerciseCollectionViewCell.swift
//  FitTime
//
//  Created by Francis Bato on 1/28/19.
//  Copyright © 2019 LateRisers. All rights reserved.
//

import UIKit

class CreateWorkoutExerciseCollectionViewCell: UICollectionViewCell {
    var muscles: [String] = [String]()
    var muscleViews: [UILabel] = [UILabel]()

    @IBOutlet weak var addButton: AddButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.isUserInteractionEnabled = false

        for _ in 1...4 {
            let l = PaddingLabel()
            l.backgroundColor = .white
            l.layer.borderColor = UIColor.lightGray.cgColor
            l.layer.borderWidth = 2.0
            l.textAlignment = NSTextAlignment.center
            l.textColor = .black
            l.translatesAutoresizingMaskIntoConstraints = false
            addSubview(l)
            muscleViews.append(l)
        }

        let l1 = muscleViews[0]
        l1.text = "Chest"
        l1.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        l1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true


        let l = muscleViews[1]
        l.text = "Biceps"
        l.bottomAnchor.constraint(equalTo: l1.bottomAnchor).isActive = true
        l.leftAnchor.constraint(equalTo: l1.rightAnchor, constant: 8).isActive = true

        let l2 = muscleViews[2]
        l2.text = "Quads"
        l2.topAnchor.constraint(equalTo: l1.bottomAnchor, constant: 7).isActive = true
        l2.leftAnchor.constraint(equalTo: l1.leftAnchor).isActive = true

        let l3 = muscleViews[3]
        l3.text = "Pectoral"
        l3.leftAnchor.constraint(equalTo: l2.rightAnchor, constant: 7).isActive = true
        l3.bottomAnchor.constraint(equalTo: l2.bottomAnchor).isActive = true

        
    }
    @IBAction func addButtonTapped(_ sender: AddButton) {
        sender.isSelected = !sender.isSelected
    }
}

class AddButton: UIButton {
    override var isSelected: Bool {
        didSet {
            if isSelected {
                setImage(UIImage(named: "added"), for: .normal)
            } else {
                 setImage(UIImage(named: "add"), for: .normal)
            }
        }
    }
}

@IBDesignable class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 8.0
    @IBInspectable var rightInset: CGFloat = 8.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}
