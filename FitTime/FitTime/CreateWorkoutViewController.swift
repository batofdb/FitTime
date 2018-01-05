//
//  CreateWorkoutViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

enum ExerciseIntervalType: Int {
    case pre
    case main
    case post
    case unknown
}

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class CreateWorkoutViewController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var cooldown: UITextField!
    @IBOutlet weak var warmup: UITextField!

    @IBOutlet weak var repRest: UITextField!
    @IBOutlet weak var setRest: UITextField!

    var workout: Workout?

    var mainExercises = [ExerciseToWorkoutBridge]()
    var preExercises = [ExerciseToWorkoutBridge]()
    var postExercises = [ExerciseToWorkoutBridge]()

    @IBOutlet weak var exerciseTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()

        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savedTapped))
        navigationItem.rightBarButtonItems = [save]

        exerciseTableView.isEditing = true
        exerciseTableView.allowsSelectionDuringEditing = true

        if let w = workout {
            mainExercises = Array(w.mainExercises)
            name.text = w.name
            cooldown.text = "\(w.cooldown)"
            warmup.text = "\(w.warmup)"

            setRest.text = "\(w.setRest)"
            repRest.text = "\(w.repRest)"
        }

        exerciseTableView.reloadData()
    }

    @objc func savedTapped() {
        let workout = Workout()
        workout.name = name.text!
        workout.cooldown = Int(cooldown.text!)!
        workout.warmup = Int(warmup.text!)!
        workout.setRest = Int(setRest.text!)!
        workout.repRest = Int(repRest.text!)!
        workout.mainExercises.append(objectsIn: mainExercises)

        let realm = try! Realm()
        try! realm.write {
            realm.add(workout, update: true)
        }

    }

    @IBAction func start(_ sender: Any) {

    }
    @IBAction func addPreExercise(_ sender: Any) {
        newExerciseFor(type: .pre)
    }
    @IBAction func addMainExercise(_ sender: Any) {
        newExerciseFor(type: .main)
    }
    @IBAction func addPostExercise(_ sender: Any) {
        newExerciseFor(type: .post)
    }

    func newExerciseFor(type: ExerciseIntervalType) {
        if let createVC = storyboard?.instantiateViewController(withIdentifier: "ExerciseRefinementViewController") as? ExerciseRefinementViewController {
            createVC.delegate = self
            createVC.exerciseIntervalType = type
            navigationController?.pushViewController(createVC, animated: true)
        }
    }
}

extension CreateWorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return preExercises.count
        } else if section == 1 {
            return mainExercises.count
        } else {
            return postExercises.count
        }

        return mainExercises.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == exerciseTableView {
            return 3
        }

        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exercise", for: indexPath)

        var exercise = ExerciseToWorkoutBridge()
        if indexPath.section == 0 {
            exercise = preExercises[indexPath.row]
            //cell.backgroundColor = .yellow
        } else if indexPath.section == 1 {
            exercise = mainExercises[indexPath.row]
            //cell.backgroundColor = .green
        } else {
            exercise = postExercises[indexPath.row]
            //cell.backgroundColor = .blue
        }


        cell.textLabel?.text = exercise.name
        cell.selectionStyle = .none
        //cell.detailTextLabel?.text = "\(phase.interval)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == exerciseTableView {
            var arr = [ExerciseToWorkoutBridge]()
            var ex = ExerciseToWorkoutBridge()

            switch indexPath.section {
            case 0:
                arr = preExercises
                ex = preExercises[indexPath.row]
            case 2:
                arr = postExercises
                ex = postExercises[indexPath.row]
            default:
                arr = mainExercises
                ex = mainExercises[indexPath.row]
            }

            if let createVC = storyboard?.instantiateViewController(withIdentifier: "ExerciseRefinementViewController") as? ExerciseRefinementViewController {
                createVC.delegate = self
                createVC.existingExerciseBridge = ex
                navigationController?.pushViewController(createVC, animated: true)
            }
        }

        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if tableView == exerciseTableView {
//            if indexPath.section == 0 {
//                return false
//            }
//
//            return true
//        }

        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        if tableView == exerciseTableView {
//            if indexPath.section == 0 {
//                return false
//            }
//
//            return true
//        }

        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if tableView == exerciseTableView {

            var exercise = ExerciseToWorkoutBridge()
            switch sourceIndexPath.section {
                case 0:
                    exercise = preExercises[sourceIndexPath.row]
                    preExercises.remove(at: sourceIndexPath.row)
                case 2:
                    exercise = postExercises[sourceIndexPath.row]
                    postExercises.remove(at: sourceIndexPath.row)
                default:
                    exercise = mainExercises[sourceIndexPath.row]
                    mainExercises.remove(at: sourceIndexPath.row)
            }


            switch destinationIndexPath.section {
            case 0:
                preExercises.insert(exercise, at: destinationIndexPath.row)
            case 2:
                postExercises.insert(exercise, at: destinationIndexPath.row)
            default:
                mainExercises.insert(exercise, at: destinationIndexPath.row)
            }

//            if let _ = exercise {
//                let realm = try! Realm()
//                try! realm.write {
//                    workout?.mainExercises.remove(at: sourceIndexPath.row)
//                    workout?.mainExercises.insert(exercise!, at: destinationIndexPath.row)
//                }
//            } else {
//                workout?.mainExercises.remove(at: sourceIndexPath.row)
//                workout?.mainExercises.insert(exercise!, at: destinationIndexPath.row)
//            }
        }
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section == 1 && proposedDestinationIndexPath.section == 0 {
            return IndexPath(row: 0, section: 1)
        }

        return proposedDestinationIndexPath
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == exerciseTableView {
            if editingStyle == .delete {
                let index = indexPath.row

//                if let _ = workout {
//                    let realm = try! Realm()
//                    try! realm.write {
//                        workout?.mainExercises.remove(at: index)
//                    }
//                } else {
//                    workout?.mainExercises.remove(at: index)
//                }
                mainExercises.remove(at: index)
                exerciseTableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
            }

//            if editingStyle == .insert {
//                tableView.reloadRows(at: [indexPath], with: .automatic)
//            }
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Warmup"
        } else if section == 1 {
            return "Exercises"
        } else {
            return "Cooldown"
        }
    }
}

extension CreateWorkoutViewController: ExerciseRefinementViewControllerDelegate {
    func selected(exercise: ExerciseToWorkoutBridge, for type: ExerciseIntervalType) {
        func selectIn( exercises: inout [ExerciseToWorkoutBridge]) {
            var found: Bool = false

            for (idx, ex) in exercises.enumerated() {
                if ex.name == exercise.name {
                    exercises[idx] = exercise
                    found = true
                }
            }

            if !found {
                exercises.append(exercise)
            }
        }

        switch type {
        case .pre:
            selectIn(exercises: &preExercises)
        case .post:
            selectIn(exercises: &postExercises)
        default:
            selectIn(exercises: &mainExercises)
        }

        exerciseTableView.reloadData()
    }
}
