//
//  BarChartReport.swift
//  ScreenTimeAPI
//
//  Created by a on 11/7/25.
//

import SwiftUI
import DeviceActivity
import ExtensionKit
import ManagedSettings

struct BarChartReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .barChart
    
    let content: ([AppReport]) -> BarChartView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [AppReport] {        
        return await data.makeReport()
    }
}
