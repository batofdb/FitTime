//
//  WatchConnectivityManager.swift
//  FitTime
//
//  Created by Francis Bato on 9/29/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import Foundation
import WatchConnectivity
import HealthKit

class WatchConnectivityManager {
    static let shared = WatchConnectivityManager()
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    var validSession: WCSession? {
        #if os(iOS)
        if let s = session, s.isPaired, s.isWatchAppInstalled {
            return s
        }
        #elseif os(watchOS)
        return session
        #endif

        return nil
    }

    
}
