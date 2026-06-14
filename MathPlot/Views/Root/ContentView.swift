import SwiftUI

enum AppScreen {
    case onboarding
    case splash
    case categories
    case levels
    case game
    case quiz
}

struct ContentView: View {
    @Environment(GameViewModel.self) private var viewModel

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var currentScreen: AppScreen

    init() {
        _currentScreen = State(initialValue: UserDefaults.standard.bool(forKey: "hasSeenOnboarding") ? .splash : .onboarding)
    }

    private var canSwipeBack: Bool {
        switch currentScreen {
        case .onboarding, .splash, .categories: return false
        case .levels, .game, .quiz: return true
        }
    }

    private func navigateBack() {
        switch currentScreen {
        case .levels:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.88)) {
                currentScreen = .categories
            }
        case .game:
            viewModel.resetLevel()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.88)) {
                currentScreen = .levels
            }
        case .quiz:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.88)) {
                currentScreen = .levels
            }
        default:
            break
        }
    }

    private var edgeSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onEnded { value in
                guard canSwipeBack,
                      value.startLocation.x < 50,
                      value.translation.width > 60
                else { return }
                navigateBack()
            }
    }

    var body: some View {
        ZStack {
            switch currentScreen {
            case .onboarding:
                OnboardingView(onComplete: {
                    hasSeenOnboarding = true
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        currentScreen = .splash
                    }
                })
                .transition(.opacity)

            case .splash:
                SplashView(onStart: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        currentScreen = .categories
                    }
                })
                .transition(.opacity)

            case .categories:
                CategorySelectionView(
                    onSelectCategory: {
                        withAnimation(.spring(response: 0.4)) {
                            currentScreen = .levels
                        }
                    }
                )
                .transition(.opacity)

            case .levels:
                LevelListView(
                    onBack: {
                        withAnimation(.spring(response: 0.4)) {
                            currentScreen = .categories
                        }
                    },
                    onSelectLevel: {
                        withAnimation(.spring(response: 0.4)) {
                            currentScreen = .game
                        }
                    },
                    onQuiz: {
                        withAnimation(.spring(response: 0.4)) {
                            currentScreen = .quiz
                        }
                    }
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    )
                )

            case .game:
                GameView(
                    onBack: {
                        viewModel.resetLevel()
                        withAnimation(.spring(response: 0.4)) {
                            currentScreen = .levels
                        }
                    },
                    onBackToLevels: {
                        viewModel.resetLevel()
                        withAnimation(.spring(response: 0.4)) {
                            currentScreen = .levels
                        }
                    },
                    onQuiz: {
                        withAnimation(.spring(response: 0.4)) {
                            currentScreen = .quiz
                        }
                    }
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    )
                )

            case .quiz:
                QuizView(
                    quizVM: QuizViewModel(category: viewModel.selectedCategory ?? .linear),
                    onBack: {
                        withAnimation(.spring(response: 0.4)) {
                            currentScreen = .levels
                        }
                    },
                    onComplete: { category in
                        viewModel.markQuizCompleted(for: category)
                    }
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    )
                )
            }
        }
        .gesture(edgeSwipeGesture)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentScreen)
    }
}

