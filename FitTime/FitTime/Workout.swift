//
//  Workout.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

enum ExerciseToWorkoutBridgeType: Int {
    case repetition = 0
    case time
    case unknown
}

class Workout: Object {
    override static func primaryKey() -> String? {
        return "name"
    }

    @objc dynamic var name: String = ""
    @objc dynamic var cooldown: Int = 0
    @objc dynamic var warmup: Int = 0
    @objc dynamic var dates: String = ""
    @objc dynamic var datesPerformed: String = ""

    var preExercises = List<ExerciseToWorkoutBridge>()
    var mainExercises = List<ExerciseToWorkoutBridge>()
    var postExercises = List<ExerciseToWorkoutBridge>()

}


class ExerciseToWorkoutBridge: Object {
    override static func primaryKey() -> String? {
        return "name"
    }

    @objc dynamic var name: String = ""
    @objc dynamic var rootExercise: Exercise?
    @objc dynamic var time: Int = 0
    @objc dynamic var repetitions: Int = 0
    @objc dynamic var weight: Int = 0
    @objc dynamic var machineSetting: Int = 0
    @objc dynamic var timestamp: String = ""
    

    @objc dynamic var type: Int = 0
    var typeEnum: ExerciseToWorkoutBridgeType {
        get {
            return ExerciseToWorkoutBridgeType(rawValue: type) ?? .unknown
        }

        set {
            type = newValue.rawValue
        }
    }

    convenience init(exercise: Exercise) {
        self.init()
        self.name = exercise.name
        self.rootExercise = exercise
    }
}
