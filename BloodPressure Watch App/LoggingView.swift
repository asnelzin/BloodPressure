//
//  LoggingView.swift
//  BloodPressure Watch App
//
//  Created by Aleksandr Nelzin on 12.04.2024.
//

import SwiftUI

struct BloodPressurePickerView: View {
    @Binding var selectedValue: Int
    let range: ClosedRange<Int>
    let title: String
    
    var body: some View {
        VStack {
            Picker("Select Value", selection: $selectedValue) {
                ForEach(range, id: \.self) { number in
                    Text("\(number)").tag(number)
                        .tag(number)
                        .font(.title3)
                }
            }
            .labelsHidden()
            .pickerStyle(WheelPickerStyle())
            .frame(width: 120)
            .clipped()
            .padding(.horizontal, 30)
            .navigationTitle(title)
        }
    }
}

enum PickerType: Identifiable {
    case systolic
    case diastolic
    
    var id: Self {self}
}

struct LoggingView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @Binding var isShowingLoggingView: Bool
    @Binding var systolicInput: Int
    @Binding var diastolicInput: Int
    @State private var activePicker: PickerType?

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    BloodPressurePickerView(selectedValue: $systolicInput, range: 1...250, title: "Systolic")
                } label: {
                    Text("Systolic: \(systolicInput) mmHg")
                }
                NavigationLink {
                    BloodPressurePickerView(selectedValue: $diastolicInput, range: 1...250, title: "Diastolic")
                } label: {
                    Text("Diastolic: \(diastolicInput) mmHg")
                }
                Button("Log Blood Pressure") {
                    healthKitManager.saveBloodPressure(systolic: systolicInput, diastolic: diastolicInput)
                    isShowingLoggingView = false
                }
                .buttonStyle(BorderedButtonStyle(tint: .green.opacity(255)))
                .listRowPlatterColor(Color.clear)
            }

            .navigationTitle("Log Blood Pressure")
        }
        .onAppear() {
            self.systolicInput = healthKitManager.recentSystolic
            self.diastolicInput = healthKitManager.recentDiastolic
        }
    }
        

}


struct LoggingView_Previews: PreviewProvider {
    static var previews: some View {
        LoggingView(isShowingLoggingView: .constant(false), systolicInput: .constant(120), diastolicInput: .constant(80))
            .environmentObject(HealthKitManager())
    }
}
