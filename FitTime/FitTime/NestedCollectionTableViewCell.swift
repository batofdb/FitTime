//
//  NestedCollectionTableViewCell.swift
//  FitTime
//
//  Created by Francis Bato on 1/26/19.
//  Copyright © 2019 LateRisers. All rights reserved.
//

import UIKit

class NestedCollectionTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    var section: Int = 0
    var datasource: [Any] = [Any]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        collectionView.register(UINib(nibName: "WorkoutNextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutNextCollectionViewCell")

        collectionView.register(UINib(nibName: "LibraryWorkoutCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LibraryWorkoutCollectionViewCell")
    }

    public func set(with items:[Any]) {
        datasource = items
        collectionView.reloadData()
    }
}

extension NestedCollectionTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryWorkoutCollectionViewCell", for: indexPath) as! LibraryWorkoutCollectionViewCell
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkoutNextCollectionViewCell", for: indexPath) as! WorkoutNextCollectionViewCell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch section {
        case 1:
            return CGSize(width: (collectionView.frame.width / 1.50) - 40.0, height: collectionView.frame.size.height - 22.0)
        default:
            return CGSize(width: collectionView.frame.width - 40.0, height: collectionView.frame.size.height - 22)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth = collectionView.frame.width - 40.0
        let inset = (collectionView.frame.width - cellWidth) / 2.0

        return UIEdgeInsetsMake(0, inset, 0, inset)
    }
}

class WorkoutNextCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var gradientView: GradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 9.0
        layer.masksToBounds = true

        gradientView.gradientLayer.colors = [UIColor(hex: "1c1b1b").cgColor, UIColor(hex: "444141").cgColor]
        gradientView.gradientLayer.gradient = GradientPoint.topLeftBottomRight.draw()
    }

}

class LibraryWorkoutsSectionHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accessoryButton: UIButton!

    @IBOutlet weak var containerView: UIView!
    @IBAction func accessoryButtonTapped(_ sender: UIButton) {

    }
}

class LibraryWorkoutCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var footLabel: UILabel!
    @IBOutlet weak var accessoryView: UIView!


    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 6.0
        layer.masksToBounds = true
    }
}

class WorkoutCollectableCollectionViewCell: UITableViewCell {
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        previewView.layer.cornerRadius = 6.0
        previewView.layer.masksToBounds = true
    }
}
