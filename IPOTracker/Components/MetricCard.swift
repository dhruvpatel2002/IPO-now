import SwiftUI

// MARK: - Brand Color Definitions
public extension Color {
    /// Vibrant Sky Blue Primary Brand Color (#00A6ED)
    static let brandPrimary = Color(red: 0/255, green: 166/255, blue: 237/255)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography (Helvetica Unified Font System)
public extension Font {
    static func helvetica(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .heavy, .black:
            return .custom("Helvetica-Bold", size: size)
        case .bold:
            return .custom("Helvetica-Bold", size: size)
        case .semibold:
            return .custom("HelveticaNeue-Medium", size: size)
        case .medium:
            return .custom("HelveticaNeue-Medium", size: size)
        case .light, .ultraLight, .thin:
            return .custom("Helvetica-Light", size: size)
        default:
            return .custom("Helvetica", size: size)
        }
    }
}

// MARK: - Standard Metric Card
public struct MetricCard: View {
    public let title: String
    public let value: String
    public var subtitle: String? = nil
    public var iconName: String? = nil
    public var accentColor: Color = .brandPrimary
    
    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        iconName: String? = nil,
        accentColor: Color = .brandPrimary
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.iconName = iconName
        self.accentColor = accentColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.helvetica(12, weight: .regular))
                    .foregroundColor(.secondary)
                Spacer()
                if let iconName {
                    Image(systemName: iconName)
                        .font(.helvetica(12, weight: .regular))
                        .foregroundColor(accentColor)
                }
            }
            
            Text(value)
                .font(.helvetica(17, weight: .bold))
                .foregroundColor(.primary)
            
            if let subtitle {
                Text(subtitle)
                    .font(.helvetica(11, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.04), lineWidth: 1)
        )
    }
}

// MARK: - Block Metric Card Visual Style
public enum MetricVisualType {
    case bars      // Soundwave/subscription bars like Dribbble Mood card
    case ring      // Mini circular progress ring like Dribbble Freud Score card
    case dots      // Dot matrix grid like Dribbble Health Journal card
    case meter     // Horizontal progress meter
}

// MARK: - Block Metric Card (Solid Vibrant Color System inspired by Dribbble Widget UI)
public struct BlockMetricCard: View {
    public let title: String
    public let value: String
    public var subtitle: String? = nil
    public var iconName: String? = nil
    public var blockColor: Color
    public var visualType: MetricVisualType = .bars
    public var isLive: Bool = false
    
    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        iconName: String? = nil,
        blockColor: Color = .brandPrimary,
        visualType: MetricVisualType = .bars,
        isLive: Bool = false
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.iconName = iconName
        self.blockColor = blockColor
        self.visualType = visualType
        self.isLive = isLive
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Title + Optional Live Badge (No icon in front of text)
            HStack(alignment: .top) {
                Text(title)
                    .font(.helvetica(14, weight: .bold))
                    .foregroundColor(.white.opacity(0.95))
                    .lineLimit(1)
                
                Spacer(minLength: 4)
                
                if isLive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 5, height: 5)
                        Text("LIVE")
                            .font(.helvetica(9, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                    )
                }
            }
            
            // Value & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.helvetica(32, weight: .heavy))
                    .foregroundColor(.white)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.helvetica(11, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                }
            }
            .padding(.top, 4)
            
            Spacer(minLength: 6)
            
            // Bottom Graphic Visualizer (Aligned on LEFT corner)
            HStack {
                switch visualType {
                case .bars:
                    // Wave / soundwave bars on left
                    HStack(alignment: .bottom, spacing: 3.5) {
                        RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.4)).frame(width: 3.5, height: 8)
                        RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.6)).frame(width: 3.5, height: 15)
                        RoundedRectangle(cornerRadius: 2).fill(Color.white).frame(width: 3.5, height: 22)
                        RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.8)).frame(width: 3.5, height: 16)
                        RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.5)).frame(width: 3.5, height: 10)
                        RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.35)).frame(width: 3.5, height: 6)
                    }
                    .frame(height: 22)
                case .ring:
                    // Circular progress ring on left
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 3.5)
                            .frame(width: 22, height: 22)
                        Circle()
                            .trim(from: 0, to: 0.75)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                            .frame(width: 22, height: 22)
                            .rotationEffect(.degrees(-90))
                    }
                case .dots:
                    // Dot matrix grid on left
                    HStack(spacing: 3.5) {
                        VStack(spacing: 3.5) {
                            Circle().fill(Color.white.opacity(0.4)).frame(width: 4, height: 4)
                            Circle().fill(Color.white.opacity(0.4)).frame(width: 4, height: 4)
                            Circle().fill(Color.white).frame(width: 4, height: 4)
                        }
                        VStack(spacing: 3.5) {
                            Circle().fill(Color.white.opacity(0.4)).frame(width: 4, height: 4)
                            Circle().fill(Color.white).frame(width: 4, height: 4)
                            Circle().fill(Color.white.opacity(0.4)).frame(width: 4, height: 4)
                        }
                        VStack(spacing: 3.5) {
                            Circle().fill(Color.white).frame(width: 4, height: 4)
                            Circle().fill(Color.white.opacity(0.4)).frame(width: 4, height: 4)
                            Circle().fill(Color.white.opacity(0.4)).frame(width: 4, height: 4)
                        }
                    }
                case .meter:
                    // Mini segmented meter on left
                    HStack(spacing: 3) {
                        ForEach(0..<5) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(index < 3 ? Color.white : Color.white.opacity(0.35))
                                .frame(width: 6, height: 10)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 125, maxHeight: 125, alignment: .topLeading)
        .background(blockColor)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: blockColor.opacity(0.35), radius: 10, x: 0, y: 5)
    }
}

// Backward compatibility alias for views referencing GradientMetricCard
public typealias GradientMetricCard = BlockMetricCard

// MARK: - Primary Action Button
public struct PrimaryButton: View {
    public let title: String
    public var iconName: String? = nil
    public var isLoading: Bool = false
    public let action: () -> Void
    
    public init(
        title: String,
        iconName: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    if let iconName {
                        Image(systemName: iconName)
                            .font(.headline)
                    }
                    Text(title)
                        .font(.headline.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.brandPrimary)
            .foregroundColor(.white)
            .cornerRadius(14)
        }
        .disabled(isLoading)
    }
}
