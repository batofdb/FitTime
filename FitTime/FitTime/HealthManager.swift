//
//  HealthManager.swift
//  FitTime
//
//  Created by Francis Bato on 9/29/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import Foundation
import HealthKit
import WatchConnectivity

class HealthManager {
    public let healthStore = HKHealthStore()
    static let shared = HealthManager()
    var startDate: Date?
    var endDate: Date?
    var activeDataQueries: [HKAnchoredObjectQuery] = [HKAnchoredObjectQuery]()
    var anchoredHeartRateQuery: HKAnchoredObjectQuery?
    var anchorHeartRate = HKQueryAnchor.init(fromValue: 0)
    let heartRateUnit: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
    var observerQuery: HKObserverQuery?
    var observedHeartRateSamples: [HKQuantitySample] = [HKQuantitySample]()

    // Validates if the HealthKit framework has the authorization to read
    func authorizeHealthKit(completion: ((Bool, Error?) -> Void)? = nil) {
        if HKHealthStore.isHealthDataAvailable() {
            let infoToRead = Set([
                HKSampleType.characteristicType(forIdentifier: .biologicalSex)!,
                HKSampleType.characteristicType(forIdentifier: .dateOfBirth)!,
                HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKSampleType.quantityType(forIdentifier: .heartRate)!,
                HKSampleType.workoutType()])

            let infoToWrite = Set([
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.workoutType()])

            healthStore.requestAuthorization(toShare: infoToWrite,
                                                     read: infoToRead,
                                                     completion: { (success, error) in

                completion?(success, error)
                //self.delegate?.workout(manager:self,didAuthorizeAccess:success,error: error)
            })
        } else {
            completion?(false, NSError(domain:"HealthManager.failedAuthorization", code:-1, userInfo:nil))
        }
    }

    func stopHealthObservation() {
        endDate = Date()
        if let o = observerQuery {
            healthStore.stop(o)
        }
    }

    func startHealthObservation() {
        startDate = Date()
        observeHeartrateSamples()
    }

    func launchWatchCompanion() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .functionalStrengthTraining
        configuration.locationType = .indoor
        healthStore.startWatchApp(with: configuration) { (success, error) in
            if let _ = error {
                print("error launching watch app")
            }

            if success {
                print("watch app successfully launched")
            }
        }
    }

    func observeHeartrateSamples() {
        let heartrateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)

        if let o = observerQuery {
            healthStore.stop(o)
        }

        observerQuery = HKObserverQuery(sampleType: heartrateSampleType!, predicate: nil, updateHandler: { [weak self] (query, handler, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            strongSelf.fetchLatestHeartrateSample { (sample) in
                guard let s = sample else {
                    return
                }

                strongSelf.observedHeartRateSamples.append(s)
                DispatchQueue.main.async {
                    let heartRate = s.quantity.doubleValue(for: strongSelf.heartRateUnit)
                    print("Heart Rate Sample: \(heartRate)")
                }
            }
        })

        healthStore.execute(observerQuery!)
        healthStore.enableBackgroundDelivery(for: HKObjectType.quantityType(forIdentifier: .heartRate)!, frequency: .immediate) { (success, error) in
            debugPrint("enableBackgroundDeliveryForType handler called for \(String(describing: HKObjectType.quantityType(forIdentifier: .heartRate))) - success: \(success), error: \(String(describing: error))")
        }
    }

    func clearHeartRateObservedCache() {
        observedHeartRateSamples.removeAll()
    }

    func fetchLatestHeartrateSample(completion: @escaping (_ sample: HKQuantitySample?) -> Void) {
        guard let st = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        anchoredHeartRateQuery = HKAnchoredObjectQuery(type: st, predicate: predicate, anchor: anchorHeartRate, limit: 0, resultsHandler: { (query, samples, deleted, anchor, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let f = samples?.first {
                completion(f as? HKQuantitySample)
            } else {
                completion(nil)
            }
        })

        /*
             let query = HKSampleQuery(sampleType: st, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (query, results, error) in
             if let error = error {
             print("Error: \(error.localizedDescription)")
             completion(nil)
             return
             }

             if let f = results?.first {
             completion(f as? HKQuantitySample)
             } else {
             completion(nil)
             }
             }
        */
        healthStore.execute(anchoredHeartRateQuery!)
    }

    func startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        let workoutStartDate = Date()
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictStartDate)
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate, devicePredicate])



        let updateHandler: ((HKAnchoredObjectQuery, [HKSample]?,
            [HKDeletedObject]?,
            HKQueryAnchor?,
            Error?) -> Void) = { query, samples, deletedObjects, queryAnchor, error in
                self.process(samples: samples, quantityTypeIdentifier: quantityTypeIdentifier)
        }

        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!,
                                          predicate: queryPredicate,
                                          anchor: nil,
                                          limit: HKObjectQueryNoLimit,
                                          resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        healthStore.execute(query)

        activeDataQueries.append(query)
    }

    func process(samples: [HKSample]?, quantityTypeIdentifier: HKQuantityTypeIdentifier) {

    }
}

extension HKQuantitySample {
    func bpm() -> Double {
        return quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
    }
}
