import SwiftUI

struct AddEditPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: SkinStore
    
    let skin: SkinItem
    var editingPlan: RentalPlan? = nil
    
    @State private var daysText: String = "7"
    @State private var dailyRentText: String = "15.0"
    @State private var startDate: Date = Date()
    @State private var status: RentalStatus = .renting
    @State private var tenantNote: String = ""
    
    var isEditing: Bool { editingPlan != nil }
    
    // 快捷天数选项
    private let dayPresets = [3, 7, 14, 15, 30, 60, 90]
    
    init(skin: SkinItem, editingPlan: RentalPlan? = nil) {
        self.skin = skin
        self.editingPlan = editingPlan
        _daysText = State(initialValue: editingPlan != nil ? "\(editingPlan!.days)" : "7")
        _dailyRentText = State(initialValue: editingPlan != nil ? String(format: "%.2f", editingPlan!.dailyRent) : "15.0")
        _startDate = State(initialValue: editingPlan?.startDate ?? Date())
        _status = State(initialValue: editingPlan?.status ?? .renting)
        _tenantNote = State(initialValue: editingPlan?.tenantNote ?? "")
    }
    
    // 实时动态试算
    private var inputDays: Int {
        Int(daysText) ?? 0
    }
    
    private var inputDailyRent: Double {
        Double(dailyRentText) ?? 0.0
    }
    
    private var calcGrossRent: Double {
        Double(max(0, inputDays)) * max(0, inputDailyRent)
    }
    
    private var calcFee: Double {
        calcGrossRent * skin.purchaseChannel.feeRate
    }
    
    private var calcNetRent: Double {
        calcGrossRent * (1.0 - skin.purchaseChannel.feeRate)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - 饰品归属信息
                Section {
                    HStack(spacing: 12) {
                        Text(skin.category.emoji)
                            .font(.system(size: 24))
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(skin.name)
                                .font(.system(size: 14, weight: .bold))
                            
                            HStack(spacing: 6) {
                                ChannelBadge(channel: skin.purchaseChannel)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                } header: {
                    Text("当前出租的饰品")
                }
                
                // MARK: - 出租天数与快捷选择
                Section {
                    HStack {
                        Text("出租天数")
                            .font(.system(size: 14))
                        Spacer()
                        TextField("天数", text: $daysText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text("天")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(dayPresets, id: \.self) { d in
                                Button {
                                    daysText = "\(d)"
                                    hapticFeedback(.light)
                                } label: {
                                    Text("\(d)天")
                                        .font(.system(size: 12, weight: inputDays == d ? .bold : .medium))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(inputDays == d ? Theme.primary : Color.dynamicSecondaryBg)
                                        .foregroundColor(inputDays == d ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("租期设置")
                }
                
                // MARK: - 日租金
                Section {
                    HStack {
                        Text("日租金 (元/天)")
                            .font(.system(size: 14))
                        Spacer()
                        TextField("0.00", text: $dailyRentText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.primary)
                        Text("元")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("租金单价")
                }
                
                // MARK: - 实时测算结果卡片 (用户核心心智：扣0.2还是0.25？到手多少？)
                Section {
                    VStack(spacing: 10) {
                        HStack {
                            Text("租金毛额 (\(inputDays)天 × \(AppFormatters.currency(inputDailyRent)))")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(AppFormatters.currency(calcGrossRent))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        
                        HStack {
                            Text("扣除手续费 (\(skin.purchaseChannel.shortTitle) \(skin.purchaseChannel == .inPlatform ? "0.2" : "0.25"))")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.lossRed)
                            Spacer()
                            Text("- " + AppFormatters.currency(calcFee))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Theme.lossRed)
                        }
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("最终到手净租金")
                                    .font(.system(size: 14, weight: .bold))
                                Text(skin.purchaseChannel == .inPlatform ? "按 80% 比例净收结算" : "按 75% 比例净收结算")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(AppFormatters.currency(calcNetRent))
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(Theme.profitGreen)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("✨ 实时净租金收益核算")
                }
                
                // MARK: - 租期日期与状态
                Section {
                    DatePicker("起租日期", selection: $startDate, displayedComponents: .date)
                    
                    Picker("当前状态", selection: $status) {
                        ForEach(RentalStatus.allCases) { s in
                            Text(s.title).tag(s)
                        }
                    }
                    
                    TextField("备注 (如: 租客昵称、押金、订单编号等)", text: $tenantNote)
                } header: {
                    Text("订单细节")
                }
            }
            .navigationTitle(isEditing ? "编辑出租计划" : "添加出租计划")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存计划") {
                        savePlan()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Theme.primary)
                    .disabled(inputDays <= 0 || inputDailyRent <= 0)
                }
            }
        }
    }
    
    private func savePlan() {
        if var plan = editingPlan {
            plan.days = inputDays
            plan.dailyRent = inputDailyRent
            plan.startDate = startDate
            plan.status = status
            plan.tenantNote = tenantNote
            store.updateRentalPlan(skinId: skin.id, plan: plan)
        } else {
            let newPlan = RentalPlan(
                days: inputDays,
                dailyRent: inputDailyRent,
                startDate: startDate,
                status: status,
                tenantNote: tenantNote
            )
            store.addRentalPlan(to: skin.id, plan: newPlan)
        }
        
        hapticFeedback()
        dismiss()
    }
}
