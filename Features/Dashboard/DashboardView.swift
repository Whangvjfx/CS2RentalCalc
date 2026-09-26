import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: SkinStore
    @State private var showingAddSkinSheet = false
    @State private var showingQuickPriceSheet = false
    @State private var selectedSkinForPlan: SkinItem?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - 生活感温暖问候 Header
                    lifestyleGreetingHeader
                    
                    // MARK: - 核心总净利润 Hero Card
                    grandProfitHeroCard
                    
                    // MARK: - 快捷功能操作条
                    quickActionRow
                    
                    // MARK: - 平台内 (0.2) vs 平台外 (0.25) 手续费与净收对比
                    channelComparisonSection
                    
                    // MARK: - 今日正在生息的在租饰品
                    activeRentingSection
                    
                    // MARK: - 饰品收益榜单 TOP 3
                    topProfitableSkinsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Color.dynamicBg.ignoresSafeArea())
            .navigationTitle("收租总览")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSkinSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddSkinSheet) {
                AddEditSkinSheet()
            }
            .sheet(isPresented: $showingQuickPriceSheet) {
                QuickPriceAdjustSheet()
            }
            .sheet(item: $selectedSkinForPlan) { skin in
                AddEditPlanSheet(skin: skin)
            }
        }
    }
    
    // MARK: - 1. 生活感温馨抬头
    private var lifestyleGreetingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("生活温度 ☕️")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Theme.primary)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("坐享饰品现金流")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Text(greetingGreetingText)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("在租日现金流")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text(AppFormatters.currency(store.todayActiveDailyNet))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.profitGreen)
                Text("/天 (净)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.dynamicSecondaryBg)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.top, 4)
    }
    
    // MARK: - 2. 核心大卡片：总净利润
    private var grandProfitHeroCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("合计总净利润")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.88))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(store.grandTotalNetProfit >= 0 ? "+" : "")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(AppFormatters.currency(store.grandTotalNetProfit))
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("综合收益率")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(AppFormatters.percent(store.overallROI))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.25))
            
            // 四宫格关键子指标
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                heroSubMetric(
                    label: "累计实收净租金",
                    value: AppFormatters.currency(store.totalNetRentalIncome),
                    icon: "banknote.fill"
                )
                
                heroSubMetric(
                    label: "饰品现价浮盈",
                    value: (store.totalFloatingPL >= 0 ? "+" : "") + AppFormatters.currency(store.totalFloatingPL),
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                heroSubMetric(
                    label: "饰品当前总市价",
                    value: AppFormatters.currency(store.totalCurrentValue),
                    icon: "bag.fill"
                )
                
                heroSubMetric(
                    label: "本金总回本进度",
                    value: AppFormatters.percent(store.overallRentalPaybackRate, includeSign: false),
                    icon: "arrow.triangle.2.circlepath"
                )
            }
        }
        .padding(20)
        .background(Theme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Theme.primary.opacity(0.35), radius: 16, x: 0, y: 8)
    }
    
    private func heroSubMetric(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.78))
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 3. 快捷操作栏
    private var quickActionRow: some View {
        HStack(spacing: 12) {
            Button {
                showingAddSkinSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Theme.primary)
                    Text("录入饰品")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .warmCard(cornerRadius: 14)
            }
            
            Button {
                showingQuickPriceSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.line")
                        .foregroundColor(Theme.secondary)
                    Text("随时改现价")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .warmCard(cornerRadius: 14)
            }
        }
    }
    
    // MARK: - 4. 平台内 (0.2) vs 平台外 (0.25) 手续费对比
    private var channelComparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("购入渠道与手续费透视")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("费率规则")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                // 平台内卡片
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        ChannelBadge(channel: .inPlatform, isCompact: true)
                        Spacer()
                        Text("\(store.inPlatformSkins.count) 件")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("到手净租金")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(AppFormatters.currency(store.inPlatformNetRent))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.inPlatform)
                    
                    Text("扣除手续费 (0.2)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(AppFormatters.currency(store.inPlatformFeesPaid))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.orange.opacity(0.18), lineWidth: 1)
                )
                
                // 平台外卡片
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        ChannelBadge(channel: .outPlatform, isCompact: true)
                        Spacer()
                        Text("\(store.outPlatformSkins.count) 件")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("到手净租金")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(AppFormatters.currency(store.outPlatformNetRent))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.outPlatform)
                    
                    Text("扣除手续费 (0.25)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(AppFormatters.currency(store.outPlatformFeesPaid))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.purple.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.purple.opacity(0.18), lineWidth: 1)
                )
            }
            
            // 贴心省钱分析
            if store.potentialFeeSavings > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Theme.accentGold)
                    Text("平台外若以平台内购入(省5%费率)，累计可多收净租金 ")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    + Text(AppFormatters.currency(store.potentialFeeSavings))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.accentGold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.dynamicSecondaryBg)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .warmCard()
    }
    
    // MARK: - 5. 正在生息的在租饰品
    private var activeRentingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Theme.profitGreen)
                        .frame(width: 8, height: 8)
                    Text("正在收租中")
                        .font(.system(size: 16, weight: .bold))
                }
                
                Spacer()
                
                Text("\(store.skins.flatMap { $0.plans }.filter { $0.status == .renting }.count) 笔计划执行中")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            let activeSkins = store.skins.filter { $0.activePlansCount > 0 }
            if activeSkins.isEmpty {
                VStack(spacing: 6) {
                    Text("☕️ 暂无正在出租中的饰品")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Text("前往饰品库为饰品添加一笔出租计划吧")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(activeSkins.prefix(4)) { skin in
                        NavigationLink(destination: SkinDetailView(skin: skin)) {
                            HStack(spacing: 12) {
                                Text(skin.category.emoji)
                                    .font(.system(size: 24))
                                    .frame(width: 40, height: 40)
                                    .background(Color.dynamicSecondaryBg)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(skin.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 6) {
                                        ChannelBadge(channel: skin.purchaseChannel, isCompact: true)
                                        Text("\(skin.activePlansCount)笔在租")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(AppFormatters.currency(skin.activeDailyRent))
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(Theme.profitGreen)
                                    Text("/天 (毛)")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(12)
                            .background(Color.dynamicSecondaryBg.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(16)
        .warmCard()
    }
    
    // MARK: - 6. 饰品净利润排行榜
    private var topProfitableSkinsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🏆 饰品综合净利润 TOP")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("净租金 + 浮盈")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            let sortedSkins = store.skins.sorted(by: { $0.totalNetProfit > $1.totalNetProfit })
            ForEach(Array(sortedSkins.prefix(3).enumerated()), id: \.element.id) { index, skin in
                NavigationLink(destination: SkinDetailView(skin: skin)) {
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(index == 0 ? Theme.accentGold : .secondary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(skin.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            HStack(spacing: 6) {
                                Text("现价 \(AppFormatters.currency(skin.currentPrice))")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text("回本 \(AppFormatters.percent(skin.paybackRate, includeSign: false))")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Theme.primary)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(skin.totalNetProfit >= 0 ? "+" + AppFormatters.currency(skin.totalNetProfit) : AppFormatters.currency(skin.totalNetProfit))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(skin.totalNetProfit >= 0 ? Theme.profitGreen : Theme.lossRed)
                            
                            Text("到手租金 \(AppFormatters.currency(skin.totalNetRent))")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
                
                if index < 2 {
                    Divider()
                }
            }
        }
        .padding(16)
        .warmCard()
    }
    
    private var greetingGreetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 11 {
            return "早上好，今天饰品行情如何？"
        } else if hour < 14 {
            return "中午好，喝杯咖啡看看收租 ☕️"
        } else if hour < 18 {
            return "下午好，现金流稳步进账中 ✨"
        } else {
            return "晚上好，盘点今日 CS2 租金收益 🌙"
        }
    }
}
