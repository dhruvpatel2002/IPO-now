import SwiftUI

public struct SkeletonCard: View {
    @State private var isAnimating = false
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Name bar + badge placeholder
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(isAnimating ? 0.3 : 0.15))
                        .frame(width: 160, height: 18)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(isAnimating ? 0.25 : 0.12))
                        .frame(width: 90, height: 12)
                }
                Spacer()
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(isAnimating ? 0.3 : 0.15))
                    .frame(width: 70, height: 22)
            }
            
            Divider()
            
            // Key Info Grid
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.12))
                        .frame(width: 60, height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(isAnimating ? 0.3 : 0.18))
                        .frame(width: 85, height: 16)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.12))
                        .frame(width: 50, height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(isAnimating ? 0.3 : 0.18))
                        .frame(width: 75, height: 16)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.12))
                        .frame(width: 55, height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(isAnimating ? 0.3 : 0.18))
                        .frame(width: 80, height: 16)
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.04), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
