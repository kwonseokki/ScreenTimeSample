# ScreenTimeSample
ScreenTime API를 활용해 앱 사용량을 가져오고 Chart로 보여주는 샘플 프로젝트입니다.

| pieChart | barChaart |
|-----|-----|
| <img width=300 src="https://github.com/user-attachments/assets/ceee7cd7-1d26-4b44-89a0-bad506993f76" /> |  <img width=300 src="https://github.com/user-attachments/assets/3c865892-c66a-4777-8b29-0c7563324208" />  |

## 주요 개념
실제로 프로젝트에 불러와서 사용하는 프레임워크는 `FamilyControls`, `DeviceActivity`, `ManagedSettings` 이 3개이고
보통 위에 3개의 프레임워크를 통틀어 ScreenTime API 라고 부른다 실제로 해당 앱에서는 FamilyControl, DeviceActivity를 주로 사용.

**FaimlyControls:**  자녀 보호기능을 승인할때 사용 ScreenTime API 의 권한을 요청하고 권한이 없으면 접근이 불가능<br/>
**DeviceActivity:**  앱내의 확장으로 추가된 앱에서 동작 기기 활동을 모니터링 하거나 사용시간 리포트를 받아볼 수 있음. <br/>
**ManagedSettings:**  특정 기기 및 앱에 대해서 접근 제어가 가능하도록 함 <br/>

## 작업 전 체크리스트
- [ ] General -> Target Capability에 FaimilyControls 추가
- [ ] 프로젝트 Navigator에 ScreenTimeAPI.entitlements 생성 확인
- [ ] ScreenTime API 권한 요청 필수

## Extension 추가
- Xcode 상단 File > new > Target 에서 Device ActivityReport Extension 추가
- 앱내에 직접 포함시키면 안됨 보안적인 문제로 App Extension을 메인 앱에서 DeviceReport를 통해서 정보를 가져온다.

## DeviceReport 
```swift
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
```
- 확장앱의 EntryPoint
- Report를 구성하는 구조체를 body에 추가한다.

## PieChartReport
```swift
extension DeviceActivityReport.Context {
    // If your app initializes a DeviceActivityReport with this context, then the system will use
    // your extension's corresponding DeviceActivityReportScene to render the contents of the
    // report.
    static let totalActivity = Self("Total Activity")
    static let pieChart = Self("pieChart")
    static let barChart = Self("barChart")
}

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
```
- DeviceActivityReport.Context 를 확장해서 Context Type 상수를 추가한다. 
- 화면에 표시할 뷰와 컨텍스트를 정의 makeConfiguration 에서 가공한 데이터는 PieChartView로 전달된다.
- 메인 앱에서 지정한 Contenxt가 호출될때 해당하는 Scene을 불러서 렌더링한다.

## PieChartView
```swift
struct PieChartView: View {
    let appReports: [AppReport]
    ...
var body: some View {
        Chart(appReports, id: \.self) { element in
            SectorMark(angle: .value("usage", element.usage),
                       innerRadius: .ratio(0.618),
                       outerRadius: .inset(10),
                       angularInset: 1)
            .opacity(element.appName == selectedItem?.appName ? 1 : 0.5)
            .foregroundStyle(by: .value("appName", element.appName))
        }
...
```
- PieChartReport 에서 데이터를 가공하고 전달하면 등록한 해당 뷰에서 받아서 UI로 데이터를 표시한다.

## ChartView(Main App)

individual로 권한 요청 필수
```swift
truct ChartView: View {
    let center = AuthorizationCenter.shared
...
VStack {...}
   }
        .task {
            do {
                // 개인이 사용시 individual로 설정
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                let status = AuthorizationCenter.shared.authorizationStatus
                print("Authorization Status: \(status)")
            } catch {
                print("error: \(error)")
            }
        }
```

Filter를 정의한다 DeviceActivityFilter로 넘겨주는 기준으로 특정기간 또는 디바이스에 한정해서 필터해서 데이터를 넘겨준다.
```swift
    @State private var filter = DeviceActivityFilter(
        segment: .thisWeek,
        users: .all,
        devices: .init([.iPhone])
    )
```

DeviceActivityReport에 지정한 Context와 filter를 넘겨주면 PieChart로 앱 사용량을 보여준다.
```swift
    var body: some View {
        VStack {
            Picker("Graph Context", selection: $context) {
                ForEach(reportType, id: \.self) {
                    Text("\($0.rawValue)")
                }
            }
            .pickerStyle(.segmented)
            
            TabView(selection: $context) {
                DeviceActivityReport(.pieChart, filter: filter)
                    .tag(ReportType.pieChart)
                
                DeviceActivityReport(.barChart, filter: filter)
                    .tag(ReportType.barChart)
            }
        }
```

## Trouble Shooting
### DevieReport Extension에서 받아온 데이터 디버깅이 안되는 문제
확장앱은 OS 내에서 다른 프로세스로 돌아가기 떄문에 로깅이 불가능했다. OSLog 사용해도 나타나지 않아서 확장앱을 Scheme에서 선택하고 메인앱으로 실행했다.<br/>
확장앱 선택하고 실행 <br/>
<img width="231" height="40" alt="스크린샷 2025-11-07 오전 3 04 22" src="https://github.com/user-attachments/assets/9235b98b-e028-4e8f-a8f1-a24f5c5bae55" /><br/>
실제 빌드는 메인앱으로<br/>
<img width="552" height="519" alt="스크린샷 2025-11-07 오전 3 04 43" src="https://github.com/user-attachments/assets/9e2da60a-58ee-4e0e-8989-51635cfb983b" />

### ChartView가 화면에 나타나지 않는 문제
DeviceActivityReport를 뷰에 추가해도 해당하는 ChartView가 나타나지 않았다. 
로그를 살펴보니 attempt to map database failed: permission was denied. This attempt will not be retried. 라고 되어있지만 자세한 오류해결법은 나와있지 않았다.

Target -> Build Phases -> Copy only when installing 체크 해제 후 다시 빌드하니 문제가 해결되었다.
<img width="416" height="242" alt="스크린샷 2025-11-07 오전 3 08 17" src="https://github.com/user-attachments/assets/fe4358b6-6015-4626-ae25-3bde56611b6b" />

