import SwiftUI

struct QuizView: View {
    @StateObject var quizVM: QuizViewModel
    var onBack: () -> Void
    var onComplete: ((FunctionCategory) -> Void)? = nil

    @State private var questionAppear = false
    @State private var optionsAppear = false
    @State private var explanationAppear = false
    @State private var shakeWrong = false

    var body: some View {
        ZStack {
            AppColors.meshGradient.ignoresSafeArea()
            BackgroundStarsView().ignoresSafeArea().opacity(0.4)

            Circle()
                .fill(quizVM.category.color.opacity(0.06))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(y: -200)

            if quizVM.isComplete {
                QuizResultView(quizVM: quizVM, onBack: onBack)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else {
                VStack(spacing: 0) {
                    topBar
                    progressBar
                    questionContent
                }
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: quizVM.isComplete)
        .onChange(of: quizVM.isComplete) { complete in
            if complete {
                onComplete?(quizVM.category)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: { onBack() }) {
                Image(systemName: "xmark")
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

            HStack(spacing: 6) {
                Image(systemName: quizVM.category.icon)
                    .font(.system(size: 11))
                    .foregroundColor(quizVM.category.color)
                Text(quizVM.category.rawValue + " Quiz")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(AppColors.glass)
                    .overlay(
                        Capsule()
                            .stroke(quizVM.category.color.opacity(0.3), lineWidth: 1)
                    )
            )

            Spacer()

            Text("\(quizVM.currentIndex + 1)/\(quizVM.totalQuestions)")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
                .padding(10)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [quizVM.category.color, quizVM.category.color.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * quizVM.progress, height: 4)
                    .animation(.spring(response: 0.4), value: quizVM.progress)
            }
        }
        .frame(height: 4)
        .padding(.horizontal)
        .padding(.top, 12)
    }

    private var questionContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Question \(quizVM.currentIndex + 1)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(quizVM.category.color)
                    .tracking(2)
                    .padding(.top, 24)

                Text(quizVM.currentQuestion.question)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .scaleEffect(questionAppear ? 1 : 0.9)
                    .opacity(questionAppear ? 1 : 0)

                VStack(spacing: 10) {
                    ForEach(Array(quizVM.currentQuestion.options.enumerated()), id: \.offset) { index, option in
                        optionButton(index: index, text: option)
                            .offset(y: optionsAppear ? 0 : 30)
                            .opacity(optionsAppear ? 1 : 0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.75)
                                    .delay(Double(index) * 0.08),
                                value: optionsAppear
                            )
                    }
                }
                .padding(.horizontal)

                if quizVM.isAnswered {
                    explanationCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if quizVM.isAnswered {
                    Button(action: {
                        withAnimation(.spring(response: 0.4)) {
                            questionAppear = false
                            optionsAppear = false
                            explanationAppear = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            quizVM.nextQuestion()
                            animateQuestionIn()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(quizVM.currentIndex + 1 < quizVM.totalQuestions ? "Next Question" : "See Results")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Image(systemName: quizVM.currentIndex + 1 < quizVM.totalQuestions ? "arrow.right" : "star.fill")
                                .font(.system(size: 14, weight: .bold))
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
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer().frame(height: 40)
            }
        }
        .onAppear { animateQuestionIn() }
        .onChange(of: quizVM.currentIndex) { _ in
            animateQuestionIn()
        }
    }

    private func optionButton(index: Int, text: String) -> some View {
        let isSelected = quizVM.selectedAnswer == index
        let isCorrectOption = index == quizVM.currentQuestion.correctIndex
        let showCorrect = quizVM.isAnswered && isCorrectOption
        let showWrong = quizVM.isAnswered && isSelected && !isCorrectOption

        return Button(action: {
            withAnimation(.spring(response: 0.3)) {
                quizVM.selectAnswer(index)
            }
            if !isCorrectOption && quizVM.selectedAnswer == index {
                withAnimation(.spring(response: 0.15).repeatCount(3, autoreverses: true)) {
                    shakeWrong = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { shakeWrong = false }
            }
            withAnimation(.spring(response: 0.4).delay(0.3)) {
                explanationAppear = true
            }
        }) {
            HStack(spacing: 12) {
                Text(["A", "B", "C", "D"][index])
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(
                        showCorrect ? .white :
                        showWrong ? .white :
                        isSelected ? quizVM.category.color : .white.opacity(0.6)
                    )
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(
                                showCorrect ? Color.green :
                                showWrong ? Color.red :
                                isSelected ? quizVM.category.color.opacity(0.2) :
                                Color.white.opacity(0.08)
                            )
                    )

                Text(text)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Spacer()

                if showCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                        .transition(.scale)
                }
                if showWrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                        .transition(.scale)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        showCorrect ? Color.green.opacity(0.12) :
                        showWrong ? Color.red.opacity(0.12) :
                        AppColors.glass
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                showCorrect ? Color.green.opacity(0.5) :
                                showWrong ? Color.red.opacity(0.5) :
                                isSelected ? quizVM.category.color.opacity(0.4) :
                                AppColors.glassBorder,
                                lineWidth: showCorrect || showWrong ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: showCorrect ? Color.green.opacity(0.15) :
                       showWrong ? Color.red.opacity(0.15) : .clear,
                radius: 12, y: 2
            )
            .offset(x: showWrong && shakeWrong ? -6 : 0)
        }
        .disabled(quizVM.isAnswered)
    }

    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: quizVM.isCorrect ? "lightbulb.fill" : "book.fill")
                    .font(.system(size: 14))
                    .foregroundColor(quizVM.isCorrect ? AppColors.accentGold : quizVM.category.color)
                Text(quizVM.isCorrect ? "Correct! 🎉" : "Not quite — here's why:")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(quizVM.isCorrect ? AppColors.accentGold : .white.opacity(0.9))
            }

            Text(quizVM.currentQuestion.explanation)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            quizVM.isCorrect
                                ? AppColors.accentGold.opacity(0.3)
                                : quizVM.category.color.opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal)
        .scaleEffect(explanationAppear ? 1 : 0.95)
        .opacity(explanationAppear ? 1 : 0)
    }

    private func animateQuestionIn() {
        questionAppear = false
        optionsAppear = false
        explanationAppear = false

        withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.05)) {
            questionAppear = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.15)) {
            optionsAppear = true
        }
    }
}

