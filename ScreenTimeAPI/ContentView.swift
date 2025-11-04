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
    
    @State private var context: DeviceActivityReport.Context = .barGraph
    @State private var filter = DeviceActivityFilter(
        segment: .hourly(
            during: DateInterval(
                start: Date(timeIntervalSinceNow: -60 * 60 * 24),
                end: .now
            )
        ),
        users: .all,
        devices: .all
    )
    
    var body: some View {
        VStack {
            DeviceActivityReport(context, filter: filter)
                .frame(width: 300, height: 300)
        }
        .task {
            do {
                // 개인이 사용시 individual로 설정
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
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
