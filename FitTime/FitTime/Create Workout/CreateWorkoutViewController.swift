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

class CreateWorkoutViewController: UIViewController, AnimatableNavigationBar {
    var navigationHeightConstraint: NSLayoutConstraint?
    var navigationView: FitTimeNavigationBar = FitTimeNavigationBar()
    var searchButton: UIButton = UIButton()

    @IBOutlet weak var containerView: PagingContainerView!
    @IBOutlet weak var parentScrollView: OutsideScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var exerciseCollectionWidth: NSLayoutConstraint!
    @IBOutlet weak var selectedExerciseCollectionViewWidth: NSLayoutConstraint!
    @IBOutlet weak var selectedExercisesCollectionView: OutsideCollectionView!
    
    @IBOutlet weak var name: UITextField!

    var warmCount: Int = 0
    var coolCount: Int = 0

    @IBOutlet weak var cooldown: UITextField!
    @IBOutlet weak var warmup: UITextField!

    @IBOutlet weak var repRest: UITextField!
    @IBOutlet weak var setRest: UITextField!

    var timerQueue = [Timeable]()

    var parentScrollViewWidth: NSLayoutConstraint!
    var exerciseCollectionViewWidth: NSLayoutConstraint!
    var scrollIndicatorTopOffsetConstraint: NSLayoutConstraint?
    var scrollIndicatorHeight: NSLayoutConstraint?

    var scrollIndicator: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(displayP3Red: 35/255.0, green: 37/255.0, blue: 58/255.0, alpha: 1.0)
        v.layer.cornerRadius = 2.0
        return v
    }()

    @IBOutlet weak var scrollIndicatorContainerView: UIView!
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

    let pagingProportion: CGFloat = 0.80
    let cellHeight: CGFloat = 139.0

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

    @IBOutlet weak var exerciseCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        hideKeyboard()
        parentScrollView.contentInset = .zero
        //selectedExerciseCollectionViewWidth.constant = UIScreen.main.bounds.width * 1.15
        //contentViewWidth.constant = UIScreen.main.bounds.width * (2.0 - 0.15)

        parentScrollViewWidth = parentScrollView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: pagingProportion)
        parentScrollViewWidth.isActive = true

        exerciseCollectionWidth = exerciseCollectionView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: pagingProportion)
        exerciseCollectionWidth.isActive = true



        if #available(iOS 11.0, *) {
            exerciseCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }

        var bottomInset: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            //let topPadding = window?.safeAreaInsets.top
            if let b = window?.safeAreaInsets.bottom {
                bottomInset = b
            }
        }

        selectedExercisesCollectionView.clipsToBounds = false

        exerciseCollectionView.contentInset = UIEdgeInsetsMake(FitTimeNavigationBar.InitialHeight, 0, bottomInset, 0)
        exerciseCollectionView.contentInsetAdjustmentBehavior = .never

        selectedExercisesCollectionView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0)
        selectedExercisesCollectionView.contentInsetAdjustmentBehavior = .never

        addNavigationView()

        scrollIndicatorContainerView.topAnchor.constraint(equalTo: navigationView.bottomAnchor).isActive = true
        scrollIndicatorContainerView.addSubview(scrollIndicator)
        scrollIndicator.leftAnchor.constraint(equalTo: scrollIndicatorContainerView.leftAnchor).isActive = true
        scrollIndicator.rightAnchor.constraint(equalTo: scrollIndicatorContainerView.rightAnchor).isActive = true
        scrollIndicatorTopOffsetConstraint = scrollIndicator.topAnchor.constraint(equalTo: scrollIndicatorContainerView.topAnchor)
        scrollIndicatorTopOffsetConstraint?.isActive = true

        scrollIndicatorHeight = scrollIndicator.heightAnchor.constraint(equalToConstant: 0)
        scrollIndicatorHeight?.isActive = true

        selectedExercisesCollectionView.topAnchor.constraint(equalTo: navigationView.bottomAnchor).isActive = true

        navigationView.leftButtonTappedHandler = { [weak self] in
            //self?.navigationController?.popViewController(animated: true)
            self?.dismiss(animated: true, completion: nil)
        }

        navigationView.rightButtonTappedHandler = { [weak self] in
            let vc = AddSetComplicationViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }

        let muscles = FilterDatasource(title: "Muscle group", datasource: [FilterObject(title: "Abs"), FilterObject(title: "Back"), FilterObject(title: "Biceps"), FilterObject(title: "Calves"),
            FilterObject(title: "Chest"),
            FilterObject(title: "Forearms"),
            FilterObject(title: "Glutes"),
            FilterObject(title: "Hamstrings"),
            FilterObject(title: "Neck"),
            FilterObject(title: "Quadriceps"),
            FilterObject(title: "Shoulders"),
            FilterObject(title: "Trapezius"),
            FilterObject(title: "Triceps")])

        let equipment = FilterDatasource(title: "Equipment Type", datasource: [FilterObject(title: "Barbell"), FilterObject(title: "Dumbbell"), FilterObject(title: "Cable"), FilterObject(title: "Bodyweight"), FilterObject(title: "Hammer"), FilterObject(title: "TRX"), FilterObject(title: "Kettlebell")])

        navigationView.filterButtonTappedHandler = { [weak self] in
            let v = FilterViewController(datasource: [muscles, equipment])
            self?.present(v, animated: true, completion: nil)
        }

        resetRepsCache()

