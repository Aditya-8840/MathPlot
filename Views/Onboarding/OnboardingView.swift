import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var currentPage = 0
    @State private var appeared = false

    private let totalPages = 3

    var body: some View {
        ZStack {
            AppColors.meshGradient.ignoresSafeArea()
            BackgroundStarsView().ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    WelcomePage().tag(0)
                    ShapeTheCurvePage().tag(1)
                    RollAndCollectPage(onGetStarted: onComplete).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentPage)

                pageIndicator
                    .padding(.bottom, 20)

                if currentPage < totalPages - 1 {
                    bottomButtons
                        .padding(.bottom, 40)
                        .transition(.opacity)
                } else {
                    Spacer().frame(height: 80)
                }
            }
        }
        .onAppear { appeared = true }
    }

    private var pageIndicator: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? pageColor(for: index) : Color.white.opacity(0.2))
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .shadow(
                        color: index == currentPage ? pageColor(for: index).opacity(0.6) : .clear,
                        radius: 6
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    private func pageColor(for index: Int) -> Color {
        switch index {
        case 0: return AppColors.accent
        case 1: return AppColors.accentPink
        case 2: return AppColors.accentGold
        default: return AppColors.accent
        }
    }

    private var bottomButtons: some View {
        HStack {
            Button(action: { onComplete() }) {
                Text("Skip")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentPage += 1
                }
            }) {
                HStack(spacing: 6) {
                    Text("Next")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [pageColor(for: currentPage), pageColor(for: currentPage).opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: pageColor(for: currentPage).opacity(0.5), radius: 16, y: 4)
                )
            }
        }
        .padding(.horizontal, 32)
    }
}

private struct WelcomePage: View {
    @State private var marbleScale: CGFloat = 0
    @State private var marbleGlow = false
    @State private var orbitAngle: Double = 0
    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var symbolsOpacity: Double = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                floatingSymbol("∫", offset: CGPoint(x: -100, y: -60), delay: 0.3, color: AppColors.accentPink)
                floatingSymbol("π", offset: CGPoint(x: 110, y: -40), delay: 0.5, color: AppColors.accentGold)
                floatingSymbol("Σ", offset: CGPoint(x: -80, y: 80), delay: 0.7, color: AppColors.functionLine)
                floatingSymbol("∞", offset: CGPoint(x: 90, y: 60), delay: 0.4, color: AppColors.accent)
                floatingSymbol("Δ", offset: CGPoint(x: 0, y: -100), delay: 0.6, color: AppColors.accentPink)

                ForEach(0..<3, id: \.self) { ring in
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    AppColors.accent.opacity(0.3),
                                    AppColors.accentPink.opacity(0.2),
                                    AppColors.accentGold.opacity(0.15),
                                    .clear
                                ],
                                center: .center
                            ),
                            lineWidth: 1.5
                        )
                        .frame(
                            width: CGFloat(90 + ring * 35),
                            height: CGFloat(90 + ring * 35)
                        )
                        .rotationEffect(.degrees(orbitAngle * (ring % 2 == 0 ? 1 : -1)))
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                }

                Circle()
                    .fill(AppColors.accent.opacity(0.12))
                    .frame(width: 100, height: 100)
                    .blur(radius: 30)
                    .scaleEffect(marbleGlow ? 1.5 : 1.0)

                Circle()
                    .fill(AppColors.marble)
                    .frame(width: 64, height: 64)
                    .shadow(color: AppColors.accent.opacity(0.8), radius: 20)
                    .shadow(color: AppColors.accentPink.opacity(0.3), radius: 30)
                    .overlay(
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.white.opacity(0.7), .clear],
                                    center: .init(x: 0.3, y: 0.25),
                                    startRadius: 0,
                                    endRadius: 26
                                )
                            )
                    )
                    .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                    .scaleEffect(marbleScale)
            }
            .frame(height: 240)

            VStack(spacing: 14) {
                Text("Welcome to")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Text("MathPlot")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
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

                Text("Where math becomes a game")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(2)
                    .opacity(subtitleOpacity)
            }

            Spacer()
            Spacer()
        }
        .onAppear { animateIn() }
    }

    private func floatingSymbol(_ symbol: String, offset: CGPoint, delay: Double, color: Color) -> some View {
        Text(symbol)
            .font(.system(size: 24, weight: .light, design: .rounded))
            .foregroundColor(color.opacity(0.3))
            .offset(x: offset.x, y: offset.y)
            .opacity(symbolsOpacity)
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.5).delay(0.2)) {
            marbleScale = 1.0
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            marbleGlow = true
        }
        withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
            orbitAngle = 360
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
            titleOffset = 0
            titleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
            subtitleOpacity = 1
        }
        withAnimation(.easeOut(duration: 1.0).delay(0.4)) {
            symbolsOpacity = 1
        }
    }
}

