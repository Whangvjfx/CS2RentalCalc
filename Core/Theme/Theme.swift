import SwiftUI

// MARK: - App Theme (生活风 & 热情暖色调)
enum Theme {
    // 热情温暖的主色调
    static let primary = Color(red: 255/255, green: 107/255, blue: 61/255)       // 暖落日橙 #FF6B3D
    static let secondary = Color(red: 255/255, green: 159/255, blue: 67/255)    // 暖琥珀黄 #FF9F43
    static let accentGold = Color(red: 245/255, green: 158/255, blue: 11/255)   // 金色丰收 #F59E0B
    static let warmPeach = Color(red: 255/255, green: 121/255, blue: 107/255)   // 珊瑚蜜桃
    
    // 状态色彩
    static let profitGreen = Color(red: 16/255, green: 185/255, blue: 129/255)  // 盎然收益绿 #10B981
    static let lossRed = Color(red: 239/255, green: 68/255, blue: 68/255)       // 警示红 #EF4444
    static let inPlatform = Color(red: 249/255, green: 115/255, blue: 22/255)   // 平台内专属活力橙 (20%手续费)
    static let outPlatform = Color(red: 139/255, green: 92/255, blue: 246/255) // 平台外雅致紫 (25%手续费)
    
    // 背景与卡片色（自适应深浅色模式，均带有微暖的生活质感）
    static let background = Color("ThemeBackground", bundle: nil)
    static let cardBackground = Color("ThemeCardBackground", bundle: nil)
    
    // 渐变方案
    static let heroGradient = LinearGradient(
        colors: [Color(red: 255/255, green: 94/255, blue: 58/255), Color(red: 255/255, green: 153/255, blue: 102/255)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goldGradient = LinearGradient(
        colors: [Color(red: 245/255, green: 158/255, blue: 11/255), Color(red: 251/255, green: 191/255, blue: 36/255)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardBorderGradient = LinearGradient(
        colors: [Color.orange.opacity(0.18), Color.orange.opacity(0.04)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Semantic Helpers
extension Color {
    static var dynamicBg: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 24/255, green: 22/255, blue: 20/255, alpha: 1.0) // 暖深炭咖啡
                : UIColor(red: 253/255, green: 250/255, blue: 245/255, alpha: 1.0) // 温暖柔奶油白
        })
    }
    
    static var dynamicCardBg: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 35/255, green: 31/255, blue: 28/255, alpha: 1.0) // 暖岩黑卡片
                : UIColor(white: 1.0, alpha: 1.0) // 纯净白卡片
        })
    }
    
    static var dynamicSecondaryBg: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 45/255, green: 40/255, blue: 36/255, alpha: 1.0)
                : UIColor(red: 246/255, green: 241/255, blue: 233/255, alpha: 1.0)
        })
    }
}

// MARK: - View Modifiers
struct WarmCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var hasBorder: Bool = true
    
    func body(content: Content) -> some View {
        content
            .background(Color.dynamicCardBg)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(hasBorder ? Theme.cardBorderGradient : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func warmCard(cornerRadius: CGFloat = 20, hasBorder: Bool = true) -> some View {
        self.modifier(WarmCardModifier(cornerRadius: cornerRadius, hasBorder: hasBorder))
    }
    
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Formatters
enum AppFormatters {
    static func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "¥"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "¥%.2f", value)
    }
    
    static func currencyNoSymbol(_ value: Double) -> String {
        return String(format: "%.2f", value)
    }
    
    static func percent(_ value: Double, includeSign: Bool = true) -> String {
        let sign = (value > 0 && includeSign) ? "+" : ""
        return String(format: "%@%.1f%%", sign, value)
    }
    
    static func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
