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

    @State private var context: DeviceActivityReport.Context = .totalActivity
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
               during: Calendar.current.dateInterval(
                  of: .weekOfYear, for: .now
               )!
           ),
        users: .all,
        devices: .init([.iPhone])
    )
    
    var body: some View {
        VStack {
            Text("앱 사용량")
            DeviceActivityReport(context, filter: filter)
                .frame(width: 400, height: 400)
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
