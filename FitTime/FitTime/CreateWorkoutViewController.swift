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

enum TimerType: Hashable {
    public var hashValue : Int {
        return self.toInt()
    }

    /// Return an 'Int' value for each `Component` type so `Component` can conform to `Hashable`
    private func toInt() -> Int {
        switch self {
        case .warmup:
            return 0
        case .cooldown:
            return 1
        case .main(_):
            return 2
        }

    }

    static func ==(lhs: TimerType, rhs: TimerType) -> Bool {
        return lhs.toInt() == rhs.toInt()
    }

    case warmup
    case main(set: Int)
    case cooldown
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

    @IBOutlet weak var addPost: UIButton!
    @IBOutlet weak var addMain: UIButton!
    @IBOutlet weak var addPre: UIButton!
    @IBOutlet weak var workoutFormat: UISegmentedControl!
    var workout: Workout?
    var workoutType: WorkoutFormat = .basic {
        didSet {
            addPre.isHidden = workoutType == .advanced
            addMain.isHidden = workoutType == .advanced
            addPost.isHidden = workoutType == .advanced

            if workoutType == .advanced {
                updateWorkout()
            } else {
                exerciseTableView.reloadData()
            }

            exerciseTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    @IBOutlet weak var sets: UITextField!
    
    var mainExercises = [ExerciseToWorkoutBridge]()
    var preExercises = [ExerciseToWorkoutBridge]()
    var postExercises = [ExerciseToWorkoutBridge]()

    var warmupTimes = [Timeable]()
    var mainTimes = [Timeable]()
    var cooldownTimes = [Timeable]()

    var temporaryWorkout = [Timeable]()
    var sections = [[Timeable]]()

    var saveButton = UIBarButtonItem()

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

        exerciseTableView.rowHeight = 44

        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savedTapped))
        saveButton.isEnabled = true
        navigationItem.rightBarButtonItems = [saveButton]

        exerciseTableView.isEditing = true
        exerciseTableView.allowsSelectionDuringEditing = true

        workoutFormat.setTitle("Edit", forSegmentAt: WorkoutFormat.basic.rawValue)
        workoutFormat.setTitle("View", forSegmentAt: WorkoutFormat.advanced.rawValue)

        workoutFormat.selectedSegmentIndex = 0

        if let w = workout {
            preExercises = Array(w.preExercises)
            mainExercises = Array(w.mainExercises)
            postExercises = Array(w.postExercises)

            name.text = w.name
            cooldown.text = "\(w.cooldown)"
            warmup.text = "\(w.warmup)"

            setRest.text = "\(w.setRest)"
            repRest.text = "\(w.repRest)"

            sets.text = "\(w.sets)"
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
        workout.sets = Int(sets.text!)!
        workout.preExercises.append(objectsIn: preExercises)
        workout.mainExercises.append(objectsIn: mainExercises)
        workout.postExercises.append(objectsIn: postExercises)

        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(workout, update: true)
            }

            saveButton.isEnabled = false
        } catch let _ as NSError {

        }

    }

    @IBAction func start(_ sender: Any) {
        updateWorkout()

        if let vc = storyboard?.instantiateViewController(withIdentifier: "OnWorkoutViewController") as? OnWorkoutViewController {
            vc.workout = workout
            vc.timerSections = sections
            present(vc, animated: true, completion: {
                self.savedTapped()
            })
        }
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
    @IBAction func textfieldChanged(_ sender: UITextField) {
        updateWorkout()
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
            return sections[section].count
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if workoutType == .basic {
            if tableView == exerciseTableView {
                return 3
            }

            return 1
        } else {
            return sections.count
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
            let ex = ExerciseTime(exercise: exercise, type: nil)

            cell.detailTextLabel?.text = "Duration: \(ex.duration)"
            cell.selectionStyle = .none
            //cell.detailTextLabel?.text = "\(phase.interval)"
        } else {
            var time = sections[indexPath.section][indexPath.row]
            cell.textLabel?.text = time.name
            cell.detailTextLabel?.text = "Duration: \(time.duration)"
            cell.selectionStyle = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
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
                var setsStr = "1"

                if let s = sets.text {
                    setsStr = s.trimNonNumericCharacters()
                }

                let count = Int(setsStr) ?? 1

                return "Exercises: \(setsStr) \(count == 1 ? "Set" : "Sets")"
            } else {
                return "Cooldown"
            }
        } else {

            if let first = sections[section].first {
                switch first.type {
                    case .cooldown:
                        return "Cooldown"
                    case .warmup:
                        return "Warmup"
                    case .main(_):
                        var warmupExists: Bool = false
                        let firstItem = sections.first

                        if let i = firstItem?.first, i.type == .warmup {
                            warmupExists = true
                        }

                        return "Set \(warmupExists ? section : section+1)"
                }
            }

            return nil
        }
    }
}

