import SwiftUI

struct SkinDetailView: View {
    let skin: SkinItem
    @EnvironmentObject var store: SkinStore
    @State private var showingAddPlanSheet = false
    @State private var showingEditSkinSheet = false
    @State private var showingPriceAdjustAlert = false
    @State private var newPriceInput: String = ""
    @State private var planToEdit: RentalPlan?
    
    // 从 Store 中动态获取最新的饰品实例（保证调价、增减计划后实时响应）
    private var currentSkin: SkinItem {
        store.skins.first(where: { $0.id == skin.id }) ?? skin
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - 1. 饰品基本档案与渠道标签
                skinHeaderCard
                
                // MARK: - 2. 核心综合净利润总览
                profitHeroCard
                
                // MARK: - 3. 随时调整现价交互条 (核心需求)
                currentPriceInteractiveBar
                
                // MARK: - 4. 平台扣点与租金透明明细
                feeTransparencyCard
                
                // MARK: - 5. 出租计划列表明细 (若干笔出租计划)
                rentalPlansSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(Color.dynamicBg.ignoresSafeArea())
        .navigationTitle(currentSkin.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEditSkinSheet = true
                    } label: {
                        Label("编辑饰品信息", systemImage: "pencil")
                    }
                    
                    Button {
                        showingAddPlanSheet = true
                    } label: {
                        Label("新增出租计划", systemImage: "plus.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                        .foregroundColor(Theme.primary)
                }
            }
        }
        .sheet(isPresented: $showingAddPlanSheet) {
            AddEditPlanSheet(skin: currentSkin)
        }
        .sheet(isPresented: $showingEditSkinSheet) {
            AddEditSkinSheet(editingSkin: currentSkin)
        }
        .sheet(item: $planToEdit) { plan in
            AddEditPlanSheet(skin: currentSkin, editingPlan: plan)
        }
        .alert("随时修改现价", isPresented: $showingPriceAdjustAlert) {
            TextField("最新现价 (¥)", text: $newPriceInput)
                .keyboardType(.decimalPad)
            Button("保存更新") {
                if let price = Double(newPriceInput) {
                    store.updateCurrentPrice(for: currentSkin.id, newPrice: price)
                    hapticFeedback()
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("现价随时变动，输入最新市场估值将即时重新计算浮盈及总净利润。")
        }
    }
    
    // MARK: - 1. 饰品头部档案
    private var skinHeaderCard: some View {
        HStack(spacing: 14) {
            Text(currentSkin.category.emoji)
                .font(.system(size: 32))
                .frame(width: 56, height: 56)
                .background(Color.dynamicSecondaryBg)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(currentSkin.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    CategoryWearBadge(category: currentSkin.category, wear: currentSkin.wear)
                    ChannelBadge(channel: currentSkin.purchaseChannel)
                }
                
                if !currentSkin.notes.isEmpty {
                    Text(currentSkin.notes)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .warmCard()
    }
    
    // MARK: - 2. 核心综合净利润总览
    private var profitHeroCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("该饰品综合净利润")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                    
                    Text((currentSkin.totalNetProfit >= 0 ? "+" : "") + AppFormatters.currency(currentSkin.totalNetProfit))
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("累计到手净租")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                    Text(AppFormatters.currency(currentSkin.totalNetRent))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("购入原价")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.75))
                    Text(AppFormatters.currency(currentSkin.purchasePrice))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text("当前现价")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.75))
                    Text(AppFormatters.currency(currentSkin.currentPrice))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("现价浮动盈亏")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.75))
                    Text((currentSkin.floatingPL >= 0 ? "+" : "") + AppFormatters.currency(currentSkin.floatingPL))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(18)
        .background(Theme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Theme.primary.opacity(0.3), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - 3. 随时调现价交互条
    private var currentPriceInteractiveBar: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundColor(Theme.secondary)
                        Text("现价随时波动调整")
                            .font(.system(size: 14, weight: .bold))
                    }
                    Text("当前市价随时根据行情波动调整，即时重算净利润")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    newPriceInput = String(format: "%.2f", currentSkin.currentPrice)
                    showingPriceAdjustAlert = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("修改现价")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(Capsule())
                }
            }
            
            // 快捷微调小按钮 (+50, +100, -50, -100)
            HStack(spacing: 8) {
                priceQuickAdjustButton(delta: -100)
                priceQuickAdjustButton(delta: -50)
                priceQuickAdjustButton(delta: +50)
                priceQuickAdjustButton(delta: +100)
            }
        }
        .padding(14)
        .warmCard()
    }
    
    private func priceQuickAdjustButton(delta: Double) -> some View {
        Button {
            let updated = max(0, currentSkin.currentPrice + delta)
            store.updateCurrentPrice(for: currentSkin.id, newPrice: updated)
            hapticFeedback(.light)
        } label: {
            Text(delta > 0 ? "+\(Int(delta))" : "\(Int(delta))")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(delta > 0 ? Theme.profitGreen : Theme.lossRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.dynamicSecondaryBg)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
    
    // MARK: - 4. 平台扣点与租金透明明细
    private var feeTransparencyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("渠道扣点与透明账目")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Text(currentSkin.purchaseChannel == .inPlatform ? "平台内扣 0.2" : "平台外扣 0.25")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(currentSkin.purchaseChannel.themeColor)
            }
            
            VStack(spacing: 10) {
                feeRow(label: "累计应收租金毛额", value: AppFormatters.currency(currentSkin.totalGrossRent))
                feeRow(
                    label: "扣除平台手续费 (\(Int(currentSkin.purchaseChannel.feeRate * 100))%)",
                    value: "- " + AppFormatters.currency(currentSkin.totalFeePaid),
                    valueColor: Theme.lossRed
                )
                feeRow(
                    label: "实际到手净租金",
                    value: AppFormatters.currency(currentSkin.totalNetRent),
                    valueColor: Theme.profitGreen,
                    isBold: true
                )
            }
            
            Divider()
            
            // 回本分析条
            HStack {
                Text("租金回本率: \(AppFormatters.percent(currentSkin.paybackRate, includeSign: false))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.primary)
                
                Spacer()
                
                if let days = currentSkin.daysToBreakeven {
                    if days == 0 {
                        Text("🎉 已完全收回购入成本！")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.profitGreen)
                    } else {
                        Text("预计还需 \(days) 天回本")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .warmCard()
    }
    
    private func feeRow(label: String, value: String, valueColor: Color = .primary, isBold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: isBold ? .semibold : .regular))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: isBold ? .bold : .medium, design: .rounded))
                .foregroundColor(valueColor)
        }
    }
    
    // MARK: - 5. 出租计划列表明细
    private var rentalPlansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .foregroundColor(Theme.primary)
                    Text("出租计划明细 (\(currentSkin.plans.count))")
                        .font(.system(size: 16, weight: .bold))
                }
                
                Spacer()
                
                Button {
                    showingAddPlanSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("新增计划")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.heroGradient)
                    .clipShape(Capsule())
                }
            }
            
            if currentSkin.plans.isEmpty {
                VStack(spacing: 8) {
                    Text("📝 暂无出租计划")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("点击右上角【新增计划】录入出租天数与日租金")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(currentSkin.plans) { plan in
                    RentalPlanRowCard(plan: plan, channel: currentSkin.purchaseChannel) {
                        store.togglePlanStatus(skinId: currentSkin.id, planId: plan.id)
                    } onEdit: {
                        planToEdit = plan
                    } onDelete: {
                        store.deleteRentalPlan(skinId: currentSkin.id, planId: plan.id)
                    }
                }
            }
        }
        .padding(16)
        .warmCard()
    }
}

// MARK: - 单笔出租计划卡片
struct RentalPlanRowCard: View {
    let plan: RentalPlan
    let channel: PurchaseChannel
    var onToggleStatus: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                StatusBadge(status: plan.status)
                
                Spacer()
                
                Button {
                    onToggleStatus()
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: plan.status == .renting ? "checkmark.circle" : "arrow.clockwise")
                        Text(plan.status == .renting ? "收租结清" : "恢复出租")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.primary)
                }
                
                Menu {
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
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.leading, 6)
                }
            }
            
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("出租天数")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("\(plan.days) 天")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("日租金")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(AppFormatters.currency(plan.dailyRent))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("手续费 (\(Int(channel.feeRate * 100))%)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("- " + AppFormatters.currency(plan.feeAmount(channel: channel)))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.lossRed)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("实收到手净额")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(AppFormatters.currency(plan.netRent(channel: channel)))
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(Theme.profitGreen)
                }
            }
            
            if !plan.tenantNote.isEmpty {
                HStack {
                    Image(systemName: "note.text")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(plan.tenantNote)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("起租: \(AppFormatters.shortDate(plan.startDate))")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .padding(.top, 2)
            }
        }
        .padding(12)
        .background(Color.dynamicSecondaryBg.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
