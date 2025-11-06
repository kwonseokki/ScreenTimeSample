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
        PieChartReport { appReports in
            PieChartView(appReports: appReports)
        }
        BarChartReport { appReports in
            BarChartView(appReports: appReports)
        }
    }
}
