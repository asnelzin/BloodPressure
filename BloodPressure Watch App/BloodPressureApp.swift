//
//  BloodPressureApp.swift
//  BloodPressure Watch App
//
//  Created by Aleksandr Nelzin on 10.04.2024.
//

import SwiftUI

@main
struct BloodPressureApp: App {
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(healthKitManager)
            }
        }
    }
}
