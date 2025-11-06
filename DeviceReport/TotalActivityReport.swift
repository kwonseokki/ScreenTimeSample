//
//  TotalActivityReport.swift
//  DeviceReport
//
//  Created by a on 11/6/25.
//

import DeviceActivity
import ExtensionKit
import SwiftUI
import os
import ManagedSettings

let logger = Logger(subsystem: "com.ScreenTimeAPI.TestApp.DeviceReport", category: "DeviceActivityReport")

extension DeviceActivityReport.Context {
    // If your app initializes a DeviceActivityReport with this context, then the system will use
    // your extension's corresponding DeviceActivityReportScene to render the contents of the
    // report.
    static let totalActivity = Self("Total Activity")
    static let pieChart = Self("pieChart")
}

struct TotalActivityReport: DeviceActivityReportScene {
    // Define which context your scene will represent.
    let context: DeviceActivityReport.Context = .totalActivity
    
    // Define the custom configuration and the resulting view for this report.
    let content: (String) -> TotalActivityView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        // Reformat the data into a configuration that can be used to create
        // the report's view.
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })
        return formatter.string(from: totalActivityDuration) ?? "No activity data"
    }
}

struct PieChartReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .pieChart
    
    let content: ([AppReport]) -> PieChartView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [AppReport] {
//        await printLog(data: data)
        return await makeReport(data: data)
    }
    
    private func printLog(data: DeviceActivityResults<DeviceActivityData>) async {
        for await value in data {
            print("user role: \(value.user.role)")
            print("user appleID: \(value.user.appleID ?? "no data")")
            
            print("activity segment: \(value.activitySegments)")
            print("segment interval: \(value.segmentInterval)")
            
            for await activity in value.activitySegments {
                for await categorie in activity.categories {
                    for await application in categorie.applications {
                        print("""
                           application displayName: \(application.application.localizedDisplayName)
                           total usage time: \(application.totalActivityDuration)                           
                           """)
                    }
                }
            }
            print("-------------------------------------------------")
        }
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