//        cooldown.delegate = self
//        warmup.delegate = self
//        repRest.delegate = self
//        setRest.delegate = self
//        sets.delegate = self
//
//
//        sets.text = "1"

//        exerciseTableView.rowHeight = 44

        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savedTapped))
        saveButton.isEnabled = true
        navigationItem.rightBarButtonItems = [saveButton]

//        exerciseTableView.isEditing = true
//        exerciseTableView.allowsSelectionDuringEditing = true

//        workoutFormat.setTitle("Edit", forSegmentAt: WorkoutFormat.basic.rawValue)
//        workoutFormat.setTitle("View", forSegmentAt: WorkoutFormat.advanced.rawValue)

//        workoutFormat.selectedSegmentIndex = 0

        if let w = workout {
            preExercises = Array(w.preExercises)
            mainExercises = Array(w.mainExercises)
            postExercises = Array(w.postExercises)

//            name.text = w.name

            if w.cooldown == 0 {
//                cooldown.text = ""
            } else {
//                cooldown.text = "\(w.cooldown)"
                coolCount = w.cooldown
            }


            if w.warmup == 0 {
//                warmup.text = ""
            } else {
//                warmup.text = "\(w.warmup)"
                warmCount = w.warmup
            }

//            setRest.text = "\(w.setRest)"
//            repRest.text = "\(w.repRest)"
//
//            sets.text = "\(w.sets)"
        }

        exerciseCollectionView.register(UINib(nibName: "CreateWorkoutExerciseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CreateWorkoutExerciseCollectionViewCell")
        exerciseCollectionView.register(UINib(nibName: "CreateWorkoutSectionHeaderView", bundle: nil), forCellWithReuseIdentifier: "CreateWorkoutSectionHeaderView")


        selectedExercisesCollectionView.register(UINib(nibName: "CreateWorkoutExerciseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CreateWorkoutExerciseCollectionViewCell")
        selectedExercisesCollectionView.register(UINib(nibName: "CreateWorkoutSectionHeaderView", bundle: nil), forCellWithReuseIdentifier: "CreateWorkoutSectionHeaderView")
        exerciseCollectionView.reloadData()

        let contentSize = exerciseCollectionView.collectionViewLayout.collectionViewContentSize.height
        let frame = exerciseCollectionView.frame.height - FitTimeNavigationBar.InitialHeight
        if contentSize > 0 {
            scrollIndicatorHeight?.constant = (frame / contentSize) * frame
        }

        let height = scrollIndicatorContainerView.frame.height
        var hind: CGFloat = 0
        if let h = scrollIndicatorHeight?.constant {
            hind = h
        }
        let maxDistance = height - hind - 5
        scrollIndicatorTopOffsetConstraint?.constant = min(5.0 + FitTimeNavigationBar.InitialHeight + exerciseCollectionView.contentOffset.y, maxDistance)

        //scrollIndicatorTopOffsetConstraint?.constant = FitTimeNavigationBar.InitialHeight + 5.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func addNavigationView() {
        navigationView.backgroundColor = .black
        navigationView.update(type: .filter)
        view.addSubview(navigationView)

        navigationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        navigationView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        navigationView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        navigationHeightConstraint = navigationView.heightAnchor.constraint(equalToConstant: FitTimeNavigationBar.InitialHeight)
        navigationHeightConstraint?.isActive = true
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

        if let vc = storyboard?.instantiateViewController(withIdentifier: "OnWorkoutViewController") as? OnWorkoutViewController, !timerQueue.isEmpty {
            vc.workout = workout
            vc.timerQueue = timerQueue
            vc.timerSections = sections
            let nvc = UINavigationController(rootViewController: vc)
            present(nvc, animated: true, completion: {
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

extension CreateWorkoutViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            if collectionView == selectedExercisesCollectionView {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateWorkoutSectionHeaderView", for: indexPath) as! CreateWorkoutSectionHeaderView
                cell.titleLabel.text = "Selected".uppercased()
                return cell

            }

            if collectionView == exerciseCollectionView {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateWorkoutSectionHeaderView", for: indexPath) as! CreateWorkoutSectionHeaderView
                cell.titleLabel.text = "Library".uppercased()
                return cell
            }

        }


        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateWorkoutExerciseCollectionViewCell", for: indexPath) as! CreateWorkoutExerciseCollectionViewCell
        cell.titleLabel.text = "Bench Press"
        cell.frame = CGRect(x: 0, y: cell.frame.origin.y, width: cell.frame.width, height: cell.frame.height)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 + 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {


        if indexPath.row == 0 {
            return CGSize(width: collectionView.frame.width, height: 50)
        }

        if collectionView == selectedExercisesCollectionView {
            return CGSize(width: UIScreen.main.bounds.width, height: cellHeight)
        }

        return CGSize(width:collectionView.frame.width, height: cellHeight)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == exerciseCollectionView {
            var indicatorHeight: CGFloat = 0
            if let h = scrollIndicatorHeight?.constant {
                indicatorHeight = h
            }
            let maxDistance = scrollIndicatorContainerView.frame.height - indicatorHeight - 5
            let height = scrollIndicatorContainerView.frame.height - indicatorHeight - 5
            let realOffset = scrollView.contentOffset.y + navigationView.frame.height
            let num = (realOffset * height)
            var offset: CGFloat = 0.0
            if num != 0 {
                offset = num / (exerciseCollectionView.contentInset.top + (exerciseCollectionView.contentSize.height - exerciseCollectionView.frame.height) - exerciseCollectionView.contentInset.bottom)
            }

            scrollIndicatorTopOffsetConstraint?.constant = min(5.0 + offset, maxDistance)
            updateNavigationHeight(with: scrollView.contentOffset.y)
        } else if scrollView == parentScrollView {
            if scrollView.contentOffset.y > 0 {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            }

            let xLimit: CGFloat = scrollView.frame.width
            if scrollView.contentOffset.x > xLimit {
                scrollView.contentOffset = CGPoint(x: xLimit, y: 0)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let vc = UIStoryboard(name: "Exercise", bundle: nil).instantiateViewController(withIdentifier: "ExerciseDetailViewController") as! ExerciseDetailViewController
        present(vc, animated: true) {

        }
    }
}

/*
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
*/
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

        timerQueue.append(timer)
        /*
        for (idx, ty) in self.sections.enumerated() {
            if let item = ty.first?.key, item == type, let oldValue = self.sections[idx][type] {
                self.sections[idx][type] = oldValue + value
            }
        }
        */
    }

    func resetTimerSection() {
        sections.removeAll()
        resetRepsCache()
        timerQueue.removeAll()
    }
}

protocol AnimatableNavigationBar {
    var navigationView: FitTimeNavigationBar { get set }
    var navigationHeightConstraint: NSLayoutConstraint? { get set }
    func addNavigationView()
}

extension AnimatableNavigationBar where Self: UIViewController {
    func updateNavigationHeight(with offset: CGFloat) {
        guard let currentHeight = navigationHeightConstraint?.constant else { return }
        let distance = FitTimeNavigationBar.InitialHeight - FitTimeNavigationBar.EndHeight
        let currentDistance = offset + FitTimeNavigationBar.InitialHeight
        navigationHeightConstraint?.constant = min(max(FitTimeNavigationBar.InitialHeight - currentDistance, FitTimeNavigationBar.EndHeight), FitTimeNavigationBar.InitialHeight)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if let h = navigationHeightConstraint {
            navigationView.gradientLayer.frame = CGRect(x: navigationView.frame.origin.x, y: navigationView.frame.origin.y, width: navigationView.frame.width, height: h.constant)
        }
        CATransaction.commit()

        let primaryTitleDistance: CGFloat = 40.0
        if offset > -(FitTimeNavigationBar.EndHeight) {
            //Top
            navigationView.titleLabelToTop.constant = 0
            //navigationView.titleLabelLeading.constant = navigationView.leftButtonWidth.constant + 15.0
            navigationView.subtitleLabelToTop.constant = 0
            navigationView.subTitleLabel.alpha = 0
            navigationView.titleLabel.transform = CGAffineTransform(scaleX: 0.75, y: 0.75).translatedBy(x: -15, y: -5)

        } else if offset > -(FitTimeNavigationBar.InitialHeight) && offset <= -(FitTimeNavigationBar.EndHeight) {
            // Animating
            let pct = min(1 - (currentDistance / (FitTimeNavigationBar.InitialHeight - FitTimeNavigationBar.EndHeight)), 1.0)
            let leadingPct = min(currentDistance / (FitTimeNavigationBar.InitialHeight - FitTimeNavigationBar.EndHeight), 1.0)
            let offset = navigationView.leftButtonHeight.constant + 15.0
            let leadingOffset = navigationView.leftButtonWidth.constant + 15.0
            navigationView.titleLabelToTop.constant = pct * offset
            //navigationView.titleLabelLeading.constant = leadingPct * leadingOffset
            let distanceToGo: CGFloat = 10.0
            let distanceToAlpha: CGFloat = 20.0
            let distanceToScale: CGFloat = 90.0
            let distanceToTrans: CGFloat = 70.0
            let dPct = currentDistance / distanceToAlpha
            let aPct = 1 - (currentDistance / distanceToAlpha)

            let sPct = currentDistance / distanceToScale
            let tPct = currentDistance / distanceToTrans
            let transY = min(max(tPct * -5, -5),0)
            let transX = min(max(tPct * -15, -15),0)

            let scale = min(max(1 - (0.35 * sPct), 0.75), 1.0)
            navigationView.titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: transX, y: transY)



            navigationView.subtitleLabelToTop.constant = 10 - (distanceToGo * dPct)
            navigationView.subTitleLabel.alpha = max(min(aPct, 1.0), 0.0)
        } else {
            //Bottom
            navigationView.titleLabel.transform = CGAffineTransform(scaleX: 1, y: 1).translatedBy(x: 0, y: 0)
            navigationView.subTitleLabel.alpha = 1.0
            navigationView.titleLabelToTop.constant = navigationView.leftButtonHeight.constant + 15.0
            //navigationView.titleLabelLeading.constant = 0
            navigationView.subtitleLabelToTop.constant = 10
        }
    }
}

class FitTimeNavigationBar: UIView {
    enum Configuration {
        case basic
        case filter
        case sets
    }

    static let InitialHeight: CGFloat = 220
    static let EndHeight: CGFloat = 150

    weak var heightConstraint: NSLayoutConstraint?
    var leftButtonTappedHandler: (()->Void)? = nil
    var rightButtonTappedHandler: (()->Void)? = nil
    var filterButtonTappedHandler: (()->Void)? = nil

    var titleLabelToTop: NSLayoutConstraint!
    var subtitleLabelToTop: NSLayoutConstraint!
    var subtitleLabelLeading: NSLayoutConstraint!
    var titleLabelLeading: NSLayoutConstraint!
    var primaryTitleHeight: NSLayoutConstraint!
    var subtitleHeight: NSLayoutConstraint!
    var searchBarHeight: NSLayoutConstraint!
    var leftButtonHeight: NSLayoutConstraint!
    var leftButtonWidth: NSLayoutConstraint!

    var type: Configuration

    var titleLabel: FTLabel = {
        let l = FTLabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = Fonts.getScaledFont(textStyle: .headline, mode: .light)
        l.textColor = .white
        l.numberOfLines = 0
        l.textAlignment = .left

        return l
    }()

    var subTitleLabel: FTLabel = {
        let l = FTLabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = Fonts.getScaledFont(textStyle: .footnote, mode: .light)
        l.textColor = .white
        l.numberOfLines = 0
        l.textAlignment = .left
        return l
    }()

    var leftButton: UIButton = {
        let b = UIButton()
        b.titleLabel?.adjustsFontForContentSizeCategory = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    var rightButton: UIButton = {
        let b = UIButton()
        b.titleLabel?.font = Fonts.getScaledFont(textStyle: .body, mode: .dark)
        b.titleLabel?.adjustsFontForContentSizeCategory = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    var searchBar: UISearchBar =  {
        let s = UISearchBar(frame: .zero)
        s.translatesAutoresizingMaskIntoConstraints = false
        s.placeholder = "Search"
        s.searchBarStyle = .minimal
        return s
    }()

    var filterButton: UIButton = {
        let b = UIButton()
        b.titleLabel?.adjustsFontForContentSizeCategory = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    var enableRestLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = Fonts.getScaledFont(textStyle: .caption1, mode: .light)
        l.textColor = UIColor(white: 1.0, alpha: 0.7)
        l.textAlignment = .right
        l.text = "Enable rest time"
        return l
    }()

    var toggle: UISwitch = {
        let s = UISwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    var gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [UIColor(displayP3Red: 80/255.0, green: 99/255.0, blue: 238/255.0, alpha: 1.0).cgColor, UIColor(displayP3Red: 35/255.0, green: 37/255.0, blue: 58/255.0, alpha: 1.0).cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1.0, y: 1.0)
        return g
    }()

    required init?(coder aDecoder: NSCoder) {
        self.type = .basic
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        self.type = .filter
        super.init(frame: frame)
        commonInit()
    }

    public func update(type: Configuration) {
        self.type = type
        switch self.type {
        case .basic:
            searchBar.isHidden = true
            filterButton.isHidden = true
            toggle.isHidden = true
            enableRestLabel.isHidden = true
        case .filter:
            searchBar.isHidden = false
            filterButton.isHidden = false
            toggle.isHidden = true
            enableRestLabel.isHidden = true
        case .sets:
            searchBar.isHidden = true
            filterButton.isHidden = true
            toggle.isHidden = false
            enableRestLabel.isHidden = false
        }
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(rightButton)
        addSubview(leftButton)

        leftButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        leftButton.topAnchor.constraint(equalTo: topAnchor, constant: 54).isActive = true
        leftButtonHeight = leftButton.heightAnchor.constraint(equalToConstant: 22)
        leftButtonHeight.isActive = true
        leftButtonWidth = leftButton.widthAnchor.constraint(equalToConstant: 22)
        leftButtonWidth.isActive = true
        rightButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        rightButton.centerYAnchor.constraint(equalTo: leftButton.centerYAnchor, constant: 0).isActive = true

        leftButton.setImage(UIImage(named: "close_button"), for: .normal)
        rightButton.setTitle("Next", for: .normal)
        rightButton.titleLabel?.textColor = .white

        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)

        addSubview(searchBar)
        addSubview(filterButton)

        filterButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        filterButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor, constant: 0).isActive = true

        searchBar.leftAnchor.constraint(equalTo: leftButton.leftAnchor, constant: -14).isActive = true
        searchBarHeight = searchBar.heightAnchor.constraint(equalToConstant: 56)
        searchBarHeight.isActive = true
        searchBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7).isActive = true
        searchBar.rightAnchor.constraint(equalTo: filterButton.leftAnchor, constant: -20).isActive = true

        filterButton.setImage(UIImage(named: "filter_button"), for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)

        addSubview(titleLabel)
        addSubview(subTitleLabel)

        titleLabelLeading = titleLabel.leftAnchor.constraint(equalTo: leftButton.leftAnchor)
        titleLabelLeading.isActive = true

        primaryTitleHeight = titleLabel.heightAnchor.constraint(equalToConstant: 32)
        primaryTitleHeight.isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 24).isActive = true

        subtitleLabelLeading = subTitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor)
        subtitleLabelLeading.isActive = true
        subtitleHeight = subTitleLabel.heightAnchor.constraint(equalToConstant: 20)
        subtitleHeight.isActive = true
        subtitleLabelToTop = subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10)
        subtitleLabelToTop.isActive = true
        subTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 24).isActive = true

        titleLabel.text = "Add Exercises"
        subTitleLabel.text = "Workout Creation"

        titleLabelToTop = titleLabel.topAnchor.constraint(equalTo: leftButton.topAnchor, constant: 15 + leftButtonHeight.constant)
        titleLabelToTop.isActive = true

        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = frame


        toggle.transform = CGAffineTransform(scaleX: 0.86, y: 0.86)

        addSubview(toggle)
        addSubview(enableRestLabel)

        toggle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true
        toggle.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
