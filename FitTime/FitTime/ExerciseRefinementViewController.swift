//
//  ExerciseRefinementViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/3/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

protocol ExerciseRefinementViewControllerDelegate: class {
    func selected(exercise: ExerciseToWorkoutBridge, for type: ExerciseIntervalType)
}

extension String {
    func trimNonNumericCharacters() -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
    }
}

class ExerciseRefinementViewController: UIViewController {

    @IBOutlet weak var rest: UITextField!
    @IBOutlet weak var exerciseTableView: UITableView!
    @IBOutlet weak var type: UISegmentedControl!
    @IBOutlet weak var seconds: UITextField!
    @IBOutlet weak var reps: UITextField!

    @IBOutlet weak var goalMachineSetting: UITextField!
    @IBOutlet weak var goalWeight: UITextField!

    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var machineSetting: UITextField!

    var exerciseIntervalType: ExerciseIntervalType = .unknown

    var existingExerciseBridge: ExerciseToWorkoutBridge?
    var selectedExercise: Exercise?

    weak var delegate:ExerciseRefinementViewControllerDelegate?

    let exercises = try! Realm().objects(Exercise.self).sorted(byKeyPath: "name")

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()

        type.setTitle(ExerciseToWorkoutBridgeType.repetition.rawValue, forSegmentAt: 0)
        type.setTitle(ExerciseToWorkoutBridgeType.time.rawValue, forSegmentAt: 1)

        if let ex = existingExerciseBridge {
            rest.text = "\(ex.rest)"
            reps.text = "\(ex.repetitions)"
            seconds.text = "\(ex.time)"
            goalMachineSetting.text = "\(ex.goalMachineSetting)"
            goalWeight.text = "\(ex.goalWeight)"
            machineSetting.text = "\(ex.machineSetting)"
            weight.text = "\(ex.weight)"

            type.selectedSegmentIndex = ex.typeEnum == .repetition ? 0 : 1

            for ex in exercises {
                if ex == existingExerciseBridge?.rootExercise {
                    selectedExercise = ex
                    exerciseTableView.reloadData()
                    break
                }
            }
        }
    }

    @IBAction func save(_ sender: UIButton) {
        guard let e = selectedExercise else { return }
        let exercise = ExerciseToWorkoutBridge()
        exercise.rootExercise = e
        exercise.name = e.name

        if let r = rest.text, let num = Int(r.trimNonNumericCharacters()) {
            exercise.rest = num
        } else {
            exercise.rest = 0
        }

        if let r = reps.text, let num = Int(r.trimNonNumericCharacters()) {
            exercise.repetitions = num
        } else {
            exercise.repetitions = 0
        }

        if let r = seconds.text, let num = Int(r.trimNonNumericCharacters()) {
            exercise.time = num
        } else {
            exercise.time = 0
        }

        if let r = goalMachineSetting.text, let num = Int(r.trimNonNumericCharacters()) {
            exercise.goalMachineSetting = num
        } else {
            exercise.goalMachineSetting = 0
        }

        if let r = goalWeight.text, let num = Int(r.trimNonNumericCharacters()) {
            exercise.goalWeight = num
        } else {
            exercise.goalWeight = 0
        }

        if let r = machineSetting.text, let num = Int(r.trimNonNumericCharacters()) {
            exercise.machineSetting = num
        } else {
            exercise.machineSetting = 0
        }

        if let r = weight.text, let num = Int(r.trimNonNumericCharacters()) {
            exercise.weight = num
        } else {
            exercise.weight = 0
        }

        exercise.typeEnum = type.selectedSegmentIndex == 0 ? .repetition : .time

        let realm = try! Realm()
        try! realm.write {
            realm.add(exercise, update: true)
        }

        delegate?.selected(exercise: exercise, for: exerciseIntervalType)
        navigationController?.popViewController(animated: true)
    }
}

extension ExerciseRefinementViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = exercises[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = exercise.name
        cell.selectionStyle = .none

        if let se = selectedExercise {
            cell.backgroundColor = se == exercise ? .red : .white
        } else {
            cell.backgroundColor = .white
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exercise = exercises[indexPath.row]

        if let se = selectedExercise{
            if exercise == se {
                selectedExercise = nil
            } else {
                selectedExercise = exercise
            }
        } else if selectedExercise == nil {
            selectedExercise = exercise
        }

        tableView.reloadData()
    }
}
