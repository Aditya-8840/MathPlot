import SwiftUI

@MainActor
class QuizViewModel: ObservableObject {
    let category: FunctionCategory
    let questions: [QuizQuestion]

    @Published var currentIndex: Int = 0
    @Published var selectedAnswer: Int? = nil
    @Published var isAnswered: Bool = false
    @Published var score: Int = 0
    @Published var isComplete: Bool = false

    @Published var results: [Bool] = []

    init(category: FunctionCategory) {
        self.category = category
        self.questions = quizQuestions(for: category)
    }

    var currentQuestion: QuizQuestion {
        questions[currentIndex]
    }

    var progress: Double {
        Double(currentIndex + 1) / Double(questions.count)
    }

    var totalQuestions: Int { questions.count }

    var isCorrect: Bool {
        selectedAnswer == currentQuestion.correctIndex
    }

    func selectAnswer(_ index: Int) {
        guard !isAnswered else { return }
        selectedAnswer = index
        isAnswered = true
        let correct = index == currentQuestion.correctIndex
        if correct { score += 1 }
        results.append(correct)
    }

    func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
            isAnswered = false
        } else {
            isComplete = true
        }
    }

    func restart() {
        currentIndex = 0
        selectedAnswer = nil
        isAnswered = false
        score = 0
        isComplete = false
        results = []
    }
}

