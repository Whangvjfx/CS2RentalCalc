import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("总览", systemImage: "sparkles.rectangle.stack.fill")
                }
                .tag(0)
            
            SkinListView()
                .tabItem {
                    Label("饰品库", systemImage: "archivebox.fill")
                }
                .tag(1)
            
            PlanListView()
                .tabItem {
                    Label("出租账本", systemImage: "list.bullet.rectangle.portrait.fill")
                }
                .tag(2)
            
            AnalyticsView()
                .tabItem {
                    Label("收益透视", systemImage: "chart.pie.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(Theme.primary)
    }
}
