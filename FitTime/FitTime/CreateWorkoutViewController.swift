//
//  CreateWorkoutViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

class CreateWorkoutViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var cooldown: UITextField!
    @IBOutlet weak var warmup: UITextField!

    var workout: Workout?

    @IBOutlet weak var exerciseTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savedTapped))
        navigationItem.rightBarButtonItems = [save]

        exerciseTableView.isEditing = true
        exerciseTableView.allowsSelectionDuringEditing = true

        exerciseTableView.reloadData()
    }

    @objc func savedTapped() {

    }
    @IBAction func start(_ sender: Any) {

    }
}

extension CreateWorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }

        return workout?.mainExercises.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == exerciseTableView {
            return 2
        }

        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "add", for: indexPath)
            cell.textLabel?.text = "Add Exercises"
            return cell
        }

        let exercise = workout?.mainExercises[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "exercise", for: indexPath)
        cell.textLabel?.text = exercise?.name
        //cell.detailTextLabel?.text = "\(phase.interval)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == exerciseTableView {
            if indexPath.section == 0 {
                if let createVC = storyboard?.instantiateViewController(withIdentifier: "CreatePhaseViewController") as? CreatePhaseViewController {
                    //createVC.delegate = self
                    navigationController?.pushViewController(createVC, animated: true)
                }
            }
        }

        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == exerciseTableView {
            if indexPath.section == 0 {
                return false
            }

            return true
        }

        return false
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if tableView == exerciseTableView {
            if indexPath.section == 0 {
                return false
            }

            return true
        }

        return false
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if tableView == exerciseTableView {
            let exercise = workout?.mainExercises[sourceIndexPath.row]

            if let _ = exercise {
                let realm = try! Realm()
                try! realm.write {
                    workout?.mainExercises.remove(at: sourceIndexPath.row)
                    workout?.mainExercises.insert(exercise!, at: destinationIndexPath.row)
                }
            } else {
                workout?.mainExercises.remove(at: sourceIndexPath.row)
                workout?.mainExercises.insert(exercise!, at: destinationIndexPath.row)
            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == exerciseTableView {
            if editingStyle == .delete, indexPath.section == 1 {
                let index = indexPath.row

                if let _ = workout {
                    let realm = try! Realm()
                    try! realm.write {
                        workout?.mainExercises.remove(at: index)
                    }
                } else {
                    workout?.mainExercises.remove(at: index)
                }

                exerciseTableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
            }
        }
    }
}
