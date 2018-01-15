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

    var repType: ExerciseToWorkoutBridgeType { get set }
    var phases: [ExercisePhase]? { get set }
    var reps: Int { get set }
}

struct IntroPhaseTime: Timeable {
    var repType: ExerciseToWorkoutBridgeType
    var phases: [ExercisePhase]?
    var reps: Int
    var type: TimerType

    var duration: Int
    var name: String
    var rootExercise: ExerciseTime

    init(exercise: ExerciseTime, type: TimerType) {
        self.duration = 4
        self.rootExercise = exercise
        self.name = "\(exercise.reps) reps of \(exercise.name)"
        self.type = type

        repType = .repetition
        reps = exercise.reps
    }
}

struct PhaseTime: Timeable {
    var repType: ExerciseToWorkoutBridgeType
    var phases: [ExercisePhase]?
    var reps: Int
    var type: TimerType

    var duration: Int
    var name: String
    var rootExercise: ExerciseTime

    init(exercise: ExerciseTime, phase: ExercisePhase, type: TimerType) {
        self.duration = phase.interval
        self.rootExercise = exercise
        self.name = phase.name //"\(exercise.name):\(phase.name)"
        self.type = type

        repType = .repetition
        reps = 0
    }
}

struct RestTime: Timeable {
    var repType: ExerciseToWorkoutBridgeType
    var phases: [ExercisePhase]?
    var reps: Int
    var type: TimerType

    var duration: Int
    var name: String

    init(rest: Int, type: TimerType) {
        self.duration = rest
        self.name = "Rest"
        self.type = type

        repType = .unknown
        reps = 0
    }
}

struct CooldownTime: Timeable {
    var repType: ExerciseToWorkoutBridgeType

    var phases: [ExercisePhase]?

    var reps: Int

    var type: TimerType

    var duration: Int
    var rest: Int?
    var name: String

    init(cooldown: Int) {
        self.duration = cooldown
        self.name = "Cooldown"
        self.type = .cooldown

        repType = .unknown
        reps = 0
    }
}

struct WarmupTime: Timeable {
    var repType: ExerciseToWorkoutBridgeType
    var phases: [ExercisePhase]?
    var reps: Int
    var type: TimerType

    var duration: Int
    var rest: Int?
    var name: String

    init(warmup: Int) {
        self.duration = warmup
        self.name = "Warmup"
        self.type = .warmup

        repType = .unknown
        reps = 0
    }
}

struct ExerciseTime: Timeable {
    var repType: ExerciseToWorkoutBridgeType
    var phases: [ExercisePhase]?
    var reps: Int
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

        self.repType = self.rootExercise.typeEnum
        self.reps = exercise.repetitions

        if self.rootExercise.typeEnum == .repetition {
            if let phases = self.rootExercise.rootExercise?.phases {
                self.phases = Array(phases)
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
    var repType: ExerciseToWorkoutBridgeType
    var phases: [ExercisePhase]?
    var reps: Int
    var type: TimerType

    var duration: Int
    var rest: Int?
    var name: String
    var exercises: [ExerciseTime]

}

struct WorkoutTime: Timeable {
    var repType: ExerciseToWorkoutBridgeType
    var phases: [ExercisePhase]?
    var reps: Int
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
