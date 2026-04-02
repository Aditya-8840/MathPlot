import SwiftUI

struct MarbleView: View {
    let screenX: CGFloat
    let screenY: CGFloat

    @State private var glowPulse = false
    @State private var innerRotation: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.accent.opacity(0.15))
                .frame(width: 34, height: 34)
                .blur(radius: 10)
                .scaleEffect(glowPulse ? 1.4 : 1.0)

            Circle()
                .fill(AppColors.accentPink.opacity(0.08))
                .frame(width: 26, height: 26)
                .blur(radius: 6)

            Circle()
                .fill(AppColors.marble)
                .frame(width: 18, height: 18)
                .shadow(color: AppColors.accent.opacity(0.8), radius: 6)
                .shadow(color: AppColors.accentPink.opacity(0.3), radius: 10)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.9), .clear],
                        center: .init(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: 7
                    )
                )
                .frame(width: 18, height: 18)

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            .white.opacity(0.4),
                            .clear,
                            .white.opacity(0.1),
                            .clear
                        ],
                        center: .center
                    ),
                    lineWidth: 1
                )
                .frame(width: 18, height: 18)
                .rotationEffect(.degrees(innerRotation))
        }
        .position(x: screenX, y: screenY)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true)
            ) {
                glowPulse = true
            }
            withAnimation(
                .linear(duration: 3)
                .repeatForever(autoreverses: false)
            ) {
                innerRotation = 360
            }
        }
    }
}

