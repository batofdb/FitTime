//
//  ExercisesViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

class ExercisesViewController: UIViewController {
    let exercises = try! Realm().objects(Exercise.self).sorted(byKeyPath: "name")
    var token: NotificationToken?
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .magenta
        navigationController?.navigationBar.isTranslucent = false

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems = [add]
        // Do any additional setup after loading the view.

        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true

        // Observe Realm Notifications
        token = exercises.observe { changes in
            self.tableView.reloadData()
        }
    }

    deinit {
        // later
        token?.invalidate()
    }

    @objc func addTapped() {
        if let createVC = storyboard?.instantiateViewController(withIdentifier: "CreateExerciseViewController") as? CreateExerciseViewController {
            navigationController?.pushViewController(createVC, animated: true)
        }
    }
}

extension ExercisesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, indexPath.section == 1 {
            let exercise = exercises[indexPath.row]
            let realm = try! Realm()
            try! realm.write {
                realm.delete(exercise)
            }

            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)
            cell.selectionStyle = .none
            return cell
        }

        let exercise = exercises[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = exercise.name
        cell.detailTextLabel?.text = exercise.typeEnum == .pull ? "Pull" : "Push"
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return exercises.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let createVC = storyboard?.instantiateViewController(withIdentifier: "CreateExerciseViewController") as? CreateExerciseViewController, exercises.indices.contains(indexPath.row) {
                createVC.exercise = exercises[indexPath.row]
                navigationController?.pushViewController(createVC, animated: true)
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
