import SwiftUI

// MARK: - 购入渠道 (平台内 vs 平台外，对应手续费 0.20 vs 0.25)
enum PurchaseChannel: String, Codable, CaseIterable, Identifiable {
    case inPlatform = "in_platform"   // 平台内购入
    case outPlatform = "out_platform" // 平台外购入
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .inPlatform: return "平台内购入"
        case .outPlatform: return "平台外购入"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .inPlatform: return "平台内"
        case .outPlatform: return "平台外"
        }
    }
    
    // 手续费率：平台内收取 0.20 (20%)，平台外收取 0.25 (25%)
    var feeRate: Double {
        switch self {
        case .inPlatform: return 0.20
        case .outPlatform: return 0.25
        }
    }
    
    var feePercentageText: String {
        switch self {
        case .inPlatform: return "20% 手续费"
        case .outPlatform: return "25% 手续费"
        }
    }
    
    var tagDescription: String {
        switch self {
        case .inPlatform: return "实收到手 80% 租金 (扣除 0.2 手续费)"
        case .outPlatform: return "实收到手 75% 租金 (扣除 0.25 手续费)"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .inPlatform: return Theme.inPlatform
        case .outPlatform: return Theme.outPlatform
        }
    }
    
    var iconName: String {
        switch self {
        case .inPlatform: return "cart.badge.plus"
        case .outPlatform: return "arrow.up.right.video"
        }
    }
}

// MARK: - 饰品品类
enum SkinCategory: String, Codable, CaseIterable, Identifiable {
    case knife = "knife"
    case gloves = "gloves"
    case rifle = "rifle"
    case sniper = "sniper"
    case pistol = "pistol"
    case other = "other"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .knife: return "匕首"
        case .gloves: return "手套"
        case .rifle: return "步枪"
        case .sniper: return "狙击枪"
        case .pistol: return "手枪"
        case .other: return "探员/印花/其它"
        }
    }
    
    var emoji: String {
        switch self {
        case .knife: return "🗡️"
        case .gloves: return "🧤"
        case .rifle: return "🔫"
        case .sniper: return "🎯"
        case .pistol: return "⚡️"
        case .other: return "📦"
        }
    }
}

// MARK: - 饰品磨损
enum SkinWear: String, Codable, CaseIterable, Identifiable {
    case fn = "Factory New"
    case mw = "Minimal Wear"
    case ft = "Field-Tested"
    case ww = "Well-Worn"
    case bs = "Battle-Scarred"
    case none = "Not Applicable"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .fn: return "崭新出厂"
        case .mw: return "略有磨损"
        case .ft: return "久经沙场"
        case .ww: return "破损不堪"
        case .bs: return "战痕累累"
        case .none: return "普通 / 无磨损"
        }
    }
    
    var shortCode: String {
        switch self {
        case .fn: return "FN"
        case .mw: return "MW"
        case .ft: return "FT"
        case .ww: return "WW"
        case .bs: return "BS"
        case .none: return "--"
        }
    }
}

// MARK: - 出租计划状态
enum RentalStatus: String, Codable, CaseIterable, Identifiable {
    case renting = "renting"       // 出租中
    case completed = "completed"   // 已结清收租
    case planned = "planned"       // 待起租
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .renting: return "出租中"
        case .completed: return "已结清收租"
        case .planned: return "待起租计划"
        }
    }
    
    var iconName: String {
        switch self {
        case .renting: return "clock.fill"
        case .completed: return "checkmark.seal.fill"
        case .planned: return "calendar.badge.clock"
        }
    }
    
    var color: Color {
        switch self {
        case .renting: return Theme.profitGreen
        case .completed: return Theme.secondary
        case .planned: return Color.gray
        }
    }
}