private struct ShapeTheCurvePage: View {
    @State private var wavePhase: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var cardOpacity: Double = 0
    @State private var cardOffset: CGFloat = 30
    @State private var sliderValue: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                AnimatedWaveShape(phase: wavePhase, amplitude: 40 * Double(sliderValue + 0.3))
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.accentPink.opacity(0.3), AppColors.accent.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 8
                    )
                    .blur(radius: 10)

                AnimatedWaveShape(phase: wavePhase, amplitude: 40 * Double(sliderValue + 0.3))
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.functionLine, AppColors.accent, AppColors.accentPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )

                VStack(spacing: 20) {
                    ForEach(0..<5, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.04))
                            .frame(height: 1)
                    }
                }
            }
            .frame(height: 160)
            .padding(.horizontal, 30)

            VStack(spacing: 8) {
                HStack {
                    Text("amplitude")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.accentPink.opacity(0.7))
                    Spacer()
                    Text(String(format: "%.1f", sliderValue * 5))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 40)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 6)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.accentPink, AppColors.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * sliderValue, height: 6)

                        Circle()
                            .fill(.white)
                            .frame(width: 20, height: 20)
                            .shadow(color: AppColors.accentPink.opacity(0.5), radius: 8)
                            .offset(x: geo.size.width * sliderValue - 10)
                    }
                }
                .frame(height: 20)
                .padding(.horizontal, 40)
            }
            .opacity(cardOpacity)
            .offset(y: cardOffset)

            VStack(spacing: 14) {
                Text("Shape the Curve")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.accentPink, AppColors.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Text("Adjust sliders to shape equations\nlike y = mx + c and y = a·sin(bx)")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
            }

            Spacer()
            Spacer()
        }
        .onAppear { animateIn() }
    }

    private func animateIn() {
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            wavePhase = .pi * 2
        }
        withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
            titleOpacity = 1
            titleOffset = 0
        }
        withAnimation(.easeOut(duration: 0.7).delay(0.4)) {
            cardOpacity = 1
            cardOffset = 0
        }
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) {
            sliderValue = 0.9
        }
    }
}

