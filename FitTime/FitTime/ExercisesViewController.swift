//
//  ExercisesViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

protocol CollectionPushAndPoppable {
    var sourceCell: UICollectionViewCell? { get }
    var collectionView: UICollectionView! { get }
    var view: UIView! { get }
}

class ExercisesViewController: UIViewController {
    let exercises = try! Realm().objects(Exercise.self).sorted(byKeyPath: "name")
    var token: NotificationToken?
    var sourceCell: UICollectionViewCell?

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Exercises"

        navigationController?.delegate = self

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .magenta
        navigationController?.navigationBar.isTranslucent = false

        collectionView.register(UINib(nibName: "ExerciseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseCollectionViewCell")
        collectionView.alwaysBounceVertical = true

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems = [add]
        // Do any additional setup after loading the view.

//        tableView.isEditing = true
//        tableView.allowsSelectionDuringEditing = true

        // Observe Realm Notifications
        token = exercises.observe { changes in
            self.collectionView.reloadData()
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

extension ExercisesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete, indexPath.section == 1 {
//            let exercise = exercises[indexPath.row]
//            let realm = try! Realm()
//            try! realm.write {
//                realm.delete(exercise)
//            }
//
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let exercise = exercises[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCollectionViewCell", for: indexPath) as! ExerciseCollectionViewCell
        cell.titleLabel.text = exercise.name

//        cell.textLabel?.text = exercise.name
//        cell.detailTextLabel?.text = exercise.typeEnum == .pull ? "Pull" : "Push"
//        cell.selectionStyle = .none
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exercises.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let createVC = storyboard?.instantiateViewController(withIdentifier: "CreateExerciseViewController") as? CreateExerciseViewController, exercises.indices.contains(indexPath.row) {
            createVC.exercise = exercises[indexPath.row]
            sourceCell = collectionView.cellForItem(at: indexPath)
            navigationController?.pushViewController(createVC, animated: true)
        }
    }
}

extension ExercisesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = view.frame.size.width
        return CGSize(width: view.frame.size.width, height: w * 0.5)
    }
}

extension ExercisesViewController: CollectionPushAndPoppable { }


extension ExercisesViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FTBaseAnimator(operation: operation)
    }
}


