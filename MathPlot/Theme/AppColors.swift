import SwiftUI

struct AppColors {
    static let background = Color(red: 0.04, green: 0.04, blue: 0.12)
    static let cardBackground = Color(red: 0.08, green: 0.08, blue: 0.18)
    static let cardBackgroundLight = Color(red: 0.12, green: 0.12, blue: 0.22)

    static let gridMajor = Color.white.opacity(0.18)
    static let gridMinor = Color.white.opacity(0.05)

    static let accent = Color(red: 0.3, green: 0.8, blue: 1.0)
    static let accentPink = Color(red: 1.0, green: 0.4, blue: 0.7)
    static let accentGold = Color(red: 1.0, green: 0.85, blue: 0.3)
    static let functionLine = Color(red: 0.4, green: 1.0, blue: 0.6)
    static let starGlow = Color(red: 1.0, green: 0.9, blue: 0.3)

    static let marble = LinearGradient(
        colors: [
            Color(red: 0.4, green: 0.85, blue: 1.0),
            Color(red: 0.15, green: 0.35, blue: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glass = Color.white.opacity(0.06)
    static let glassBorder = Color.white.opacity(0.1)

    static let meshGradient = LinearGradient(
        colors: [
            Color(red: 0.1, green: 0.05, blue: 0.25),
            Color(red: 0.04, green: 0.04, blue: 0.12),
            Color(red: 0.05, green: 0.1, blue: 0.2)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let shimmer = LinearGradient(
        colors: [.clear, .white.opacity(0.05), .clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

