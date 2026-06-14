import SwiftUI

struct MathSlider: View {
    let label: String
    let symbol: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let color: Color
    let step: Double

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(symbol)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color.opacity(0.15))
                    )

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.35))

                Spacer()

                Text(String(format: "%.1f", value))
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                    .frame(width: 50, alignment: .trailing)
            }

            Slider(value: $value, in: range, step: step)
                .tint(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColors.glass)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppColors.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.2), color.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