//        toggle.heightAnchor.constraint(equalToConstant: 24).isActive = true
//        toggle.widthAnchor.constraint(equalToConstant: 44).isActive = true

        enableRestLabel.rightAnchor.constraint(equalTo: toggle.leftAnchor, constant: -7).isActive = true
        enableRestLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.30).isActive = true
        enableRestLabel.topAnchor.constraint(equalTo: toggle.topAnchor).isActive = true
        enableRestLabel.bottomAnchor.constraint(equalTo: toggle.bottomAnchor).isActive = true

    }

    @objc func leftButtonTapped() {
        leftButtonTappedHandler?()
    }
    @objc func rightButtonTapped() {
        rightButtonTappedHandler?()
    }
    @objc func filterButtonTapped() {
        filterButtonTappedHandler?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = frame
    }
}

class PagingContainerView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let child = super.hitTest(point, with: event)
        if let scroll = subviews.first as? OutsideScrollView, child == self && self.subviews.count > 0 {
            if scroll.contentOffset.x < scroll.frame.width {
                return scroll
            }

            return scroll.hitTest(point, with: event)
        }
        return child
    }
}

class OutsideScrollView: UIScrollView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)
        return inside
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, with: event)
        return v
    }
}

class OutsideContentView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)
        return inside
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var outsideCollectionView: OutsideCollectionView?
        for sub in subviews {
            if let s = sub as? OutsideCollectionView {
                outsideCollectionView = s
            }
        }

        if let selectedCollectionView = outsideCollectionView, let realPoint = superview?.superview?.convert(point, to: selectedCollectionView) {
            for cell in selectedCollectionView.visibleCells {
                if cell.frame.contains(realPoint) {
                    return cell.hitTest(point, with: event)
                }
            }
        }

        let v = super.hitTest(point, with: event)
        return v
    }
}

class OutsideCollectionView: UICollectionView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)
        return inside
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, with: event)

        return v
    }
}

class OutsideSelectedExerciseContentView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)
        return inside
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, with: event)
        return v
    }
}

