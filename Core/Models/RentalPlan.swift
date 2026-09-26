import Foundation

// MARK: - 饰品出租计划与明细
struct RentalPlan: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var days: Int                    // 出租天数
    var dailyRent: Double            // 日租金 (元/天)
    var startDate: Date              // 起租日期
    var status: RentalStatus         // 状态 (出租中/已结清/待起租)
    var tenantNote: String           // 租客或平台订单号备注
    var createdAt: Date = Date()
    
    // 应收总租金毛额 = 天数 * 日租金
    var grossRent: Double {
        return Double(max(0, days)) * max(0, dailyRent)
    }
    
    // 扣除的平台手续费 (根据饰品的渠道：平台内 0.20，平台外 0.25)
    func feeAmount(channel: PurchaseChannel) -> Double {
        return grossRent * channel.feeRate
    }
    
    // 实际到手净租金 = 毛租金 * (1 - 手续费率)
    func netRent(channel: PurchaseChannel) -> Double {
        return grossRent * (1.0 - channel.feeRate)
    }
    
    // 计划结束日期
    var endDate: Date {
        Calendar.current.date(byAdding: .day, value: days, to: startDate) ?? startDate
    }
}
