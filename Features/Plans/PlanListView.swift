import SwiftUI

struct PlanListView: View {
    @EnvironmentObject var store: SkinStore
    @State private var selectedStatus: RentalFilterStatus = .all
    @State private var skinForNewPlan: SkinItem?
    @State private var editingPlanTarget: (skin: SkinItem, plan: RentalPlan)?
    
    enum RentalFilterStatus: String, CaseIterable, Identifiable {
        case all = "全部计划"
        case renting = "出租中"
        case completed = "已结清收租"
        case planned = "待起租"
        
        var id: String { rawValue }
    }
    
    // 汇总所有饰品下的所有计划
    private var allPlanEntries: [(skin: SkinItem, plan: RentalPlan)] {
        var list: [(skin: SkinItem, plan: RentalPlan)] = []
        for skin in store.skins {
            for plan in skin.plans {
                list.append((skin: skin, plan: plan))
            }
        }
        // 按起租日期降序排列
        list.sort { $0.plan.startDate > $1.plan.startDate }
        
        switch selectedStatus {
        case .all:
            return list
        case .renting:
            return list.filter { $0.plan.status == .renting }
        case .completed:
            return list.filter { $0.plan.status == .completed }
        case .planned:
            return list.filter { $0.plan.status == .planned }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 状态筛选 Tab
                Picker("状态", selection: $selectedStatus) {
                    ForEach(RentalFilterStatus.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                if allPlanEntries.isEmpty {
                    emptyPlansView
                } else {
                    List {
                        // 顶部租金统计条
                        Section {
                            plansSummaryHeader
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        
                        // 计划列表
                        Section {
                            ForEach(allPlanEntries, id: \.plan.id) { entry in
                                NavigationLink(destination: SkinDetailView(skin: entry.skin)) {
                                    GlobalPlanRowCard(skin: entry.skin, plan: entry.plan) {
                                        store.togglePlanStatus(skinId: entry.skin.id, planId: entry.plan.id)
                                    } onEdit: {
                                        editingPlanTarget = (skin: entry.skin, plan: entry.plan)
                                    } onDelete: {
                                        store.deleteRentalPlan(skinId: entry.skin.id, planId: entry.plan.id)
                                    }
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.dynamicBg)
                }
            }
            .background(Color.dynamicBg.ignoresSafeArea())
            .navigationTitle("出租明细账本")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(store.skins) { skin in
                            Button {
                                skinForNewPlan = skin
                            } label: {
                                Label("为 \(skin.name) 添加计划", systemImage: "plus")
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("记一笔")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(Theme.primary)
                    }
                }
            }
            .sheet(item: $skinForNewPlan) { skin in
                AddEditPlanSheet(skin: skin)
            }
            .sheet(item: Binding(
                get: { editingPlanTarget?.plan },
                set: { if $0 == nil { editingPlanTarget = nil } }
            )) { _ in
                if let target = editingPlanTarget {
                    AddEditPlanSheet(skin: target.skin, editingPlan: target.plan)
                }
            }
        }
    }
    
    private var plansSummaryHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("筛选总净租金")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                let netSum = allPlanEntries.reduce(0) { $0 + $1.plan.netRent(channel: $1.skin.purchaseChannel) }
                Text(AppFormatters.currency(netSum))
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(Theme.profitGreen)
            }
            
            Spacer()
            
            VStack(alignment: .center, spacing: 4) {
                Text("扣除手续费")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                let feeSum = allPlanEntries.reduce(0) { $0 + $1.plan.feeAmount(channel: $1.skin.purchaseChannel) }
                Text(AppFormatters.currency(feeSum))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.lossRed)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("记录总数")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text("\(allPlanEntries.count) 笔")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
        }
        .padding(14)
        .warmCard()
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
    
    private var emptyPlansView: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("☕️")
                .font(.system(size: 48))
            Text("当前分类下暂无出租计划")
                .font(.system(size: 16, weight: .bold))
            Text("在饰品详情中点击【新增计划】即可记录出租天数与日租金")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

// MARK: - 全局出租记录卡片
struct GlobalPlanRowCard: View {
    let skin: SkinItem
    let plan: RentalPlan
    var onToggleStatus: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(skin.category.emoji)
                    .font(.system(size: 16))
                
                Text(skin.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                StatusBadge(status: plan.status)
                
                Menu {
                    Button {
                        onToggleStatus()
                    } label: {
                        Label(plan.status == .renting ? "标记为已结清" : "恢复为出租中", systemImage: "arrow.triangle.2.circlepath")
                    }
                    Button {
                        onEdit()
                    } label: {
                        Label("编辑计划", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("删除计划", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                }
            }
            
            HStack(spacing: 8) {
                ChannelBadge(channel: skin.purchaseChannel, isCompact: true)
                
                Text("\(plan.days)天 × \(AppFormatters.currency(plan.dailyRent))/天")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("到手净租金")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(AppFormatters.currency(plan.netRent(channel: skin.purchaseChannel)))
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(Theme.profitGreen)
                }
            }
            
            HStack {
                Text("毛额: \(AppFormatters.currency(plan.grossRent))")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                Text("• 手续费扣: \(AppFormatters.currency(plan.feeAmount(channel: skin.purchaseChannel))) (\(skin.purchaseChannel == .inPlatform ? "20%" : "25%"))")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.lossRed)
                
                Spacer()
                
                Text(AppFormatters.shortDate(plan.startDate))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
        .padding(14)
        .warmCard()
    }
}
