//
//  Workout.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

class Workout: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var cooldown: Int = 0
    @objc dynamic var warmup: Int = 0
}
