import SwiftUI

struct StarShapeView: View {
    let star: Star
    let screenX: CGFloat
    let screenY: CGFloat

    @State private var pulse = false
    @State private var collected = false

    var body: some View {
        ZStack {
            if !star.isCollected {
                Image(systemName: "star.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.starGlow.opacity(0.3))
                    .scaleEffect(pulse ? 1.5 : 1.2)
                    .blur(radius: 6)
                    .position(x: screenX, y: screenY)

                Image(systemName: "star.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.accentGold, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: AppColors.starGlow, radius: 8)
                    .scaleEffect(pulse ? 1.1 : 0.95)
                    .position(x: screenX, y: screenY)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true)
                        ) {
                            pulse = true
                        }
                    }
            } else {
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(AppColors.starGlow)
                        .frame(width: 4, height: 4)
                        .offset(
                            x: collected ? cos(Double(i) * .pi / 4) * 30 : 0,
                            y: collected ? sin(Double(i) * .pi / 4) * 30 : 0
                        )
                        .opacity(collected ? 0 : 1)
                        .position(x: screenX, y: screenY)
                }

                Image(systemName: "star.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.starGlow)
                    .scaleEffect(collected ? 2.0 : 1.0)
                    .opacity(collected ? 0 : 1)
                    .position(x: screenX, y: screenY)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.5)) {
                            collected = true
                        }
                    }
            }
        }
    }
}

