import SwiftUI

// MARK: - 常用关键指标小块
struct MetricItem: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var icon: String? = nil
    var iconColor: Color = Theme.primary
    var isPositive: Bool? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var valueColor: Color {
        if let isPositive = isPositive {
            return isPositive ? Theme.profitGreen : Theme.lossRed
        }
        return .primary
    }
}

// MARK: - 优雅带状态圆点的状态标签
struct StatusBadge: View {
    let status: RentalStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 6, height: 6)
            Text(status.title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(status.color.opacity(0.12))
        .clipShape(Capsule())
    }
}
