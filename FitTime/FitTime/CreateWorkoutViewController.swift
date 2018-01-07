//
//  CreateWorkoutViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

enum WorkoutFormat: Int {
    case basic = 0
    case advanced
}

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

    @IBOutlet weak var workoutFormat: UISegmentedControl!
    var workout: Workout?
    var workoutType: WorkoutFormat = .basic {
        didSet {
            if workoutType == .advanced {
                updateWorkout(with: self.sets.text ?? "1")
            } else {
                exerciseTableView.reloadData()
            }
        }
    }

    @IBOutlet weak var sets: UITextField!
    
    var mainExercises = [ExerciseToWorkoutBridge]()
    var preExercises = [ExerciseToWorkoutBridge]()
    var postExercises = [ExerciseToWorkoutBridge]()

    var temporaryWorkout = [ExerciseTime]()

    @IBOutlet weak var exerciseTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()

        cooldown.delegate = self
        warmup.delegate = self
        repRest.delegate = self
        setRest.delegate = self
        sets.delegate = self
        

        sets.text = "1"

        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savedTapped))
        navigationItem.rightBarButtonItems = [save]

        exerciseTableView.isEditing = true
        exerciseTableView.allowsSelectionDuringEditing = true

        workoutFormat.setTitle("Basic", forSegmentAt: WorkoutFormat.basic.rawValue)
        workoutFormat.setTitle("Advanced", forSegmentAt: WorkoutFormat.advanced.rawValue)

        workoutFormat.selectedSegmentIndex = 0

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

    @IBAction func workoutFormatChanged(_ sender: UISegmentedControl) {
        workoutType = sender.selectedSegmentIndex == 0 ? .basic : .advanced
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
        if workoutType == .basic {
            if section == 0 {
                return preExercises.count
            } else if section == 1 {
                return mainExercises.count
            } else {
                return postExercises.count
            }

            return mainExercises.count
        } else {
            return temporaryWorkout.count
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if workoutType == .basic {
            if tableView == exerciseTableView {
                return 3
            }

            return 1
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exercise", for: indexPath)

        if workoutType == .basic  {
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
            let ex = ExerciseTime(exercise: exercise)
            cell.detailTextLabel?.text = "Duration: \(ex.duration)"
            cell.selectionStyle = .none
            //cell.detailTextLabel?.text = "\(phase.interval)"
        } else {
            var time = temporaryWorkout[indexPath.row]
            cell.textLabel?.text = time.name
            cell.detailTextLabel?.text = "Duration: \(time.duration)"
            cell.selectionStyle = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if workoutType == .basic {
            if tableView == exerciseTableView {
                var ex = ExerciseToWorkoutBridge()

                switch indexPath.section {
                case 0:
                    ex = preExercises[indexPath.row]
                case 2:
                    ex = postExercises[indexPath.row]
                default:
                    ex = mainExercises[indexPath.row]
                }

                if let createVC = storyboard?.instantiateViewController(withIdentifier: "ExerciseRefinementViewController") as? ExerciseRefinementViewController {
                    createVC.delegate = self
                    createVC.existingExerciseBridge = ex

                    switch indexPath.section {
                    case 0:
                        createVC.exerciseIntervalType = .pre
                    case 2:
                        createVC.exerciseIntervalType = .post
                    default:
                        createVC.exerciseIntervalType = .main
                    }

                    navigationController?.pushViewController(createVC, animated: true)
                }
            }

            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if workoutType == .basic {
    //        if tableView == exerciseTableView {
    //            if indexPath.section == 0 {
    //                return false
    //            }
    //
    //            return true
    //        }

            return true
        }

        return false
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if workoutType == .basic {
    //        if tableView == exerciseTableView {
    //            if indexPath.section == 0 {
    //                return false
    //            }
    //
    //            return true
    //        }

            return true
        }

        return false
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
        if workoutType == .basic {
            if sourceIndexPath.section == 1 && proposedDestinationIndexPath.section == 0 {
                return IndexPath(row: 0, section: 1)
            }
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
        if workoutType == .basic {
            if section == 0 {
                return "Warmup"
            } else if section == 1 {
                return "Exercises"
            } else {
                return "Cooldown"
            }
        } else {
            return nil
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

extension CreateWorkoutViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        if newString != "" {
            updateWorkout(with: newString)
        }

        return true
    }

    func updateWorkout(with setsString: String) {
        func createExerciseSet() {
            for main in preExercises {
                let time = ExerciseTime(exercise: main)
                temporaryWorkout.append(time)
            }

            for main in mainExercises {
                let time = ExerciseTime(exercise: main)
                temporaryWorkout.append(time)
            }

            for main in postExercises {
                let time = ExerciseTime(exercise: main)
                temporaryWorkout.append(time)
            }
        }

        temporaryWorkout.removeAll()

        var sets: Int = 1

        if let setsInt = Int(setsString) {
            sets = setsInt
        }

        for _ in 1...sets {
            createExerciseSet()
        }

        exerciseTableView.reloadData()
    }
}
