import SwiftUI

enum FunctionCategory: String, CaseIterable, Identifiable {
    case linear        = "Linear"
    case quadratic     = "Quadratic"
    case polynomial    = "Polynomial"
    case trigonometric = "Trigonometric"
    case exponential   = "Exponential"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .linear:        return "line.diagonal"
        case .quadratic:     return "point.topleft.down.to.point.bottomright.curvepath"
        case .polynomial:    return "chart.xyaxis.line"
        case .trigonometric: return "waveform.path"
        case .exponential:   return "arrow.up.right"
        }
    }

    var color: Color {
        switch self {
        case .linear:        return AppColors.accent
        case .quadratic:     return AppColors.accentPink
        case .polynomial:    return AppColors.accentGold
        case .trigonometric: return Color(red: 1.0, green: 0.5, blue: 0.3)
        case .exponential:   return Color(red: 0.9, green: 0.3, blue: 0.5)
        }
    }

    var formula: String {
        switch self {
        case .linear:        return "y = mx + c"
        case .quadratic:     return "y = ax² + bx + c"
        case .polynomial:    return "y = ax³ + bx + c"
        case .trigonometric: return "y = a·sin(bx + c)"
        case .exponential:   return "y = a·bˣ + c"
        }
    }

    var description: String {
        switch self {
        case .linear:        return "Straight lines with slope and intercept"
        case .quadratic:     return "Parabolas that open up or down"
        case .polynomial:    return "Cubic curves with twists and turns"
        case .trigonometric: return "Waves that oscillate up and down"
        case .exponential:   return "Rapidly growing or decaying curves"
        }
    }
}

