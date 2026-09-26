import SwiftUI

struct QuickPriceAdjustSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: SkinStore
    
    // 临时价格字典，便于批量输入与撤销
    @State private var priceInputs: [UUID: String] = [:]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(Theme.primary)
                            Text("CS2 饰品行情波动调整")
                                .font(.system(size: 15, weight: .bold))
                        }
                        Text("饰品市场价随时变化，您可以在此一次性更新多件饰品的最新现价。保存后系统将重新计算您的总净利润和资产浮动盈亏。")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    ForEach(store.skins) { skin in
                        HStack(spacing: 12) {
                            Text(skin.category.emoji)
                                .font(.system(size: 20))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(skin.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .lineLimit(1)
                                
                                HStack(spacing: 4) {
                                    Text("购入: \(AppFormatters.currency(skin.purchasePrice))")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // 输入框
                            HStack(spacing: 4) {
                                Text("¥")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                TextField("现价", text: Binding(
                                    get: {
                                        priceInputs[skin.id] ?? String(format: "%.2f", skin.currentPrice)
                                    },
                                    set: { newValue in
                                        priceInputs[skin.id] = newValue
                                    }
                                ))
                                .keyboardType(.decimalPad)
                                .frame(width: 85)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.dynamicSecondaryBg)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("饰品列表 (\(store.skins.count))")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("行情调价面板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("全部应用") {
                        applyAllPriceChanges()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Theme.primary)
                }
            }
        }
    }
    
    private func applyAllPriceChanges() {
        for (id, text) in priceInputs {
            if let newPrice = Double(text) {
                store.updateCurrentPrice(for: id, newPrice: newPrice)
            }
        }
        hapticFeedback()
        dismiss()
    }
}
