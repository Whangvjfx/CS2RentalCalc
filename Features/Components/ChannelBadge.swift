import SwiftUI

// MARK: - 购入渠道手续费标签组件
struct ChannelBadge: View {
    let channel: PurchaseChannel
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: channel.iconName)
                .font(.system(size: isCompact ? 10 : 12, weight: .semibold))
            
            Text(isCompact ? channel.shortTitle : "\(channel.shortTitle) • \(channel.feePercentageText)")
                .font(.system(size: isCompact ? 11 : 12, weight: .medium))
        }
        .padding(.horizontal, isCompact ? 7 : 10)
        .padding(.vertical, isCompact ? 3 : 5)
        .background(
            channel == .inPlatform
                ? Color.orange.opacity(0.12)
                : Color.purple.opacity(0.12)
        )
        .foregroundColor(
            channel == .inPlatform
                ? Color(red: 234/255, green: 88/255, blue: 12/255)
                : Color(red: 124/255, green: 58/255, blue: 237/255)
        )
        .clipShape(Capsule())
    }
}

// MARK: - 饰品品类与磨损小标签
struct CategoryWearBadge: View {
    let category: SkinCategory
    let wear: SkinWear
    
    var body: some View {
        HStack(spacing: 5) {
            Text(category.emoji)
                .font(.system(size: 11))
            Text(category.title)
                .font(.system(size: 11, weight: .medium))
            Text("•")
                .foregroundColor(.secondary)
                .font(.system(size: 10))
            Text(wear.shortCode)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(wear == .fn ? Theme.accentGold : .secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color.dynamicSecondaryBg)
        .clipShape(Capsule())
    }
}
