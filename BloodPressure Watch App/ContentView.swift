//
//  ContentView.swift
//  BloodPressure Watch App
//
//  Created by Aleksandr Nelzin on 10.04.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingLoggingView = false
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Recent Blood Pressure")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                Text("\(healthKitManager.recentSystolic) / \(healthKitManager.recentDiastolic) mmHg")
                    .font(.system(size: 25))
                    .foregroundColor(Color.green)
                    .padding(.bottom)
                
                Text(lastMeasurementDateText)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.bottom)
                
                
                Button("Log New Reading") {
                    isShowingLoggingView = true
                }
                .padding()
                .navigationDestination(isPresented: $isShowingLoggingView, destination: {
                    LoggingView(isShowingLoggingView: $isShowingLoggingView, systolicInput: $healthKitManager.recentSystolic, diastolicInput: $healthKitManager.recentDiastolic)
                        .environmentObject(healthKitManager)
                })
            }
        }
        .onChange(of: isShowingLoggingView) { _, showing in
            if !showing {
                healthKitManager.fetchMostRecentBloodPressure()
            }
        }
    }
    
    var lastMeasurementDateText: String {
        if let date = healthKitManager.recentMeasuresDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            return "at \(dateFormatter.string(from: date))"
        } else {
            return "No recent measurements"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(HealthKitManager())
    }
}
