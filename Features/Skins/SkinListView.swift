import SwiftUI

struct SkinListView: View {
    @EnvironmentObject var store: SkinStore
    @State private var searchText = ""
    @State private var selectedFilter: SkinFilter = .all
    @State private var selectedSort: SkinSortOption = .profitDesc
    @State private var showingAddSheet = false
    @State private var editingPriceSkin: SkinItem?
    @State private var tempPriceInput: String = ""
    
    enum SkinFilter: String, CaseIterable, Identifiable {
        case all = "全部"
        case inPlatform = "平台内 (0.2)"
        case outPlatform = "平台外 (0.25)"
        case renting = "出租中"
        
        var id: String { rawValue }
    }
    
    enum SkinSortOption: String, CaseIterable, Identifiable {
        case profitDesc = "综合净利润最高"
        case netRentDesc = "到手租金最高"
        case currentPriceDesc = "当前市价最高"
        case paybackDesc = "回本率最高"
        
        var id: String { rawValue }
    }
    
    var filteredSkins: [SkinItem] {
        var list = store.skins
        
        // 搜索过滤
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let query = searchText.lowercased()
            list = list.filter {
                $0.name.lowercased().contains(query) ||
                $0.category.title.contains(query) ||
                $0.wear.title.contains(query) ||
                $0.notes.lowercased().contains(query)
            }
        }
        
        // 渠道/状态过滤
        switch selectedFilter {
        case .all: break
        case .inPlatform:
            list = list.filter { $0.purchaseChannel == .inPlatform }
        case .outPlatform:
            list = list.filter { $0.purchaseChannel == .outPlatform }
        case .renting:
            list = list.filter { $0.activePlansCount > 0 }
        }
        
        // 排序
        switch selectedSort {
        case .profitDesc:
            list.sort { $0.totalNetProfit > $1.totalNetProfit }
        case .netRentDesc:
            list.sort { $0.totalNetRent > $1.totalNetRent }
        case .currentPriceDesc:
            list.sort { $0.currentPrice > $1.currentPrice }
        case .paybackDesc:
            list.sort { $0.paybackRate > $1.paybackRate }
        }
        
        return list
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 筛选过滤横向滚动条
                filterBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                if filteredSkins.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredSkins) { skin in
                            NavigationLink(destination: SkinDetailView(skin: skin)) {
                                SkinRowCard(skin: skin) {
                                    editingPriceSkin = skin
                                    tempPriceInput = String(format: "%.2f", skin.currentPrice)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteSkins)
                    }
                    .listStyle(.plain)
                    .background(Color.dynamicBg)
                }
            }
            .searchable(text: $searchText, prompt: "搜索饰品名称、分类或备注...")
            .background(Color.dynamicBg.ignoresSafeArea())
            .navigationTitle("饰品资产库 (\(store.skins.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("排序方式", selection: $selectedSort) {
                            ForEach(SkinSortOption.allCases) { opt in
                                Text(opt.rawValue).tag(opt)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("排序")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(Theme.primary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditSkinSheet()
            }
            .alert("快速调整现价", isPresented: Binding(
                get: { editingPriceSkin != nil },
                set: { if !$0 { editingPriceSkin = nil } }
            )) {
                TextField("输入最新市场价格", text: $tempPriceInput)
                    .keyboardType(.decimalPad)
                Button("确定修改") {
                    if let skin = editingPriceSkin, let newPrice = Double(tempPriceInput) {
                        store.updateCurrentPrice(for: skin.id, newPrice: newPrice)
                    }
                    editingPriceSkin = nil
                }
                Button("取消", role: .cancel) {
                    editingPriceSkin = nil
                }
            } message: {
                if let skin = editingPriceSkin {
                    Text("当前调节：\(skin.name)\n购入价为 \(AppFormatters.currency(skin.purchasePrice))，修改现价将实时更新浮盈与综合净利润。")
                }
            }
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SkinFilter.allCases) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.system(size: 12, weight: selectedFilter == filter ? .bold : .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                selectedFilter == filter
                                    ? Theme.primary
                                    : Color.dynamicSecondaryBg
                            )
                            .foregroundColor(selectedFilter == filter ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("📦")
                .font(.system(size: 48))
            Text("没有找到匹配的饰品")
                .font(.system(size: 16, weight: .bold))
            Text("您可以点击右上角 ➕ 快速录入一件新的 CS2 饰品")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Button {
                showingAddSheet = true
            } label: {
                Text("立即添加饰品")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Theme.heroGradient)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
            Spacer()
        }
    }
    
    private func deleteSkins(at offsets: IndexSet) {
        let skinsToDelete = offsets.map { filteredSkins[$0] }
        for skin in skinsToDelete {
            store.deleteSkin(id: skin.id)
        }
    }
}

// MARK: - 饰品卡片行组件
struct SkinRowCard: View {
    let skin: SkinItem
    var onEditPriceTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // 顶栏：品类、磨损、名称、渠道标签
            HStack(spacing: 8) {
                Text(skin.category.emoji)
                    .font(.system(size: 20))
                    .frame(width: 36, height: 36)
                    .background(Color.dynamicSecondaryBg)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(skin.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        CategoryWearBadge(category: skin.category, wear: skin.wear)
                        ChannelBadge(channel: skin.purchaseChannel, isCompact: true)
                    }
                }
                
                Spacer()
                
                // 综合净利润大徽章
                VStack(alignment: .trailing, spacing: 2) {
                    Text("综合净利润")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text((skin.totalNetProfit >= 0 ? "+" : "") + AppFormatters.currency(skin.totalNetProfit))
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(skin.totalNetProfit >= 0 ? Theme.profitGreen : Theme.lossRed)
                }
            }
            
            Divider()
                .background(Color.secondary.opacity(0.12))
            
            // 中间栏：购入价、现价（可随时调）、浮动盈亏、到手净租金
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("购入价")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(AppFormatters.currency(skin.purchasePrice))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                
                Spacer()
                
                // 现价（带随时修改的小铅笔按钮）
                Button {
                    onEditPriceTapped()
                } label: {
                    HStack(spacing: 4) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 2) {
                                Text("当前现价")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Image(systemName: "pencil")
                                    .font(.system(size: 9))
                                    .foregroundColor(Theme.primary)
                            }
                            Text(AppFormatters.currency(skin.currentPrice))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.dynamicSecondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("资产浮动")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text((skin.floatingPL >= 0 ? "+" : "") + AppFormatters.currency(skin.floatingPL))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(skin.floatingPL >= 0 ? Theme.profitGreen : Theme.lossRed)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("累计到手净租")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(AppFormatters.currency(skin.totalNetRent))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.primary)
                }
            }
            
            // 底栏：出租进度与回本率条
            HStack(spacing: 8) {
                ProgressView(value: min(1.0, max(0.0, skin.paybackRate / 100.0)))
                    .tint(Theme.primary)
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                
                Text("回本 \(AppFormatters.percent(skin.paybackRate, includeSign: false))")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.primary)
                
                Text("(\(skin.plans.count)笔出租)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .warmCard()
    }
}
