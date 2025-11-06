//
//  PieChartReport.swift
//  ScreenTimeAPI
//
//  Created by a on 11/6/25.
//

import SwiftUI
import DeviceActivity
import ExtensionKit
import ManagedSettings

struct PieChartReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .pieChart
    
    let content: ([AppReport]) -> PieChartView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [AppReport] {
        await data.printLog()
        return await makeReport(data: data)
    }
    
    private func makeReport(data: DeviceActivityResults<DeviceActivityData>) async -> [AppReport] {
        var appReports: [AppReport] = await []
        
        for await value in data {
            for await activity in value.activitySegments {
                for await categorie in activity.categories {
                    for await application in categorie.applications {
                        appReports.append(AppReport(appName: application.application.localizedDisplayName!, usage: application.totalActivityDuration))
                    }
                }
            }
        }
        return appReports
    }
}
