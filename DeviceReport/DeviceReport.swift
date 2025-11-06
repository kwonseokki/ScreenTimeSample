//
//  DeviceReport.swift
//  DeviceReport
//
//  Created by a on 11/6/25.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct DeviceReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)                
        }
        // Add more reports here...
    }
}
