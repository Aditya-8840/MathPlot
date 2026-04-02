import SwiftUI

struct LevelCompleteView: View {
    @ObservedObject var viewModel: GameViewModel
    var onBackToLevels: () -> Void
    var onQuiz: () -> Void

    @State private var appear = false
    @State private var titleScale: CGFloat = 0.5
    @State private var buttonsOffset: CGFloat = 50

    var body: some View {
        ZStack {
            Color.black.opacity(appear ? 0.6 : 0)
                .ignoresSafeArea()

            ParticleView()
                .ignoresSafeArea()
                .opacity(appear ? 1 : 0)

            VStack(spacing: 20) {
                Text("⭐️ Level Complete! ⭐️")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.accentGold, .orange, AppColors.accentGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(titleScale)

                Text("You collected all \(viewModel.stars.count) star\(viewModel.stars.count > 1 ? "s" : "")!")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))

                HStack(spacing: 6) {
                    Image(systemName: viewModel.currentLevel.category.icon)
                        .foregroundColor(viewModel.currentLevel.category.color)
                    Text(viewModel.currentLevel.category.rawValue)
                        .foregroundColor(viewModel.currentLevel.category.color)
                    Text("·")
                        .foregroundColor(.white.opacity(0.3))
                    Text("Level \(viewModel.currentLevel.number)/10")
                        .foregroundColor(.white.opacity(0.7))
                }
                .font(.system(size: 12, weight: .semibold))

                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        Button(action: { viewModel.resetLevel() }) {
                            Label("Replay", systemImage: "arrow.counterclockwise")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.accentPink.opacity(0.8))
                                )
                        }

                        if viewModel.hasNextLevel {
                            Button(action: { _ = viewModel.nextLevel() }) {
                                Label("Next Level", systemImage: "arrow.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(AppColors.accentGold)
                                    )
                            }
                        } else {
                            Button(action: { onQuiz() }) {
                                Label("Take Quiz", systemImage: "brain.head.profile")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        viewModel.currentLevel.category.color,
                                                        viewModel.currentLevel.category.color.opacity(0.7)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                            }
                        }
                    }

                    Button(action: { onBackToLevels() }) {
                        Label("Back to Levels", systemImage: "square.grid.2x2")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
                .offset(y: buttonsOffset)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(AppColors.accentGold.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: AppColors.accentGold.opacity(0.3), radius: 30)
            )
            .padding(.horizontal, 24)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appear = true
                titleScale = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                buttonsOffset = 0
            }
        }
    }
}