extension CreateWorkoutViewController: ExerciseRefinementViewControllerDelegate {
    func selected(exercise: ExerciseToWorkoutBridge, for type: ExerciseIntervalType) {
        func selectIn(exercises: inout [ExerciseToWorkoutBridge]) {
            var found: Bool = false

            /*
            for (idx, ex) in exercises.enumerated() {
                if ex.name == exercise.name {
                    exercises[idx] = exercise
                    found = true
                }
            }
            */

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
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
//        if newString != "" {
//            self.updateWorkout(with: newString)
//        }
//
//        if textField == sets {
//            exerciseTableView.reloadData()
//        }
//
//        return true
//    }

    func updateWorkout() {
        func createExerciseTimer(forSet set: Int = 0, type: TimerType) {
            func addExercise(ex: ExerciseToWorkoutBridge, isLast: Bool = false, type: TimerType) {
                let time = ExerciseTime(exercise: ex, type: type)
                addTimerSection(timer: time)
                temporaryWorkout.append(time)

                var restStr: String = "0"
                if !isLast {
                    restStr = repRest.text ?? "0"
                } else {
                    restStr = setRest.text ?? "0"
                }

                let r = RestTime(rest: Int(restStr) ?? 0, type: type)
                temporaryWorkout.append(r)
                addTimerSection(timer: r)
            }

            switch type {
                case .main(_):
                    for main in mainExercises {
                        addExercise(ex: main, isLast: main == mainExercises.last, type: type)
                    }
                case .warmup:
                    for main in preExercises {
                        addExercise(ex: main, isLast: main == preExercises.last, type: type)
                    }
                case .cooldown:
                    for main in postExercises {
                        addExercise(ex: main, isLast: main == postExercises.last, type: type)
                    }

            }
        }

        temporaryWorkout.removeAll()
        resetTimerSection()

        if let warm = warmup.text, warm != "" || warm != "0" {
            let w = WarmupTime(warmup: Int(warm) ?? 0)
            temporaryWorkout.append(w)
            addTimerSection(timer: w)
        }

        var sets: Int = 1

        if let setsInt = Int(self.sets.text ?? "1") {
            sets = setsInt
        }

        createExerciseTimer(type: .warmup)

        for set in 1...sets {
            createExerciseTimer(type: .main(set: 0))
        }

        createExerciseTimer(type: .cooldown)

        if let cool = cooldown.text, cool != "" || cool != "0" {
            let c = CooldownTime(cooldown: Int(cool) ?? 0)
            temporaryWorkout.append(c)
            addTimerSection(timer: c)
        }

        self.exerciseTableView.reloadData()
    }

    func addTimerSection(timer: Timeable) {
        if sections.count > 0 {
            for (idx,time) in sections.enumerated() {
                if let item = time.first, item.type == timer.type {
                    let count = time.count
                    var maxMainExerciseCount = 0
                    switch timer.type {
                        case .cooldown:
                            maxMainExerciseCount = postExercises.count * 2
                            if let c = cooldown.text, let cc = Int(c), cc > 0 {
                                maxMainExerciseCount += 1
                            }
                        case .warmup:
                            maxMainExerciseCount = preExercises.count * 2
                            if let c = warmup.text, let cc = Int(c), cc > 0 {
                                maxMainExerciseCount += 1
                            }
                        case .main(_):
                            maxMainExerciseCount = mainExercises.count * 2
                    }


                    let sectionCount = sections[idx].count

                    if timer.type == .main(set: 0), count == maxMainExerciseCount, idx == (sections.count-1) {
                        sections.append([timer])
                    } else if count < maxMainExerciseCount {
                        sections[idx].append(timer)
                    }

                } else if idx == sections.count - 1 {
                    sections.append([timer])
                }
            }
        } else {
            sections.append([timer])
        }

        /*
        for (idx, ty) in self.sections.enumerated() {
            if let item = ty.first?.key, item == type, let oldValue = self.sections[idx][type] {
                self.sections[idx][type] = oldValue + value
            }
        }
        */
    }

    func resetTimerSection() {
        self.sections.removeAll()
        self.sections.removeAll()
    }
}
