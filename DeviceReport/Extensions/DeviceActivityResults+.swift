//
//  DeviceActivityResults+.swift
//  ScreenTimeAPI
//
//  Created by a on 11/7/25.
//

import SwiftUI
import DeviceActivity
import ManagedSettings

extension DeviceActivityResults where Element ==  DeviceActivityData {
    func printLog() async {
        for await value in self {
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
}
