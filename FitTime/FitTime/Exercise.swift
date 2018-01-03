//
//  Exercise.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

enum ExerciseType: Int {
    case push = 0
    case pull
    case unknown

    static func stringFor(type: ExerciseType) -> String? {
        var str: String? = nil
        switch type {
        case .push:
            str = "Push"
        case .pull:
            str = "Pull"
        default:
            break
        }

        return str
    }
}

public protocol EnumCollection: Hashable {
    static func cases() -> AnySequence<Self>
    static var allValues: [Self] { get }
}

public extension EnumCollection {

    public static func cases() -> AnySequence<Self> {
        return AnySequence { () -> AnyIterator<Self> in
            var raw = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else {
                    return nil
                }
                raw += 1
                return current
            }
        }
    }

    public static var allValues: [Self] {
        return Array(self.cases())
    }
}

enum MuscleType: String, EnumCollection {
    case pectoral_top = "Top Pectoral"
    case bicep_inner = "Inner Bicep"
    case bicep_outer = "Outer Bicep"
    case deltoid_rear = "Rear Deltoid"

    static func getMuscleGroups(with input: String) -> [MuscleType] {
        let components = input.components(separatedBy: ",")
        var muscles = [MuscleType]()
        for c in components {
            if let t = MuscleType(rawValue: c) {
                muscles.append(t)
            }
        }

        return muscles.sorted { $0.rawValue < $1.rawValue }
    }

    static func getMuscleDatasource(with exercise: Exercise? = nil) -> [MuscleTypeWrapper] {
        guard let e = exercise else { return MuscleType.allValues.map { MuscleTypeWrapper(muscle: $0) } }

        var targetedMuscles = [String:MuscleType]()

        for m in e.muscleGroups {
            targetedMuscles[m.rawValue] = m
        }

        var wrappers = [MuscleTypeWrapper]()
        for muscle in MuscleType.allValues {
            if let m = targetedMuscles[muscle.rawValue] {
                wrappers.append(MuscleTypeWrapper(muscle: m, isSelected: true))
            } else {
                wrappers.append(MuscleTypeWrapper(muscle: muscle))
            }
        }

        return wrappers
    }
}

class MuscleTypeWrapper {
    let muscle: MuscleType
    var isSelected: Bool = false

    init(muscle: MuscleType, isSelected: Bool = false) {
        self.muscle = muscle
        self.isSelected = isSelected
    }
}

class Exercise: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var type: Int = 0

    override static func primaryKey() -> String? {
        return "name"
    }

    var phases = List<ExercisePhase>()
    @objc dynamic var musclesBacking: String?

    var muscleGroups: [MuscleType] {
        get {
            guard let b = musclesBacking else { return [MuscleType]() }
            return MuscleType.getMuscleGroups(with: b)
        }

        set {
            musclesBacking = newValue.map{ $0.rawValue }.joined(separator: ",")
        }
    }

    var typeEnum: ExerciseType {
        get {
            return ExerciseType(rawValue: type) ?? .unknown
        }

        set {
            type = newValue.rawValue
        }
    }

    @objc dynamic var comments: String = ""
}
