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
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .magenta
        
        navigationController?.navigationBar.isTranslucent = false

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems = [add]

        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true

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
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)
            cell.selectionStyle = .none
            return cell
        }

        let workout = workouts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = workout.name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }

        return workouts.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }

        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, indexPath.section == 1 {
            let workout = workouts[indexPath.row]
            let realm = try! Realm()
            try! realm.write {
                realm.delete(workout)
            }

            tableView.deleteRows(at: [indexPath], with: .automatic)
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
}
