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

typealias BackgroundTimerCompletion = () -> Void

class BackgroundTimer {
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var time: Int = 0 {
        didSet {
            print("Timer is running: \(time) seconds")
        }
    }
    var timer: Timer? = nil

    func startBackgroundTimer(completion: BackgroundTimerCompletion? = nil) {
        guard let c = completion else { return }

        registerBackgroundTask {
            self.timer = Timer(timeInterval: 1, repeats: true, block: { [unowned self] (timer) in
                self.time += 1

                if self.time == 12 {
                    self.stopBackgroundTimer()
                    c()
                }

            })
        }
    }

    func resetBackgroundTimer() {

    }

    func stopBackgroundTimer() {
        endBackgroundTask()
        timer?.invalidate()
        timer = nil
    }
}

extension BackgroundTimer {
    func registerBackgroundTask(completion: BackgroundTimerCompletion? = nil) {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            guard let c = completion else {
                self?.endBackgroundTask()
                return
            }

            c()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }

    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
}
