//
//  DeviceActivityReportContext+.swift
//  ScreenTimeAPI
//
//  Created by a on 11/6/25.
//

import DeviceActivity
import ExtensionKit
import SwiftUI
import ManagedSettings

extension DeviceActivityReport.Context {
    // If your app initializes a DeviceActivityReport with this context, then the system will use
    // your extension's corresponding DeviceActivityReportScene to render the contents of the
    // report.
    static let totalActivity = Self("Total Activity")
    static let pieChart = Self("pieChart")
    static let barChart = Self("barChart")
}
