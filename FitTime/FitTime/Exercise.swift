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

class Exercise: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var type: Int = 0

    override static func primaryKey() -> String? {
        return "name"
    }

    var phases = List<ExercisePhase>()

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
