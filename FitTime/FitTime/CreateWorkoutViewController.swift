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

    var warmCount: Int = 0
    var coolCount: Int = 0

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


            exerciseTableView.setContentOffset(CGPoint.zero, animated:false)

        }
    }

    @IBOutlet weak var sets: UITextField!
    
    var mainExercises = [ExerciseToWorkoutBridge]()
    var preExercises = [ExerciseToWorkoutBridge]()
    var postExercises = [ExerciseToWorkoutBridge]()

    var exercisePhaseCount = [TimerType : Int]()
    var exerciseRepititionCount = [TimerType : Int]()

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

        resetRepsCache()

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

            if w.cooldown == 0 {
                cooldown.text = ""
            } else {
                cooldown.text = "\(w.cooldown)"
                coolCount = w.cooldown
            }


            if w.warmup == 0 {
                warmup.text = ""
            } else {
                warmup.text = "\(w.warmup)"
                warmCount = w.warmup
            }

            setRest.text = "\(w.setRest)"
            repRest.text = "\(w.repRest)"

            sets.text = "\(w.sets)"
        }

        exerciseTableView.reloadData()
    }

    func resetRepsCache() {
        exercisePhaseCount[.warmup] = 0
        exercisePhaseCount[.cooldown] = 0
        exercisePhaseCount[.main(set: 0)] = 0

        exerciseRepititionCount[.warmup] = 0
        exerciseRepititionCount[.cooldown] = 0
        exerciseRepititionCount[.main(set: 0)] = 0
    }

    @IBAction func workoutFormatChanged(_ sender: UISegmentedControl) {
        workoutType = sender.selectedSegmentIndex == 0 ? .basic : .advanced
    }

    @objc func savedTapped() {
        let workout = Workout()
        workout.name = name.text!

        if let c = cooldown.text {
            workout.cooldown = Int(c) ?? 0
        }

        if let w = warmup.text {
            workout.warmup = Int(w) ?? 0
        }


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
        if sender == warmup {
            if let w = warmup.text, let warm = Int(w), warm > 0 {
                warmCount = warm
            } else {
                warmCount = 0
            }


        }

        if sender == cooldown {
            if let c = cooldown.text, let cool = Int(c), cool > 0 {
                coolCount = cool
            } else {
                coolCount = 0
            }


        }

        updateWorkout()
        saveButton.isEnabled = true
    }
}

extension CreateWorkoutViewController {
    func typeFor(section: Int) -> ExerciseIntervalType {
        if (warmCount > 0 || preExercises.count > 0), section == 0 {
            return .pre
        } else if mainExercises.count > 0 && section == 0 {
            return .main
        } else if (warmCount > 0 || preExercises.count > 0) && mainExercises.count > 0 && section == 1 {
            return .main
        } else  if mainExercises.count <= 0 && (warmCount > 0 || preExercises.count > 0)
            && section == 1 && (coolCount > 0 || postExercises.count > 0) {
            return .post
        } else {
            return .post
        }
    }
}

