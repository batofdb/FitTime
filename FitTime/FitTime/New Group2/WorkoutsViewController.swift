//
//  WorkoutsViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

extension UIColor {
    convenience init(_ hex: UInt) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

typealias GradientType = (x: CGPoint, y: CGPoint)

enum GradientPoint {
    case leftRight
    case rightLeft
    case topBottom
    case bottomTop
    case topLeftBottomRight
    case bottomRightTopLeft
    case topRightBottomLeft
    case bottomLeftTopRight

    func draw() -> GradientType {
        switch self {
        case .leftRight:
            return (x: CGPoint(x: 0, y: 0.5), y: CGPoint(x: 1, y: 0.5))
        case .rightLeft:
            return (x: CGPoint(x: 1, y: 0.5), y: CGPoint(x: 0, y: 0.5))
        case .topBottom:
            return (x: CGPoint(x: 0.5, y: 0), y: CGPoint(x: 0.5, y: 1))
        case .bottomTop:
            return (x: CGPoint(x: 0.5, y: 1), y: CGPoint(x: 0.5, y: 0))
        case .topLeftBottomRight:
            return (x: CGPoint(x: 0, y: 0), y: CGPoint(x: 1, y: 1))
        case .bottomRightTopLeft:
            return (x: CGPoint(x: 1, y: 1), y: CGPoint(x: 0, y: 0))
        case .topRightBottomLeft:
            return (x: CGPoint(x: 1, y: 0), y: CGPoint(x: 0, y: 1))
        case .bottomLeftTopRight:
            return (x: CGPoint(x: 0, y: 1), y: CGPoint(x: 1, y: 0))
        }
    }
}

class GradientLayer : CAGradientLayer {
    var gradient: GradientType? {
        didSet {
            startPoint = gradient?.x ?? CGPoint.zero
            endPoint = gradient?.y ?? CGPoint.zero
        }
    }
}

class GradientView: UIView {
    override public class var layerClass: Swift.AnyClass {
        get {
            return GradientLayer.self
        }
    }
}

extension UIView: GradientViewProvider {
    typealias GradientViewType = GradientLayer
}

protocol GradientViewProvider {
    associatedtype GradientViewType
}

extension GradientViewProvider where Self: UIView {
    var gradientLayer: Self.GradientViewType {
        return layer as! Self.GradientViewType
    }
}



struct ThemeProvider {
    static let PrimaryColor: UIColor = UIColor(red: 80/255.0, green: 99/255.0, blue: 238/255.0, alpha: 1.0)
    static let HighlightColor: UIColor = .white
    static let TitleTextColor: UIColor = .black
    static let SubTitleTextColor: UIColor = .lightGray
    static func gradientForWorkoutNow(for bounds: CGRect) -> CAGradientLayer {
        let grad = CAGradientLayer()
        return grad
    }

}

class WorkoutsViewController: UIViewController {
    let workouts = try! Realm().objects(Workout.self).sorted(byKeyPath: "name")
    var token: NotificationToken?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray
        tableView.register(UINib(nibName: "NestedCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "NestedCollectionTableViewCell")

        tableView.register(UINib(nibName: "LibraryWorkoutsSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "LibraryWorkoutsSectionHeader")

        tableView.register(UINib(nibName: "WorkoutCollectableCollectionViewCell", bundle: nil), forCellReuseIdentifier: "WorkoutCollectableCollectionViewCell")

        tableView.contentInset = UIEdgeInsetsMake(8.0, 0, 0, 0)

        self.title = "Workouts"

        //navigationController?.delegate = self


        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true

        //navigationController?.view.backgroundColor = UIColor(red: 249/255.0, green: 251/255.0, blue: 242/255.0, alpha: 1.0)

        //navigationController?.navigationBar.barTintColor = UIColor(red: 249/255.0, green: 251/255.0, blue: 242/255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = .magenta
        
        view.backgroundColor = ThemeProvider.PrimaryColor
        tableView.backgroundColor = ThemeProvider.PrimaryColor

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems = [add]

//        tableView.isEditing = true
//        tableView.allowsSelectionDuringEditing = true

        // Observe Realm Notifications
        token = workouts.observe { changes in
            self.tableView.reloadData()
        }
    }

    deinit {
        // later
        token?.invalidate()
    }

    @objc func addTapped() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreateWorkoutViewController") as! CreateWorkoutViewController
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
        //navigationController?.pushViewController(vc!, animated: true)
    }
}

extension WorkoutsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCollectableCollectionViewCell", for: indexPath) as! WorkoutCollectableCollectionViewCell
            cell.titleLabel.text = "Push workout"
            cell.subtitleLabel.text = "Circuit training focused on push exercises and cardio."
            return cell
        }


