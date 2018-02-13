//
//  ColorLibrary.swift
//  FitTime
//
//  Created by Francis Bato on 2/11/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

struct Colors {

    static func colorFor(indexPath: IndexPath) -> UIColor {
        let index = indexPath.item.remainderReportingOverflow(dividingBy: self.available.count)

        return self.available[index.partialValue]
    }

    static let available: [UIColor] = [
        UIColor.flatRed,
        UIColor.flatOrange,
        UIColor.flatYellow,
        UIColor.flatSand,
        UIColor.flatNavyBlue,
        UIColor.flatBlack,
        UIColor.flatMagenta,
        UIColor.flatTeal,
        UIColor.flatSkyBlue,
        UIColor.flatGreen,
        UIColor.flatMint,
        UIColor.flatWhite,
        UIColor.flatGray,
        UIColor.flatForestGreen,
        UIColor.flatPurple,
        UIColor.flatBrown,
        UIColor.flatPlum,
        UIColor.flatWatermelon,
        UIColor.flatLime,
        UIColor.flatPink,
        UIColor.flatMaroon,
        UIColor.flatCoffee,
        UIColor.flatPowderBlue,
        UIColor.flatBlack
    ]
}
