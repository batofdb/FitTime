//
//  TimerBuilder.swift
//  FitTime
//
//  Created by Francis Bato on 1/4/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import Foundation
import RealmSwift

protocol Timeable {
    var duration: Int { get set }
    var name: String { get set }
    var type: TimerType { get set }
}

struct RestTime: Timeable {
    var type: TimerType

    var duration: Int
    var name: String

    init(rest: Int, type: TimerType) {
        self.duration = rest
        self.name = "Rest"
        self.type = type
    }
}

struct CooldownTime: Timeable {
    var type: TimerType

    var duration: Int
    var rest: Int?
    var name: String

    init(cooldown: Int) {
        self.duration = cooldown
        self.name = "Cooldown"
        self.type = .cooldown
    }
}

struct WarmupTime: Timeable {
    var type: TimerType

    var duration: Int
    var rest: Int?
    var name: String

    init(warmup: Int) {
        self.duration = warmup
        self.name = "Warmup"
        self.type = .warmup
    }
}

struct ExerciseTime: Timeable {
    var type: TimerType

    var duration: Int
    var rest: Int?
    var name: String
    var rootExercise: ExerciseToWorkoutBridge

    init(exercise: ExerciseToWorkoutBridge, type: TimerType?) {
        self.duration = 0
        self.rootExercise = exercise
        self.name = self.rootExercise.name
        if self.rootExercise.rest != 0 {
            self.rest = self.rootExercise.rest
        }

        if self.rootExercise.typeEnum == .repetition {
            if let phases = self.rootExercise.rootExercise?.phases {
                var phaseTotal: Int = phases.map{ $0.interval }.reduce(0){ $0 + $1 }
                phaseTotal = phaseTotal * self.rootExercise.repetitions
                self.duration = phaseTotal
            }
        } else {
            self.duration = self.rootExercise.time
        }

        self.type = type ?? .cooldown
    }
}

struct SetTime: Timeable {
    var type: TimerType

    var duration: Int
    var rest: Int?
    var name: String
    var exercises: [ExerciseTime]

}

struct WorkoutTime: Timeable {
    var type: TimerType

    var duration: Int
    var rest: Int?
    var name: String

    var cooldowns: [CooldownTime]
    var sets: [SetTime]
    var warmups: [WarmupTime]

//    init(workout: Workout) {
//
//    }
}

struct TimerBuilder {
    var workout: Workout
    var workoutTime: WorkoutTime

//    init(workout: Workout) {
//        self.workout = workout
//        self.workoutTime = WorkoutTime(workout: self.workout)
//    }
}
