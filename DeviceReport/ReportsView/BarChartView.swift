//
//  BarChartView.swift
//  DeviceReport
//
//  Created by a on 11/7/25.
//

import SwiftUI
import Charts

struct BarChartView: View {
    let appReports: [AppReport]
    
    var body: some View {
        Chart(appReports, id: \.appName) { element in
            BarMark(
                x: .value("AppName", element.appName),
                y: .value("Usage", element.usage)
            )
            .foregroundStyle(by: .value("appName", element.appName))
        }
    }
}

#Preview {
    BarChartView(appReports: [])
}
