import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var store: SkinStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - 1. 终极总利润构成拆解
                    profitBreakdownCard
                    
                    // MARK: - 2. 平台内 0.2 vs 平台外 0.25 扣点专项深度分析
                    feeDeductionDeepDiveCard
                    
                    // MARK: - 3. 各饰品本金回收进度大盘
                    paybackProgressSection
                    
                    // MARK: - 4. 资产配置与品类占比
                    categoryDistributionSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 36)
            }
            .background(Color.dynamicBg.ignoresSafeArea())
            .navigationTitle("收益与扣点透视")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - 1. 利润构成拆解
    private var profitBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(Theme.primary)
                Text("综合总净利润计算逻辑")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            
            VStack(spacing: 10) {
                calcFlowRow(
                    label: "累计应收租金毛额",
                    value: AppFormatters.currency(store.totalGrossRentalIncome),
                    sign: nil,
                    color: .primary
                )
                
                calcFlowRow(
                    label: "扣除平台手续费 (平台内20% / 平台外25%)",
                    value: AppFormatters.currency(store.totalFeesPaid),
                    sign: "-",
                    color: Theme.lossRed
                )
                
                calcFlowRow(
                    label: "累计实际到手净租金",
                    value: AppFormatters.currency(store.totalNetRentalIncome),
                    sign: "=",
                    color: Theme.profitGreen,
                    isHighlight: true
                )
                
                calcFlowRow(
                    label: "饰品资产浮动盈亏 (现价 - 购入原价)",
                    value: AppFormatters.currency(abs(store.totalFloatingPL)),
                    sign: store.totalFloatingPL >= 0 ? "+" : "-",
                    color: store.totalFloatingPL >= 0 ? Theme.profitGreen : Theme.lossRed
                )
                
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("合计综合总净利润")
                            .font(.system(size: 15, weight: .bold))
                        Text("实收净租金 + 饰品现价波动浮盈")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text((store.grandTotalNetProfit >= 0 ? "+" : "") + AppFormatters.currency(store.grandTotalNetProfit))
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(store.grandTotalNetProfit >= 0 ? Theme.profitGreen : Theme.lossRed)
                }
            }
        }
        .padding(16)
        .warmCard()
    }
    
    private func calcFlowRow(label: String, value: String, sign: String?, color: Color, isHighlight: Bool = false) -> some View {
        HStack {
            if let sign = sign {
                Text(sign)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                    .frame(width: 14)
            } else {
                Spacer().frame(width: 14)
            }
            
            Text(label)
                .font(.system(size: 13, weight: isHighlight ? .semibold : .regular))
                .foregroundColor(isHighlight ? .primary : .secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: isHighlight ? .bold : .medium, design: .rounded))
                .foregroundColor(color)
        }
    }
    
    // MARK: - 2. 渠道扣点深度对比
    private var feeDeductionDeepDiveCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "percent")
                    .foregroundColor(Theme.secondary)
                Text("手续费损耗对比 (0.2 vs 0.25)")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            
            Text("您在添加每个饰品时区分了平台内购入或平台外购入：\n• 平台内购入：最终到手租金扣除 0.2 (20%) 手续费\n• 平台外购入：最终到手租金扣除 0.25 (25%) 手续费")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineSpacing(3)
            
            VStack(spacing: 12) {
                // 平台内
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        ChannelBadge(channel: .inPlatform)
                        Text("共 \(store.inPlatformSkins.count) 件饰品")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("到手净租: \(AppFormatters.currency(store.inPlatformNetRent))")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.inPlatform)
                        Text("扣费: \(AppFormatters.currency(store.inPlatformFeesPaid)) (20%)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .background(Color.orange.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                // 平台外
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        ChannelBadge(channel: .outPlatform)
                        Text("共 \(store.outPlatformSkins.count) 件饰品")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("到手净租: \(AppFormatters.currency(store.outPlatformNetRent))")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.outPlatform)
                        Text("扣费: \(AppFormatters.currency(store.outPlatformFeesPaid)) (25%)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .background(Color.purple.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            if store.potentialFeeSavings > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(Theme.accentGold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("省钱智囊提示")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Theme.accentGold)
                        Text("若平台外饰品均以平台内购入，将为您多留存 \(AppFormatters.currency(store.potentialFeeSavings)) 净租金。")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(10)
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(16)
        .warmCard()
    }
    
    // MARK: - 3. 本金回本率进度
    private var paybackProgressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "gauge.with.needle.fill")
                    .foregroundColor(Theme.profitGreen)
                Text("饰品本金回本进度")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("实收净租 / 购入价")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 14) {
                ForEach(store.skins.sorted(by: { $0.paybackRate > $1.paybackRate })) { skin in
                    VStack(spacing: 6) {
                        HStack {
                            Text(skin.category.emoji)
                            Text(skin.name)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(AppFormatters.percent(skin.paybackRate, includeSign: false))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(skin.paybackRate >= 100 ? Theme.profitGreen : Theme.primary)
                        }
                        
                        ProgressView(value: min(1.0, max(0.0, skin.paybackRate / 100.0)))
                            .tint(skin.paybackRate >= 100 ? Theme.profitGreen : Theme.primary)
                        
                        HStack {
                            Text("已收租: \(AppFormatters.currency(skin.totalNetRent))")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("购入价: \(AppFormatters.currency(skin.purchasePrice))")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .warmCard()
    }
    
    // MARK: - 4. 品类分布
    private var categoryDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundColor(Theme.primary)
                Text("品类资产分布")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            
            let categories = SkinCategory.allCases.filter { cat in
                store.skins.contains(where: { $0.category == cat })
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(categories) { cat in
                    let matchingSkins = store.skins.filter { $0.category == cat }
                    let catValue = matchingSkins.reduce(0) { $0 + $1.currentPrice }
                    let catNetRent = matchingSkins.reduce(0) { $0 + $1.totalNetRent }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(cat.emoji)
                            Text(cat.title)
                                .font(.system(size: 13, weight: .bold))
                            Spacer()
                            Text("\(matchingSkins.count)件")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("现值: \(AppFormatters.currency(catValue))")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("累计收租: \(AppFormatters.currency(catNetRent))")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.profitGreen)
                    }
                    .padding(12)
                    .background(Color.dynamicSecondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(16)
        .warmCard()
    }
}
