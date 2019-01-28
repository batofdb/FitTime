//
//  WorkoutsViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

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
        navigationController?.view.backgroundColor = .clear
        //navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.tintColor = .magenta
        
        view.backgroundColor = UIColor(displayP3Red: 249/255.0, green: 251/255.0, blue: 242/255.0, alpha: 1.0)

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
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreateWorkoutViewController")
        navigationController?.pushViewController(vc!, animated: true)
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
            cell.set(with: [1, 2, 3])
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
            view.titleLabel.text = "Library"
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
