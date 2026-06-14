import SwiftUI

struct SplashView: View {
    var onStart: () -> Void
    
    @State private var titleOffset: CGFloat = -40
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var marbleScale: CGFloat = 0
    @State private var marbleGlow = false
    @State private var showButton = false
    @State private var orbitAngle: Double = 0
    @State private var backgroundPulse = false
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    
    var body: some View {
        ZStack {
            AppColors.meshGradient.ignoresSafeArea()
            BackgroundStarsView().ignoresSafeArea()
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColors.accent.opacity(0.08),
                            AppColors.accentPink.opacity(0.04),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 300
                    )
                )
                .scaleEffect(backgroundPulse ? 1.3 : 0.8)
                .opacity(backgroundPulse ? 0.6 : 0.3)
            
            VStack(spacing: 36) {
                Spacer()
                
                ZStack {
                    ForEach(0..<3, id: \.self) { ring in
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        AppColors.accent.opacity(0.3),
                                        AppColors.accentPink.opacity(0.2),
                                        AppColors.accentGold.opacity(0.1),
                                        .clear
                                    ],
                                    center: .center
                                ),
                                lineWidth: 1.5
                            )
                            .frame(
                                width: CGFloat(80 + ring * 30),
                                height: CGFloat(80 + ring * 30)
                            )
                            .rotationEffect(.degrees(orbitAngle * (ring % 2 == 0 ? 1 : -1)))
                            .scaleEffect(ringScale)
                            .opacity(ringOpacity)
                    }
                    
                    ForEach(0..<8, id: \.self) { i in
                        Circle()
                            .fill(
                                Color(
                                    hue: Double(i) / 8.0,
                                    saturation: 0.8,
                                    brightness: 1.0
                                )
                            )
                            .frame(width: CGFloat(4 + (i % 3) * 2), height: CGFloat(4 + (i % 3) * 2))
                            .offset(
                                x: CGFloat(40 + (i % 2) * 20) * cos(orbitAngle + Double(i) * .pi / 4),
                                y: CGFloat(40 + (i % 2) * 20) * sin(orbitAngle + Double(i) * .pi / 4)
                            )
                            .blur(radius: 1)
                            .opacity(0.8)
                    }
                    
                    Circle()
                        .fill(AppColors.accent.opacity(0.12))
                        .frame(width: 90, height: 90)
                        .blur(radius: 25)
                        .scaleEffect(marbleGlow ? 1.5 : 1.0)
                    
                    Circle()
                        .fill(AppColors.marble)
                        .frame(width: 56, height: 56)
                        .shadow(color: AppColors.accent.opacity(0.8), radius: 16)
                        .shadow(color: AppColors.accentPink.opacity(0.3), radius: 24)
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.white.opacity(0.7), .clear],
                                        center: .init(x: 0.3, y: 0.25),
                                        startRadius: 0,
                                        endRadius: 22
                                    )
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .scaleEffect(marbleScale)
                
                VStack(spacing: 10) {
                    Text("MathPlot")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.accent, AppColors.accentPink, AppColors.accentGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppColors.accent.opacity(0.3), radius: 12)
                        .offset(y: titleOffset)
                        .opacity(titleOpacity)
                    
                    Text("Graph · Roll · Discover")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(4)
                        .opacity(subtitleOpacity)
                }
                
                Spacer()
                
                if showButton {
                    Button(action: { onStart() }) {
                        HStack(spacing: 10) {
                            Text("Start Playing")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 44)
                        .padding(.vertical, 18)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.accent, AppColors.functionLine],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: AppColors.accent.opacity(0.6), radius: 24, y: 4)
                        )
                        .overlay(
                            Capsule()
                                .fill(AppColors.shimmer)
                        )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer().frame(height: 60)
            }
        }
        .onAppear { startAnimations() }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.5).delay(0.2)) {
            marbleScale = 1.0
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            marbleGlow = true
            backgroundPulse = true
        }
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
            orbitAngle = .pi * 2
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
            titleOffset = 0
            titleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
            subtitleOpacity = 1
        }
        withAnimation(.spring(response: 0.5).delay(1.5)) {
            showButton = true
        }
    }
}

