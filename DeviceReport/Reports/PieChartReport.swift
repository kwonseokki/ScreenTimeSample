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
