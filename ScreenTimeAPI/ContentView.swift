//
//  ContentView.swift
//  ScreenTimeAPI
//
//  Created by a on 11/4/25.
//

import FamilyControls
import SwiftUI
import DeviceActivity
import ManagedSettings

struct ContentView: View {
    let center = AuthorizationCenter.shared
    
    @State private var reportType: [DeviceActivityReport.Context] = [.pieChart, .barChart]
    @State private var context: DeviceActivityReport.Context = .pieChart
    
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
            during: DateInterval(start: Calendar.current.startOfDay(for: Date()), end: .now)
        ),
        users: .all,
        devices: .init([.iPhone])
    )
    
    var body: some View {
        VStack {
            Picker("Graph Context", selection: $context) {
                ForEach(reportType, id: \.self) {
                    Text("\($0.rawValue)")
                }
            }
            .pickerStyle(.segmented)
            DeviceActivityReport(context, filter: filter)            
        }
        .task {
            do {
                // 개인이 사용시 individual로 설정
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)        
                let status = AuthorizationCenter.shared.authorizationStatus
                        print("Authorization Status: \(status)")
            } catch {
                print("error: \(error)")
            }
        }
        .padding()
    }
}

//#Preview {
//    ContentView()
//}
