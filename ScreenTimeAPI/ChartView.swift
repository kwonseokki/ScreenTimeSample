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

extension DeviceActivityFilter.SegmentInterval {
    // 일일 데이터를 지정된 시간내의 기준으로 나눠서 보여준다
    static let today: Self = .daily(during: DateInterval(start: Calendar.current.startOfDay(for: Date()), end: .now))
    // 이번주 데이터를 지정된 시간 기준으로 나눠서 보여준다
    static let thisWeek: Self = .weekly(during: Calendar.current.dateInterval(of: .weekOfYear, for: .now)!)
}

struct ChartView: View {
    let center = AuthorizationCenter.shared
    
    typealias ReportType = DeviceActivityReport.Context
    
    @State private var reportType: [ReportType] = [.pieChart, .barChart]
    @State private var context: ReportType = .pieChart
    
    @State private var filter = DeviceActivityFilter(
        segment: .thisWeek,
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
            
            TabView(selection: $context) {
                DeviceActivityReport(.pieChart, filter: filter)
                    .tag(ReportType.pieChart)
                
                DeviceActivityReport(.barChart, filter: filter)
                    .tag(ReportType.barChart)
            }
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
