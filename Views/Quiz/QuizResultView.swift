import SwiftUI

struct QuizResultView: View {
    @ObservedObject var quizVM: QuizViewModel
    var onBack: () -> Void

    @State private var ringProgress: Double = 0
    @State private var scoreAppear = false
    @State private var starsAppear = false
    @State private var buttonsAppear = false
    @State private var particleBurst = false

    private var percentage: Double {
        Double(quizVM.score) / Double(quizVM.totalQuestions)
    }

    private var starCount: Int {
        switch quizVM.score {
        case 5: return 3
        case 4: return 2
        case 3: return 1
        default: return 0
        }
    }

    private var resultMessage: String {
        switch quizVM.score {
        case 5: return "Perfect Score! 🏆"
        case 4: return "Almost Perfect! 🌟"
        case 3: return "Good Job! 💪"
        case 2: return "Keep Practicing! 📚"
        default: return "Let's Try Again! 🔄"
        }
    }

    private var resultSubtext: String {
        switch quizVM.score {
        case 5: return "You've mastered \(quizVM.category.rawValue) functions!"
        case 4: return "You're almost there — just one more to go!"
        case 3: return "Solid understanding of the basics."
        case 2: return "Review the concepts and try again."
        default: return "Play more levels to strengthen your skills."
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(quizVM.category.color.opacity(0.08))
                    .frame(width: 180, height: 180)
                    .blur(radius: 30)
                    .scaleEffect(particleBurst ? 1.5 : 1.0)
                    .opacity(particleBurst ? 0.3 : 0.6)

                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 10)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        AngularGradient(
                            colors: [
                                quizVM.category.color,
                                quizVM.category.color.opacity(0.6),
                                quizVM.category.color
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(quizVM.score)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("out of \(quizVM.totalQuestions)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .scaleEffect(scoreAppear ? 1 : 0.5)
                .opacity(scoreAppear ? 1 : 0)
            }

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < starCount ? "star.fill" : "star")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            i < starCount
                                ? LinearGradient(colors: [AppColors.accentGold, .orange], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                        )
                        .scaleEffect(starsAppear ? 1 : 0)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.5)
                                .delay(0.6 + Double(i) * 0.15),
                            value: starsAppear
                        )
                }
            }

            VStack(spacing: 6) {
                Text(resultMessage)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(resultSubtext)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(scoreAppear ? 1 : 0)
            .offset(y: scoreAppear ? 0 : 20)

            HStack(spacing: 6) {
                ForEach(0..<quizVM.results.count, id: \.self) { i in
                    Circle()
                        .fill(quizVM.results[i] ? Color.green : Color.red.opacity(0.7))
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(.vertical, 4)
            .opacity(scoreAppear ? 1 : 0)

            Spacer()

            VStack(spacing: 10) {
                Button(action: {
                    withAnimation(.spring(response: 0.4)) {
                        ringProgress = 0
                        scoreAppear = false
                        starsAppear = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        quizVM.restart()
                        animateIn()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .bold))
                        Text("Retry Quiz")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [quizVM.category.color, quizVM.category.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: quizVM.category.color.opacity(0.4), radius: 16, y: 4)
                    )
                }

                Button(action: { onBack() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 14, weight: .bold))
                        Text("Back to Levels")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
            .offset(y: buttonsAppear ? 0 : 50)
            .opacity(buttonsAppear ? 1 : 0)
        }
        .onAppear { animateIn() }
    }

    private func animateIn() {
        withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
            ringProgress = percentage
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4)) {
            scoreAppear = true
        }
        withAnimation(.spring(response: 0.4).delay(0.6)) {
            starsAppear = true
        }
        withAnimation(.spring(response: 0.5).delay(0.8)) {
            buttonsAppear = true
        }
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) {
            particleBurst = true
        }
    }
}

