//
//  CreateExerciseViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

class CreateExerciseViewController: UIViewController {
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    @IBOutlet weak var phaseTableView: UITableView!
    @IBOutlet weak var muscleTableView: UITableView!

    var exercise: Exercise?
    //var phases = List<ExercisePhase>()
    var phases = [ExercisePhase]()
    var muscles = [MuscleTypeWrapper]()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()

        muscles = MuscleType.getMuscleDatasource(with: exercise)

        if let ex = exercise {
            nameLabel.text = ex.name
            typeSegment.selectedSegmentIndex = ex.typeEnum == .pull ? 0 : 1
            phases = Array(ex.phases)
            self.title = ex.name
        }

        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savedTapped))
        navigationItem.rightBarButtonItems = [save]

        phaseTableView.isEditing = true
        phaseTableView.allowsSelectionDuringEditing = true
        typeSegment.setTitle(ExerciseType.stringFor(type: .pull), forSegmentAt: 0)
        typeSegment.setTitle(ExerciseType.stringFor(type: .push), forSegmentAt: 1)

        phaseTableView.reloadData()
    }

    @objc func savedTapped() {
        guard let name = nameLabel.text else { return }

        let realm = try! Realm()

        if let ex = exercise {

            // Persist your data easily
            try! realm.write {
                exercise?.muscleGroups = muscles.filter{ $0.isSelected }.map{ $0.muscle }
                ex.phases.removeAll()
                ex.phases.append(objectsIn: phases)
                realm.add(ex, update: true)
            }
        } else {
            let exercise = Exercise()
            exercise.name = name
            exercise.typeEnum = typeSegment.selectedSegmentIndex == 0 ? .pull : .push
            exercise.phases.append(objectsIn: phases)
            exercise.muscleGroups = muscles.filter{ $0.isSelected }.map{ $0.muscle }

            // Persist your data easily
            try! realm.write {
                realm.add(exercise, update: true)
            }
        }
        navigationController?.popViewController(animated: true)
    }
}

extension CreateExerciseViewController: CreatePhaseViewControllerDelegate {
    func saved(phase: ExercisePhase) {
//        if let ex = exercise {
//            let realm = try! Realm()
//            try! realm.write {
//                phases.append(phase)
//            }
//        } else {
//            phases.append(phase)
//        }

        phases.append(phase)
        phaseTableView.reloadData()
    }
}

extension CreateExerciseViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == phaseTableView {
            if section == 0 {
                return 1
            }

            return phases.count
        }

        return muscles.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == phaseTableView {
            return 2
        }

        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == phaseTableView {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "add", for: indexPath)
                cell.textLabel?.text = "Add Phases"
                cell.selectionStyle = .none
                return cell
            }

            let phase = phases[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "phase", for: indexPath)
            cell.textLabel?.text = phase.name
            cell.detailTextLabel?.text = "\(phase.interval)"
            cell.selectionStyle = .none
            return cell
        }

        let muscle = muscles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = muscle.muscle.rawValue
        cell.backgroundColor = muscle.isSelected ? .red : .white
        cell.selectionStyle = .none

        //cell.detailTextLabel?.text = "\(phase.interval)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == phaseTableView {
            if indexPath.section == 0 {
                if let createVC = storyboard?.instantiateViewController(withIdentifier: "CreatePhaseViewController") as? CreatePhaseViewController {
                    createVC.delegate = self
                    navigationController?.pushViewController(createVC, animated: true)
                }
            }
        }

        let muscle = muscles[indexPath.row]
        muscle.isSelected = !muscle.isSelected

        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == phaseTableView {
            if indexPath.section == 0 {
                return false
            }

            return true
        }

        return false
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if tableView == phaseTableView {
            if indexPath.section == 0 {
                return false
            }

            return true
        }

        return false
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section == 1 && proposedDestinationIndexPath.section == 0 {
            return IndexPath(row: 0, section: 1)
        }

        return proposedDestinationIndexPath
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if tableView == phaseTableView {
            let phase = phases[sourceIndexPath.row]

            phases.remove(at: sourceIndexPath.row)
            phases.insert(phase, at: destinationIndexPath.row)
//            if let _ = exercise {
//                let realm = try! Realm()
//                try! realm.write {
//                    phases.remove(at: sourceIndexPath.row)
//                    phases.insert(phase, at: destinationIndexPath.row)
//                }
//            } else {
//
//            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == phaseTableView {
            if editingStyle == .delete, indexPath.section == 1 {
                let index = indexPath.row

//                if let _ = exercise {
//                    let realm = try! Realm()
//                    try! realm.write {
//                        phases.remove(at: index)
//                    }
//                } else {
//                    phases.remove(at: index)
//                }

                phases.remove(at: index)
                phaseTableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
            }
        }
    }
}


