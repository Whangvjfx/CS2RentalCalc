import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: SkinStore
    @State private var showingResetAlert = false
    @State private var showingClearAlert = false
    @State private var exportShareString: String = ""
    @State private var showingExportSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                // 生活温馨寄语
                Section {
                    HStack(spacing: 14) {
                        Text("☕️")
                            .font(.system(size: 36))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CS2 租伴 • 温暖收租生活")
                                .font(.system(size: 15, weight: .bold))
                            Text("每一件心爱的饰品，都在为您创造看得见的稳健现金流。")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // 手续费与净利润核心规则说明
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📌 平台手续费扣除标准")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Theme.primary)
                        
                        Text("• 平台内购入：扣除 0.2 (20%) 平台手续费，实际到手 80% 租金。\n• 平台外购入：扣除 0.25 (25%) 平台手续费，实际到手 75% 租金。")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineSpacing(2)
                        
                        Divider()
                            .padding(.vertical, 2)
                        
                        Text("📈 总净利润计算规则")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Theme.profitGreen)
                        
                        Text("总净利润 = 所有出租计划实际到手净租金之和 + (当前现价 - 购入价)\n现价由您随时根据市场波动调整，随时为您呈现真实盈亏全貌。")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineSpacing(2)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("核心核算规则指南")
                }
                
                // 数据管理
                Section {
                    Button {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .foregroundColor(Theme.secondary)
                            Text("重置为官方精选演示数据")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                    
                    Button {
                        exportData()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(Theme.primary)
                            Text("导出饰品与出租数据 (JSON)")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                    
                    Button(role: .destructive) {
                        showingClearAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("清空所有饰品与记录")
                        }
                    }
                } header: {
                    Text("数据与账本管理")
                }
                
                // 关于
                Section {
                    HStack {
                        Text("应用名称")
                        Spacer()
                        Text("CS2租伴 (CS2 Rental Calc)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("版本号")
                        Spacer()
                        Text("v1.0.0 (Build 1)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("设计风格")
                        Spacer()
                        Text("生活风 • 热情暖意")
                            .foregroundColor(Theme.primary)
                    }
                } header: {
                    Text("关于本应用")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("设置与说明")
            .navigationBarTitleDisplayMode(.inline)
            .alert("重置为演示数据？", isPresented: $showingResetAlert) {
                Button("确定重置", role: .destructive) {
                    store.resetToDemoData()
                    hapticFeedback()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("将重新载入蝴蝶刀、印花集、咆哮等真实饰品数据与出租计划样例。")
            }
            .alert("确认清空全部数据？", isPresented: $showingClearAlert) {
                Button("清空", role: .destructive) {
                    store.clearAllData()
                    hapticFeedback()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("此操作不可撤销，请谨慎操作。")
            }
            .sheet(isPresented: $showingExportSheet) {
                ShareSheet(activityItems: [exportShareString])
            }
        }
    }
    
    private func exportData() {
        if let data = try? JSONEncoder().encode(store.skins),
           let str = String(data: data, encoding: .utf8) {
            exportShareString = str
            showingExportSheet = true
        }
    }
}

// 系统原生分享面板
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
