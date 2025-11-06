//
//  PieChartView.swift
//  DeviceReport
//
//  Created by a on 11/6/25.
//

import SwiftUI
import Charts

struct PieChartView: View {
    let appReports: [AppReport]
    
    private let categoryRanges: [(category: String, range: Range<Double>)]
    private let totalReports: Int
    
    @State private var selectedAngle: Double?
    @State private var selectedData: AppReport?
    
    var selectedItem: AppReport? {
        guard let selectedAngle else { return nil }
        if let selected = categoryRanges.firstIndex(where: {
            $0.range.contains(selectedAngle)
        }) {
            return appReports[selected]
        }
        return nil
    }
    
    init(appReports: [AppReport]) {
        self.appReports = appReports
        var total = 0
        
        categoryRanges = appReports.map {
            let newTotal = total + Int($0.usage)
            let result = (category: $0.appName,
                          range: Double(total) ..< Double(newTotal))
            total = newTotal
            return result
        }
        totalReports = total
    }
    
    var body: some View {
        Chart(appReports, id: \.self) { element in
            SectorMark(angle: .value("usage", element.usage),
                       innerRadius: .ratio(0.618),
                       outerRadius: .inset(10),
                       angularInset: 1)
            .opacity(element.appName == selectedItem?.appName ? 1 : 0.5)
            .foregroundStyle(by: .value("appName", element.appName))
        }
        .chartAngleSelection(value: $selectedAngle)
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let frame = geometry[chartProxy.plotFrame!]
                
                VStack {
                    if let selectedItem {
                        Text("\(selectedItem.appName)")
                        Text(selectedItem.usage.toHHMM())
                            .font(.title)
                            .fontWeight(.bold)
                    } else if let selectedData {
                        Text("\(selectedData.appName)")
                        Text(selectedData.usage.toHHMM())
                            .font(.title)
                            .fontWeight(.bold)
                    } else {
                        Text("N/A")
                        Text("0")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                }
                .position(x: frame.midX, y: frame.midY)
            }
        }
    }
}

#Preview {
    PieChartView(appReports: [])
}