private struct AnimatedWaveShape: Shape {
    var phase: Double
    var amplitude: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(phase, amplitude) }
        set {
            phase = newValue.first
            amplitude = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        let width = rect.width
        let stepCount = 120

        for i in 0...stepCount {
            let x = width * CGFloat(i) / CGFloat(stepCount)
            let normalizedX = Double(i) / Double(stepCount) * 4 * .pi
            let y = midY + CGFloat(sin(normalizedX + phase) * amplitude)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}

private struct RollAndCollectPage: View {
    var onGetStarted: () -> Void

    @State private var marbleProgress: CGFloat = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var starsCollected = [false, false, false]
    @State private var starPulse = false
    @State private var buttonAppear = false

    private let starPositions: [CGFloat] = [0.25, 0.5, 0.75]

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                CurvePath()
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.functionLine.opacity(0.2), AppColors.functionLine.opacity(0.6), AppColors.functionLine.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 4])
                    )
                    .frame(height: 160)

                CurvePath()
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.functionLine, AppColors.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(height: 160)
                    .shadow(color: AppColors.functionLine.opacity(0.4), radius: 8)

                GeometryReader { geo in
                    ForEach(0..<3, id: \.self) { i in
                        let pos = starPosition(at: starPositions[i], in: geo.size)
                        ZStack {
                            Image(systemName: "star.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppColors.starGlow.opacity(0.3))
                                .scaleEffect(starPulse ? 1.5 : 1.1)
                                .blur(radius: 6)

                            Image(systemName: "star.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColors.accentGold, .orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: AppColors.starGlow, radius: 8)
                                .scaleEffect(starsCollected[i] ? 0 : 1)
                                .opacity(starsCollected[i] ? 0 : 1)
                        }
                        .position(x: pos.x, y: pos.y - 18)
                    }

                    let marblePos = marblePosition(progress: marbleProgress, in: geo.size)
                    ZStack {
                        Circle()
                            .fill(AppColors.accent.opacity(0.15))
                            .frame(width: 30, height: 30)
                            .blur(radius: 8)

                        Circle()
                            .fill(AppColors.marble)
                            .frame(width: 18, height: 18)
                            .shadow(color: AppColors.accent.opacity(0.8), radius: 8)
                            .shadow(color: AppColors.accentPink.opacity(0.3), radius: 12)
                            .overlay(
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [.white.opacity(0.8), .clear],
                                            center: .init(x: 0.3, y: 0.25),
                                            startRadius: 0,
                                            endRadius: 7
                                        )
                                    )
                            )
                    }
                    .position(x: marblePos.x, y: marblePos.y)
                }
                .frame(height: 160)
            }
            .padding(.horizontal, 30)

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: starsCollected[i] ? "star.fill" : "star")
                        .font(.system(size: 20))
                        .foregroundColor(starsCollected[i] ? AppColors.accentGold : .white.opacity(0.2))
                        .scaleEffect(starsCollected[i] ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: starsCollected[i])
                }
            }

            VStack(spacing: 14) {
                Text("Roll & Collect")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.accentGold, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Text("Roll the marble along your curve\nand collect stars to complete levels")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
            }

            Spacer()

            if buttonAppear {
                Button(action: { onGetStarted() }) {
                    HStack(spacing: 10) {
                        Text("Get Started")
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
                                    colors: [AppColors.accentGold, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: AppColors.accentGold.opacity(0.6), radius: 24, y: 4)
                    )
                    .overlay(
                        Capsule()
                            .fill(AppColors.shimmer)
                    )
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer().frame(height: 20)
        }
        .onAppear { animateIn() }
    }

    private func starPosition(at progress: CGFloat, in size: CGSize) -> CGPoint {
        let x = progress * size.width
        let y = size.height / 2 + sin(Double(progress) * .pi * 2) * 40
        return CGPoint(x: x, y: CGFloat(y))
    }

    private func marblePosition(progress: CGFloat, in size: CGSize) -> CGPoint {
        let x = progress * size.width
        let y = size.height / 2 + sin(Double(progress) * .pi * 2) * 40
        return CGPoint(x: x, y: CGFloat(y))
    }

    private func animateIn() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            starPulse = true
        }
        withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
            titleOpacity = 1
            titleOffset = 0
        }
        rollMarble()
        withAnimation(.spring(response: 0.5).delay(1.0)) {
            buttonAppear = true
        }
    }

    private func rollMarble() {
        marbleProgress = 0
        starsCollected = [false, false, false]

        withAnimation(.easeInOut(duration: 4).delay(0.5)) {
            marbleProgress = 1.0
        }

        for i in 0..<3 {
            let delay = 0.5 + Double(starPositions[i]) * 4.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    starsCollected[i] = true
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            rollMarble()
        }
    }
}

private struct CurvePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let steps = 100
        for i in 0...steps {
            let progress = CGFloat(i) / CGFloat(steps)
            let x = progress * rect.width
            let y = rect.height / 2 + CGFloat(sin(Double(progress) * .pi * 2) * 40)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}

