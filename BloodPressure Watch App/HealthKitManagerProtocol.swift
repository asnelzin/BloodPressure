//
//  HealthKitManagerProtocol.swift
//  BloodPressure Watch App
//
//  Created by Aleksandr Nelzin on 12.04.2024.
//

import HealthKit

class HealthKitManager: ObservableObject {
    @Published var recentSystolic: Int = 120
    @Published var recentDiastolic: Int = 80
    @Published var recentMeasuresDate: Date? = Date()
    private var healthStore: HKHealthStore?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            requestHealthKitPermissions()
            
            self.fetchMostRecentBloodPressure()
        }
    }
    
    private func requestHealthKitPermissions() {
            guard let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
                  let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
                print("One of the required types is unavailable.")
                return
            }

            let healthDataToRead = Set([systolicType, diastolicType])
            let healthDataToWrite = Set([systolicType, diastolicType])

            healthStore?.requestAuthorization(toShare: healthDataToWrite, read: healthDataToRead) { success, error in
                if !success || error != nil {
                    // Handle failures of permissions here
                    print("Error requesting HealthKit authorization: \(String(describing: error))")
                }
            }
        }
    
    func fetchMostRecentBloodPressure() {
        guard let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
              let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
            return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Query for systolic pressure
        let systolicQuery = HKSampleQuery(sampleType: systolicType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, results, error in
            guard let strongSelf = self, error == nil, let result = results?.first as? HKQuantitySample else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.recentSystolic = Int(result.quantity.doubleValue(for: HKUnit.millimeterOfMercury()))
                strongSelf.recentMeasuresDate = result.endDate
            }
        }

        // Query for diastolic pressure
        let diastolicQuery = HKSampleQuery(sampleType: diastolicType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, results, error in
            guard let strongSelf = self, error == nil, let result = results?.first as? HKQuantitySample else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.recentDiastolic = Int(result.quantity.doubleValue(for: HKUnit.millimeterOfMercury()))
                strongSelf.recentMeasuresDate = strongSelf.recentMeasuresDate ?? result.endDate
            }
        }

        healthStore?.execute(systolicQuery)
        healthStore?.execute(diastolicQuery)
    }
    
    func saveBloodPressure(systolic: Int, diastolic: Int) {
        guard let healthStore = self.healthStore,
              let bloodPressureType = HKObjectType.correlationType(forIdentifier: .bloodPressure),
              let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
              let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
            return
        }
        
        let now = Date()
        let systolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(systolic))
        let diastolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(diastolic))
        
        let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: now, end: now)
        let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: now, end: now)
        
        let samples: Set<HKSample> = [systolicSample, diastolicSample]
        let correlation = HKCorrelation(type: bloodPressureType, start: now, end: now, objects: samples)
        
        healthStore.save(correlation) { success, error in
            if success {
                self.fetchMostRecentBloodPressure()
                print("Blood pressure saved")
            }
            if let error = error {
                print("Error saving blood pressure: \(error.localizedDescription)")
            }
        }
    }
}
