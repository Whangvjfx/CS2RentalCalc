import Foundation

// MARK: - CS2 饰品数据模型
struct SkinItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String                         // 饰品名称，例如 "蝴蝶刀 (★) | 渐变大理石"
    var category: SkinCategory               // 分类：匕首、手套、步枪等
    var wear: SkinWear                       // 磨损等级
    var purchasePrice: Double                // 购入成本价 (¥)
    var currentPrice: Double                 // 当前市场价格 (¥ - 随时由用户调整波动)
    var purchaseChannel: PurchaseChannel     // 渠道：平台内 (0.2手续费) vs 平台外 (0.25手续费)
    var plans: [RentalPlan] = []             // 该饰品历次出租计划列表
    var notes: String = ""                   // 备注信息
    var createdAt: Date = Date()
    
    // MARK: - 核心收益统计计算
    
    // 1. 累计应收租金毛额
    var totalGrossRent: Double {
        plans.reduce(0) { $0 + $1.grossRent }
    }
    
    // 2. 累计扣除的手续费 (平台内扣 20%，平台外扣 25%)
    var totalFeePaid: Double {
        plans.reduce(0) { $0 + $1.feeAmount(channel: purchaseChannel) }
    }
    
    // 3. 累计实际到手净租金
    var totalNetRent: Double {
        plans.reduce(0) { $0 + $1.netRent(channel: purchaseChannel) }
    }
    
    // 4. 饰品资产本身浮动盈亏 = 现价 - 购入价
    var floatingPL: Double {
        currentPrice - purchasePrice
    }
    
    // 5. 饰品资产浮动盈亏比例 (%)
    var floatingPLPercent: Double {
        guard purchasePrice > 0 else { return 0 }
        return (floatingPL / purchasePrice) * 100.0
    }
    
    // 6. 该饰品综合总净利润 = 累计实际到手净租金 + 饰品浮动盈亏 (现价 - 购入价)
    var totalNetProfit: Double {
        totalNetRent + floatingPL
    }
    
    // 7. 本金回本率 = 实际到手租金 / 购入成本 (%)
    var paybackRate: Double {
        guard purchasePrice > 0 else { return 0 }
        return (totalNetRent / purchasePrice) * 100.0
    }
    
    // 8. 累计出租天数
    var totalRentalDays: Int {
        plans.reduce(0) { $0 + $1.days }
    }
    
    // 9. 当前在租中的日租金合计
    var activeDailyRent: Double {
        plans.filter { $0.status == .renting }.reduce(0) { $0 + $1.dailyRent }
    }
    
    // 10. 当前正在出租中的计划数量
    var activePlansCount: Int {
        plans.filter { $0.status == .renting }.count
    }
    
    // 11. 测算距离完全回本还需天数 (基于当前日租金与净到手率)
    var daysToBreakeven: Int? {
        let remainingCost = purchasePrice - totalNetRent
        guard remainingCost > 0 else { return 0 } // 已完全收回购入成本
        let effectiveDailyNet = activeDailyRent * (1.0 - purchaseChannel.feeRate)
        guard effectiveDailyNet > 0 else { return nil }
        return Int(ceil(remainingCost / effectiveDailyNet))
    }
}
