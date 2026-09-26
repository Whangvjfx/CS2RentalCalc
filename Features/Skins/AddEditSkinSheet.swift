import SwiftUI

struct AddEditSkinSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: SkinStore
    
    var editingSkin: SkinItem? = nil
    
    @State private var name: String = ""
    @State private var category: SkinCategory = .knife
    @State private var wear: SkinWear = .fn
    @State private var purchasePriceText: String = ""
    @State private var currentPriceText: String = ""
    @State private var purchaseChannel: PurchaseChannel = .inPlatform
    @State private var notes: String = ""
    
    // 热门预设
    private let presetSkins: [(name: String, category: SkinCategory, wear: SkinWear, price: Double, channel: PurchaseChannel)] = [
        ("蝴蝶刀 (★) | 渐变大理石", .knife, .fn, 12000.0, .inPlatform),
        ("AK-47 | 印花集", .rifle, .fn, 1900.0, .outPlatform),
        ("M4A4 | 咆哮", .rifle, .mw, 38000.0, .inPlatform),
        ("运动手套 (★) | 迈阿密风云", .gloves, .ft, 9500.0, .outPlatform),
        ("AWP | 二乃 (二硫化物)", .sniper, .fn, 700.0, .inPlatform),
        ("爪子刀 (★) | 多普勒 P2", .knife, .fn, 13500.0, .inPlatform),
        ("M4A1-S | 二乃", .rifle, .fn, 1200.0, .inPlatform)
    ]
    
    var isEditing: Bool { editingSkin != nil }
    
    init(editingSkin: SkinItem? = nil) {
        self.editingSkin = editingSkin
        _name = State(initialValue: editingSkin?.name ?? "")
        _category = State(initialValue: editingSkin?.category ?? .knife)
        _wear = State(initialValue: editingSkin?.wear ?? .fn)
        _purchasePriceText = State(initialValue: editingSkin != nil ? String(format: "%.2f", editingSkin!.purchasePrice) : "")
        _currentPriceText = State(initialValue: editingSkin != nil ? String(format: "%.2f", editingSkin!.currentPrice) : "")
        _purchaseChannel = State(initialValue: editingSkin?.purchaseChannel ?? .inPlatform)
        _notes = State(initialValue: editingSkin?.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - 快捷预设模版
                if !isEditing {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(presetSkins, id: \.name) { preset in
                                    Button {
                                        name = preset.name
                                        category = preset.category
                                        wear = preset.wear
                                        purchasePriceText = String(format: "%.0f", preset.price)
                                        currentPriceText = String(format: "%.0f", preset.price)
                                        purchaseChannel = preset.channel
                                        hapticFeedback(.light)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(preset.category.emoji)
                                            Text(preset.name)
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.dynamicSecondaryBg)
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        Text("⚡️ 常用热门 CS2 饰品模版 (点击一键填入)")
                    }
                }
                
                // MARK: - 饰品基本信息
                Section {
                    TextField("饰品名称 (如: 蝴蝶刀 | 渐变大理石)", text: $name)
                    
                    Picker("品类分类", selection: $category) {
                        ForEach(SkinCategory.allCases) { cat in
                            Text("\(cat.emoji) \(cat.title)").tag(cat)
                        }
                    }
                    
                    Picker("外观磨损", selection: $wear) {
                        ForEach(SkinWear.allCases) { w in
                            Text("\(w.title) (\(w.shortCode))").tag(w)
                        }
                    }
                } header: {
                    Text("饰品基础资料")
                }
                
                // MARK: - 核心：购入渠道选择 (平台内 0.2 vs 平台外 0.25)
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("请选择饰品购入渠道（直接决定出租租金扣费比例）:")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            // 平台内选择卡片
                            channelSelectionCard(
                                channel: .inPlatform,
                                title: "平台内购入",
                                rateDesc: "0.2 手续费",
                                subDesc: "租金到手 80%",
                                isSelected: purchaseChannel == .inPlatform
                            )
                            
                            // 平台外选择卡片
                            channelSelectionCard(
                                channel: .outPlatform,
                                title: "平台外购入",
                                rateDesc: "0.25 手续费",
                                subDesc: "租金到手 75%",
                                isSelected: purchaseChannel == .outPlatform
                            )
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("💰 购入渠道与手续费档位 (重要)")
                }
                
                // MARK: - 价格信息 (购入价与当前现价)
                Section {
                    HStack {
                        Text("购入成本 (¥)")
                            .font(.system(size: 14))
                        Spacer()
                        TextField("0.00", text: $purchasePriceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("当前市场现价 (¥)")
                                .font(.system(size: 14))
                            Text("随时波动，后续可随时调整")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        TextField("0.00", text: $currentPriceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.primary)
                    }
                    
                    Button {
                        currentPriceText = purchasePriceText
                        hapticFeedback(.light)
                    } label: {
                        HStack {
                            Image(systemName: "equal.circle")
                            Text("快速将当前现价同步为购入价")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.secondary)
                    }
                } header: {
                    Text("价格核算")
                } footer: {
                    Text("💡 浮动盈亏 = 当前现价 - 购入成本。您在任何时候都可以微调现价，应用会自动重算总净利润。")
                        .font(.system(size: 11))
                }
                
                // MARK: - 备注
                Section {
                    TextField("例如: 红顶渐变、四连印花、悠悠自提等", text: $notes)
                } header: {
                    Text("备注笔记 (可选)")
                }
            }
            .navigationTitle(isEditing ? "编辑饰品" : "录入新饰品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveSkin()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Theme.primary)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func channelSelectionCard(channel: PurchaseChannel, title: String, rateDesc: String, subDesc: String, isSelected: Bool) -> some View {
        Button {
            purchaseChannel = channel
            hapticFeedback(.light)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: channel.iconName)
                        .font(.system(size: 14))
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(channel.themeColor)
                    }
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(rateDesc)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(channel.themeColor)
                
                Text(subDesc)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected ? channel.themeColor.opacity(0.12) : Color.dynamicSecondaryBg
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? channel.themeColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func saveSkin() {
        let pPrice = Double(purchasePriceText) ?? 0.0
        let cPrice = Double(currentPriceText) ?? pPrice
        
        if var skin = editingSkin {
            skin.name = name.trimmingCharacters(in: .whitespaces)
            skin.category = category
            skin.wear = wear
            skin.purchasePrice = pPrice
            skin.currentPrice = cPrice
            skin.purchaseChannel = purchaseChannel
            skin.notes = notes
            store.updateSkin(skin)
        } else {
            let newSkin = SkinItem(
                name: name.trimmingCharacters(in: .whitespaces),
                category: category,
                wear: wear,
                purchasePrice: pPrice,
                currentPrice: cPrice,
                purchaseChannel: purchaseChannel,
                plans: [],
                notes: notes
            )
            store.addSkin(newSkin)
        }
        
        dismiss()
    }
}
