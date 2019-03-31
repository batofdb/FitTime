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
    @IBOutlet weak var titleLabel: FTLabel!
    @IBOutlet weak var bodyImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()

        commonInit()
        contentView.isUserInteractionEnabled = false

//        contentView.frame = self.bounds
//        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    }
    @IBAction func addButtonTapped(_ sender: AddButton) {
        sender.isSelected = !sender.isSelected
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
//        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        commonInit()
    }

    func commonInit() {
        for _ in 1...4 {
            let l = PaddingLabel()
            l.backgroundColor = .white
            l.layer.borderColor = UIColor(red: 223/255.0, green: 223/255.0, blue: 230/255.0, alpha: 1.0).cgColor
            l.layer.borderWidth = 1.0
            l.adjustsFontForContentSizeCategory = true
            l.textAlignment = NSTextAlignment.center
            l.textColor = UIColor(red: 35/255.0, green: 37/255.0, blue: 58.0/255.0, alpha: 1.0)
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let point = touches.first?.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let pageContainerView = superview?.superview?.superview?.superview else {
            return super.hitTest(point, with: event)
        }

        if !self.isHidden && self.alpha > 0 {
            for sub in subviews.reversed() {
                let subPoint = pageContainerView.convert(point, to: self)
                if let result = sub.hitTest(subPoint, with: event) {
                    return result
                }
            }
        }
        return super.hitTest(point, with: event)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)

        if let pageContainerView = superview?.superview?.superview?.superview {
            let realPoint = pageContainerView.convert(point, to: self)
            if frame.contains(realPoint) {
                return true
            }


        }
        return inside
    }
}

class AddButton: UIButton {
    override var isSelected: Bool {
        didSet {
            let impact = UIImpactFeedbackGenerator()
            impact.impactOccurred()

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

class CreateWorkoutSectionHeaderView: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = Fonts.getScaledFont(textStyle: .subheadline, mode: .light)
        self.titleLabel.textColor = UIColor(red: 60/255.0, green: 60/255.0, blue: 224/255.0, alpha: 1.0)
    }

    func configure(title: String) {
        self.titleLabel.text = title
        self.titleLabel.adjustsFontForContentSizeCategory = true
    }
    
}
