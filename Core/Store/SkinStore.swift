import Foundation
import SwiftUI
import Combine

// MARK: - 核心数据存储与业务状态管理器
class SkinStore: ObservableObject {
    @Published var skins: [SkinItem] = [] {
        didSet {
            saveToDisk()
        }
    }
    
    private let fileName = "cs2_rental_skins.json"
    
    init() {
        loadFromDisk()
        if skins.isEmpty {
            preloadSampleData()
        }
    }
    
    // MARK: - 文件持久化
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(skins)
            try data.write(to: fileURL, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Failed to save skins to disk: \(error)")
        }
    }
    
    func loadFromDisk() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([SkinItem].self, from: data)
            self.skins = decoded
        } catch {
            print("Failed to load skins from disk: \(error)")
        }
    }
    
    // MARK: - 饰品 CRUD
    func addSkin(_ skin: SkinItem) {
        skins.insert(skin, at: 0)
    }
    
    func updateSkin(_ skin: SkinItem) {
        if let index = skins.firstIndex(where: { $0.id == skin.id }) {
            skins[index] = skin
        }
    }
    
    func deleteSkin(at offsets: IndexSet) {
        skins.remove(atOffsets: offsets)
    }
    
    func deleteSkin(id: UUID) {
        skins.removeAll(where: { $0.id == id })
    }
    
    // 随时修改现价（核心高频操作）
    func updateCurrentPrice(for skinId: UUID, newPrice: Double) {
        if let index = skins.firstIndex(where: { $0.id == skinId }) {
            skins[index].currentPrice = max(0, newPrice)
        }
    }
    
    // MARK: - 出租计划 CRUD
    func addRentalPlan(to skinId: UUID, plan: RentalPlan) {
        if let index = skins.firstIndex(where: { $0.id == skinId }) {
            skins[index].plans.insert(plan, at: 0)
        }
    }
    
    func updateRentalPlan(skinId: UUID, plan: RentalPlan) {
        guard let sIndex = skins.firstIndex(where: { $0.id == skinId }),
              let pIndex = skins[sIndex].plans.firstIndex(where: { $0.id == plan.id }) else { return }
        skins[sIndex].plans[pIndex] = plan
    }
    
    func deleteRentalPlan(skinId: UUID, planId: UUID) {
        if let index = skins.firstIndex(where: { $0.id == skinId }) {
            skins[index].plans.removeAll(where: { $0.id == planId })
        }
    }
    
    func togglePlanStatus(skinId: UUID, planId: UUID) {
        guard let sIndex = skins.firstIndex(where: { $0.id == skinId }),
              let pIndex = skins[sIndex].plans.firstIndex(where: { $0.id == planId }) else { return }
        let current = skins[sIndex].plans[pIndex].status
        skins[sIndex].plans[pIndex].status = (current == .renting) ? .completed : .renting
    }
    
    // MARK: - 全局收益汇总与关键财务指标
    
    // 总购入成本
    var totalPurchaseCost: Double {
        skins.reduce(0) { $0 + $1.purchasePrice }
    }
    
    // 总资产当前现值
    var totalCurrentValue: Double {
        skins.reduce(0) { $0 + $1.currentPrice }
    }
    
    // 饰品资产总浮动盈亏 (现价 - 购入价)
    var totalFloatingPL: Double {
        totalCurrentValue - totalPurchaseCost
    }
    
    // 饰品资产总浮动盈亏率 (%)
    var totalFloatingPLPercent: Double {
        guard totalPurchaseCost > 0 else { return 0 }
        return (totalFloatingPL / totalPurchaseCost) * 100.0
    }
    
    // 累计应收租金毛额
    var totalGrossRentalIncome: Double {
        skins.reduce(0) { $0 + $1.totalGrossRent }
    }
    
    // 平台扣除手续费总额 (平台内0.2 + 平台外0.25)
    var totalFeesPaid: Double {
        skins.reduce(0) { $0 + $1.totalFeePaid }
    }
    
    // 累计实际到手净租金
    var totalNetRentalIncome: Double {
        skins.reduce(0) { $0 + $1.totalNetRent }
    }
    
    // 🌟 终极综合总净利润 = 累计实际到手净租金 + 饰品资产浮动盈亏
    var grandTotalNetProfit: Double {
        totalNetRentalIncome + totalFloatingPL
    }
    
    // 综合投资回报率 ROI (%)
    var overallROI: Double {
        guard totalPurchaseCost > 0 else { return 0 }
        return (grandTotalNetProfit / totalPurchaseCost) * 100.0
    }
    
    // 租金累计回本进度 (%)
    var overallRentalPaybackRate: Double {
        guard totalPurchaseCost > 0 else { return 0 }
        return (totalNetRentalIncome / totalPurchaseCost) * 100.0
    }
    
    // 当前在租日租金毛额
    var todayActiveDailyGross: Double {
        skins.reduce(0) { $0 + $1.activeDailyRent }
    }
    
    // 当前在租日到手净租金 (已预先扣除各自 0.2 或 0.25 扣点)
    var todayActiveDailyNet: Double {
        skins.reduce(0) { total, skin in
            let dailyNetForSkin = skin.plans
                .filter { $0.status == .renting }
                .reduce(0) { $0 + ($1.dailyRent * (1.0 - skin.purchaseChannel.feeRate)) }
            return total + dailyNetForSkin
        }
    }
    
    // 平台内 vs 平台外 统计
    var inPlatformSkins: [SkinItem] {
        skins.filter { $0.purchaseChannel == .inPlatform }
    }
    
    var outPlatformSkins: [SkinItem] {
        skins.filter { $0.purchaseChannel == .outPlatform }
    }
    
    var inPlatformNetRent: Double {
        inPlatformSkins.reduce(0) { $0 + $1.totalNetRent }
    }
    
    var outPlatformNetRent: Double {
        outPlatformSkins.reduce(0) { $0 + $1.totalNetRent }
    }
    
    var inPlatformFeesPaid: Double {
        inPlatformSkins.reduce(0) { $0 + $1.totalFeePaid }
    }
    
    var outPlatformFeesPaid: Double {
        outPlatformSkins.reduce(0) { $0 + $1.totalFeePaid }
    }
    
    // 洞察：如果所有平台外订单此前走平台内(20%而非25%)，能多省下的手续费 (5% 差额)
    var potentialFeeSavings: Double {
        outPlatformSkins.reduce(0) { total, skin in
            total + (skin.totalGrossRent * 0.05)
        }
    }
    
    // MARK: - 预置精美真实数据 (生活风开箱体验)
    func preloadSampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        let sample1 = SkinItem(
            name: "蝴蝶刀 (★) | 渐变大理石",
            category: .knife,
            wear: .fn,
            purchasePrice: 11800.00,
            currentPrice: 12650.00,
            purchaseChannel: .inPlatform, // 平台内 20%
            plans: [
                RentalPlan(
                    days: 14,
                    dailyRent: 65.0,
                    startDate: calendar.date(byAdding: .day, value: -20, to: today) ?? today,
                    status: .completed,
                    tenantNote: "悠悠租客A(短租体验)"
                ),
                RentalPlan(
                    days: 30,
                    dailyRent: 62.0,
                    startDate: calendar.date(byAdding: .day, value: -5, to: today) ?? today,
                    status: .renting,
                    tenantNote: "老客户包月长租"
                )
            ],
            notes: "红顶完美渐变，行情坚挺"
        )
        
        let sample2 = SkinItem(
            name: "AK-47 | 印花集",
            category: .rifle,
            wear: .fn,
            purchasePrice: 1850.00,
            currentPrice: 1980.00,
            purchaseChannel: .outPlatform, // 平台外 25%
            plans: [
                RentalPlan(
                    days: 7,
                    dailyRent: 15.0,
                    startDate: calendar.date(byAdding: .day, value: -12, to: today) ?? today,
                    status: .completed,
                    tenantNote: "贴纸四连泰坦印花周租"
                ),
                RentalPlan(
                    days: 15,
                    dailyRent: 14.5,
                    startDate: calendar.date(byAdding: .day, value: -3, to: today) ?? today,
                    status: .renting,
                    tenantNote: "五一假期租单"
                )
            ],
            notes: "四连镭射，租金溢价很高"
        )
        
        let sample3 = SkinItem(
            name: "M4A4 | 咆哮",
            category: .rifle,
            wear: .mw,
            purchasePrice: 38000.00,
            currentPrice: 37200.00,
            purchaseChannel: .inPlatform, // 平台内 20%
            plans: [
                RentalPlan(
                    days: 30,
                    dailyRent: 180.0,
                    startDate: calendar.date(byAdding: .day, value: -40, to: today) ?? today,
                    status: .completed,
                    tenantNote: "高端战队季租期1"
                ),
                RentalPlan(
                    days: 30,
                    dailyRent: 180.0,
                    startDate: calendar.date(byAdding: .day, value: -8, to: today) ?? today,
                    status: .renting,
                    tenantNote: "高端战队季租期2"
                )
            ],
            notes: "绝版传家宝，稳定收租印钞机"
        )
        
        let sample4 = SkinItem(
            name: "运动手套 (★) | 迈阿密风云",
            category: .gloves,
            wear: .ft,
            purchasePrice: 9200.00,
            currentPrice: 9600.00,
            purchaseChannel: .outPlatform, // 平台外 25%
            plans: [
                RentalPlan(
                    days: 10,
                    dailyRent: 48.0,
                    startDate: calendar.date(byAdding: .day, value: -18, to: today) ?? today,
                    status: .completed,
                    tenantNote: "搭配蝴蝶刀套餐租"
                ),
                RentalPlan(
                    days: 20,
                    dailyRent: 45.0,
                    startDate: calendar.date(byAdding: .day, value: -6, to: today) ?? today,
                    status: .renting,
                    tenantNote: "暑期长租计划"
                )
            ],
            notes: "磨损0.21，双右手无破皮"
        )
        
        let sample5 = SkinItem(
            name: "AWP | 二乃 (二硫化物)",
            category: .sniper,
            wear: .fn,
            purchasePrice: 680.00,
            currentPrice: 720.00,
            purchaseChannel: .inPlatform, // 平台内 20%
            plans: [
                RentalPlan(
                    days: 14,
                    dailyRent: 6.5,
                    startDate: calendar.date(byAdding: .day, value: -15, to: today) ?? today,
                    status: .completed,
                    tenantNote: "学生党半月租"
                )
            ],
            notes: "高性价比热门快租枪"
        )
        
        self.skins = [sample1, sample2, sample3, sample4, sample5]
    }
    
    func resetToDemoData() {
        preloadSampleData()
    }
    
    func clearAllData() {
        skins.removeAll()
    }
}