extension CreateWorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if workoutType == .basic {
            switch typeFor(section: section) {
                case .pre:
                    return preExercises.count
                case .main:
                    return mainExercises.count
                case .post:
                    return postExercises.count
                default: return 0
            }
        } else {
            return sections[section].count
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if workoutType == .basic {
            if tableView == exerciseTableView {
                var count: Int = 0
                if let warm = warmup.text, let c = Int(warm), c > 0 {
                    count += 1
                } else if preExercises.count > 0 {
                    count += 1
                }

                if let cool = cooldown.text, let c = Int(cool), c > 0 {
                    count += 1
                } else if postExercises.count > 0 {
                    count += 1
                }

                if mainExercises.count > 0 {
                    count += 1
                }

                return count
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

            switch typeFor(section: indexPath.section) {
                case .pre:
                    exercise = preExercises[indexPath.row]
                case .main:
                    exercise = mainExercises[indexPath.row]
                case .post:
                    exercise = postExercises[indexPath.row]
                default:
                    return UITableViewCell()
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

                switch typeFor(section: indexPath.section) {
                case .pre:
                    ex = preExercises[indexPath.row]
                case .post:
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
                exerciseTableView.deleteRows(at: [IndexPath(row: index, section: indexPath.section)], with: .automatic)
            }

//            if editingStyle == .insert {
//                tableView.reloadRows(at: [indexPath], with: .automatic)
//            }
        }
    }

    func titleForEditView(section: Int) -> String {
        func stringForMainExercises() -> String {
            var setsStr = "1"

            if let s = sets.text {
                setsStr = s.trimNonNumericCharacters()
            }

            let count = Int(setsStr) ?? 1

            return "Exercises: \(setsStr) \(count == 1 ? "Set" : "Sets")"
        }

        switch typeFor(section: section) {
            case .pre:
                return "Warmup"
            case .main:
                return stringForMainExercises()
            case .post:
                return "Cooldown"
            default:
                return ""
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if workoutType == .basic {
            return titleForEditView(section: section)
            /*
            if section == 0, let warm = warmup.text, let c = Int(warm), c > 0 {
                return "Warmup"
            } else if section == 1 && mainExercises.count > 0 {
                var setsStr = "1"

                if let s = sets.text {
                    setsStr = s.trimNonNumericCharacters()
                }

                let count = Int(setsStr) ?? 1

                return "Exercises: \(setsStr) \(count == 1 ? "Set" : "Sets")"
            } else {
                return "Cooldown"
            }
            */
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
                var reps = [Timeable]()

                let time = ExerciseTime(exercise: ex, type: type)
                addTimerSection(timer: time, type: type)
                temporaryWorkout.append(time)

                var restStr: String = "0"
                if !isLast {
                    restStr = repRest.text ?? "0"
                } else {
                    restStr = setRest.text ?? "0"
                }

                let r = RestTime(rest: Int(restStr) ?? 0, type: type)
                temporaryWorkout.append(r)
                addTimerSection(timer: r, type: type)
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

        for pre in preExercises {
            if pre.typeEnum == .repetition {
                if let num = exercisePhaseCount[.warmup] {
                    exercisePhaseCount[.warmup] = num + (pre.repetitions * (pre.rootExercise?.phases.count ?? 0))
                } else {
                    exercisePhaseCount[.warmup] = pre.repetitions * (pre.rootExercise?.phases.count ?? 0)
                }

                if let num = exerciseRepititionCount[.warmup] {
                    exerciseRepititionCount[.warmup] = num + 1
                } else {
                    exerciseRepititionCount[.warmup] = 1
                }
            }
        }

        for main in mainExercises {
            if main.typeEnum == .repetition {
                if let num = exercisePhaseCount[.main(set: 0)] {
                    exercisePhaseCount[.main(set: 0)] = num + (main.repetitions * (main.rootExercise?.phases.count ?? 0))
                } else {
                    exercisePhaseCount[.main(set: 0)] = main.repetitions * (main.rootExercise?.phases.count ?? 0)
                }

                if let num = exerciseRepititionCount[.main(set: 0)] {
                    exerciseRepititionCount[.main(set: 0)] = num + 1
                } else {
                    exerciseRepititionCount[.main(set: 0)] = 1
                }
            }
        }

        for post in postExercises {
            if post.typeEnum == .repetition {
                if let num = exercisePhaseCount[.cooldown] {
                    exercisePhaseCount[.cooldown] = num + (post.repetitions * (post.rootExercise?.phases.count ?? 0))
                } else {
                    exercisePhaseCount[.cooldown] = post.repetitions * (post.rootExercise?.phases.count ?? 0)
                }

                if let num = exerciseRepititionCount[.cooldown] {
                    exerciseRepititionCount[.cooldown] = num + 1
                } else {
                    exerciseRepititionCount[.cooldown] = 1
                }
            }
        }

        if let warm = warmup.text, warm != "" && warm != "0" {
            let w = WarmupTime(warmup: Int(warm) ?? 0)
            temporaryWorkout.append(w)
            addTimerSection(timer: w, type: .warmup)
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

        if let cool = cooldown.text, cool != "" && cool != "0" {
            let c = CooldownTime(cooldown: Int(cool) ?? 0)
            temporaryWorkout.append(c)
            addTimerSection(timer: c, type: .cooldown)
        }

        self.exerciseTableView.reloadData()
    }

    func addTimerSection(timer: Timeable, type: TimerType) {
        func extractExerciseReps(timer: Timeable) -> [Timeable] {
            var phases = [Timeable]()
            guard let timerPhases = timer.phases, let exercise = timer as? ExerciseTime else { return [Timeable]() }

            phases.append(IntroPhaseTime(exercise: exercise, type: type))

            for _ in 1...timer.reps {
                for ph in timerPhases {
                    phases.append(PhaseTime(exercise: exercise, phase: ph, type: type))
                }
            }

            return phases
        }

        func appendToCurrentTimerSection(timer: Timeable, at index: Int) {
            if timer.repType == .repetition {
                let phases = extractExerciseReps(timer: timer)
                sections[index].append(contentsOf: phases)
            } else {
                sections[index].append(timer)
            }
        }

        func startNewTimerSection(timer: Timeable) {
            if timer.repType == .repetition {
                let phases = extractExerciseReps(timer: timer)
                sections.append(phases)
            } else {
                sections.append([timer])
            }
        }

        func calculateMaxCountFor(type: TimerType) -> Int {
            switch type {
                case .warmup:
                    let durationCount = preExercises.count - (exerciseRepititionCount[.warmup] ?? 0)
                    let totalDuration = durationCount * 2

                    let phaseCount = (exercisePhaseCount[.warmup] ?? 0) * 2
                    let restCount = exerciseRepititionCount[.warmup] ?? 0

                    let introCount = exerciseRepititionCount[.warmup] ?? 0

                    return totalDuration + phaseCount + restCount + introCount
                case .cooldown:
                    let durationCount = postExercises.count - (exerciseRepititionCount[.cooldown] ?? 0)
                    let totalDuration = durationCount * 2

                    let phaseCount = (exercisePhaseCount[.cooldown] ?? 0)
                    let restCount = exerciseRepititionCount[.cooldown] ?? 0
                    let introCount = exerciseRepititionCount[.cooldown] ?? 0

                    return totalDuration + phaseCount + restCount + introCount
                case .main(_):
                    let durationCount = mainExercises.count - (exerciseRepititionCount[.main(set: 0)] ?? 0)
                    let totalDuration = durationCount * 2

                    let phaseCount = (exercisePhaseCount[.main(set: 0)] ?? 0)
                    let restCount = exerciseRepititionCount[.main(set: 0)] ?? 0
                    let introCount = exerciseRepititionCount[.main(set: 0)] ?? 0

                    return totalDuration + phaseCount + restCount + introCount
            }
        }

        if sections.count > 0 {
            for (idx,time) in sections.enumerated() {
                if let item = time.first, item.type == timer.type {
                    let count = time.count
                    var maxMainExerciseCount = 0
                    switch timer.type {
                        case .cooldown:
                            maxMainExerciseCount = calculateMaxCountFor(type: .cooldown)
                            if let c = cooldown.text, let cc = Int(c), cc > 0 {
                                maxMainExerciseCount += 1
                            }
                        case .warmup:
                            maxMainExerciseCount = calculateMaxCountFor(type: .warmup)
                            if let c = warmup.text, let cc = Int(c), cc > 0 {
                                maxMainExerciseCount += 1
                            }
                        case .main(_):
                            maxMainExerciseCount = calculateMaxCountFor(type: .main(set: 0))
                    }


                    let sectionCount = sections[idx].count

                    if timer.type == .main(set: 0), count == maxMainExerciseCount, idx == (sections.count-1) {
                        startNewTimerSection(timer: timer)
                    } else if count < maxMainExerciseCount {
                        appendToCurrentTimerSection(timer: timer, at: idx)
                    }

                } else if idx == sections.count - 1 {
                    startNewTimerSection(timer: timer)
                }
            }
        } else {
            startNewTimerSection(timer: timer)
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
        resetRepsCache()
    }
}
