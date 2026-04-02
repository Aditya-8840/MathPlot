import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    var onBack: () -> Void
    var onBackToLevels: () -> Void
    var onQuiz: () -> Void

    @State private var is3DMode = false
    @State private var showInfoSheet = false

    var body: some View {
        ZStack {
            AppColors.meshGradient.ignoresSafeArea()
            BackgroundStarsView().ignoresSafeArea().opacity(0.3)

            VStack(spacing: 8) {
                topBar
                HUDView(viewModel: viewModel)
                graphSection
                equationBar
                slidersSection
                runButton
            }

            if viewModel.showCelebration {
                LevelCompleteView(viewModel: viewModel, onBackToLevels: onBackToLevels, onQuiz: onQuiz)
                    .transition(.opacity)
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            EquationInfoSheet(viewModel: viewModel)
        }
    }

    private var equationBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "function")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(viewModel.currentLevel.category.color)

            Text(viewModel.equationString)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(AppColors.functionLine)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Spacer()

            Button(action: { showInfoSheet = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                    Text("Info")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            viewModel.currentLevel.category.color,
                            viewModel.currentLevel.category.color.opacity(0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(viewModel.currentLevel.category.color.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(viewModel.currentLevel.category.color.opacity(0.25), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.functionLine.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    private var topBar: some View {
        HStack {
            Button(action: { onBack() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(AppColors.glass)
                            .overlay(Circle().stroke(AppColors.glassBorder, lineWidth: 1))
                    )
            }

            Spacer()

            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.currentLevel.category.icon)
                        .font(.system(size: 10))
                        .foregroundColor(viewModel.currentLevel.category.color)
                    Text(viewModel.currentLevel.category.rawValue)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(viewModel.currentLevel.category.color)
                }
                Text(viewModel.currentLevel.description)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)

            Spacer()

            HStack(spacing: 8) {
                Button(action: {
                    withAnimation(.spring(response: 0.4)) {
                        is3DMode.toggle()
                    }
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: is3DMode ? "square.fill" : "cube.fill")
                            .font(.system(size: 11))
                        Text(is3DMode ? "2D" : "3D")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(is3DMode ? AppColors.accent : .white.opacity(0.6))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(is3DMode ? AppColors.accent.opacity(0.15) : AppColors.glass)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        is3DMode ? AppColors.accent.opacity(0.4) : AppColors.glassBorder,
                                        lineWidth: 1
                                    )
                            )
                    )
                }

                Button(action: { viewModel.resetLevel() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.accentPink)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(AppColors.glass)
                                .overlay(Circle().stroke(AppColors.glassBorder, lineWidth: 1))
                        )
                }
            }
        }
        .padding(.horizontal)
    }

    private var graphSection: some View {
        GeometryReader { geo in
            let side = min(geo.size.width - 20, geo.size.height)
            Graph3DContainerView(
                viewModel: viewModel,
                size: CGSize(width: side, height: side),
                is3DMode: $is3DMode
            )
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity)
        }
    }

    private var slidersSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 6) {
                let config = viewModel.currentLevel.sliderConfig
                if config.showM { MathSlider(label: config.mLabel, symbol: "m", value: $viewModel.paramM, range: config.mRange, color: AppColors.accent, step: 0.1) }
                if config.showA { MathSlider(label: config.aLabel, symbol: "a", value: $viewModel.paramA, range: config.aRange, color: AppColors.accentGold, step: 0.1) }
                if config.showB { MathSlider(label: config.bLabel, symbol: "b", value: $viewModel.paramB, range: config.bRange, color: Color(red: 0.6, green: 0.4, blue: 1.0), step: 0.1) }
                if config.showC { MathSlider(label: config.cLabel, symbol: "c", value: $viewModel.paramC, range: config.cRange, color: AppColors.accentPink, step: 0.1) }
                if config.showH { MathSlider(label: config.hLabel, symbol: "h", value: $viewModel.paramH, range: config.hRange, color: Color(red: 0.3, green: 1.0, blue: 0.7), step: 0.1) }
                if config.showK { MathSlider(label: config.kLabel, symbol: "k", value: $viewModel.paramK, range: config.kRange, color: Color(red: 1.0, green: 0.5, blue: 0.3), step: 0.1) }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 170)
        .disabled(viewModel.isRunning)
        .opacity(viewModel.isRunning ? 0.4 : 1)
    }

    private var runButton: some View {
        Button(action: { viewModel.runMarble() }) {
            HStack(spacing: 10) {
                Image(systemName: viewModel.isRunning ? "hourglass" : "play.fill")
                    .font(.system(size: 16))
                Text(viewModel.isRunning ? "Rolling..." : "Run Marble")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        viewModel.isRunning
                            ? AnyShapeStyle(Color.gray.opacity(0.5))
                            : AnyShapeStyle(
                                LinearGradient(
                                    colors: [AppColors.accent, AppColors.functionLine],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .overlay(RoundedRectangle(cornerRadius: 16).fill(AppColors.shimmer))
                    .shadow(
                        color: viewModel.isRunning ? .clear : AppColors.accent.opacity(0.4),
                        radius: 16, y: 4
                    )
            )
        }
        .disabled(viewModel.isRunning)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