        let cell = tableView.dequeueReusableCell(withIdentifier: "NestedCollectionTableViewCell", for: indexPath) as! NestedCollectionTableViewCell
        cell.section = indexPath.section
        if indexPath.section == 0 {
            cell.set(with: [1])
        } else {
            cell.set(with: [1, 2, 3, 4, 5, 6])
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            return 3
        default:
            return 1
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.section == 0 {
//            return false
//        }
//
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete, indexPath.section == 1 {
//            let workout = workouts[indexPath.row]
//            let realm = try! Realm()
//            try! realm.write {
//                realm.delete(workout)
//            }
//
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 228.0
        case 1:
            return 175.0
        case 2:
            return 80.0
        default:
            return UIScreen.main.bounds.height / 2.5
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let createVC = storyboard?.instantiateViewController(withIdentifier: "CreateWorkoutViewController") as? CreateWorkoutViewController, workouts.indices.contains(indexPath.row) {
                createVC.workout = workouts[indexPath.row]
                navigationController?.pushViewController(createVC, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        case 1:
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LibraryWorkoutsSectionHeader") as! LibraryWorkoutsSectionHeader
            view.titleLabel.text = "Recent"
            view.contentView.backgroundColor = .clear
            return view
        case 2:
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LibraryWorkoutsSectionHeader") as! LibraryWorkoutsSectionHeader
            view.titleLabel.text = "Collection"
            view.contentView.backgroundColor = .white
            return view
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 35.0
        case 2:
            return 44.0
        default:
            return 0.0
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        default:
            return 20.0
        }
    }
}




class MyWorkoutsViewController: NavigationBaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationHeight(constant: 140)
        navigationView.update(type: .basic2Buttons)
        navigationView.gradientLayer.removeFromSuperlayer()
        navigationView.titleLabel.textColor = .black
        navigationView.leftButton.setImage(UIImage(named: "back_button"), for: .normal)
        navigationView.rightButton.setTitle("Edit", for: .normal)
        navigationView.rightButton.setTitleColor(ThemeProvider.PrimaryColor, for: .normal)
        navigationView.rightButton2.setTitleColor(ThemeProvider.PrimaryColor, for: .normal)
        navigationView.rightButton2.setTitle("Create", for: .normal)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsetsMake((140 + 16), 0, 0, 0)
        collectionView.register(UINib(nibName: "MyWorkoutCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyWorkoutCollectionViewCell")
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 24 - 24, height: ((collectionView.frame.height - 140 - 64)/2) - 16-12)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWorkoutCollectionViewCell", for: indexPath)
        return cell
    }
}


class NavigationBaseViewController: UIViewController {
    var navigationView: FitTimeNavigationBar = {
        let nav = FitTimeNavigationBar()
        nav.translatesAutoresizingMaskIntoConstraints = false
        nav.backgroundColor = .white
        nav.subTitleLabel.isHidden = true
        nav.update(type: .basic)
        return nav
    }()

    var navigationHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(navigationView)

        navigationView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navigationView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationHeightConstraint = navigationView.heightAnchor.constraint(equalToConstant: 253)
        navigationHeightConstraint.isActive = true

        
    }

    public func setNavigationHeight(constant: CGFloat) {
        navigationHeightConstraint.constant = constant
    }
}

class MyWorkoutCollectionViewCell: UICollectionViewCell {


    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
