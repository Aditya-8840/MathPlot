import SwiftUI
import Combine
import Observation

@MainActor
@Observable
class QuizViewModel {
    let category: FunctionCategory
    let questions: [QuizQuestion]

    var currentIndex: Int = 0
    var selectedAnswer: Int? = nil
    var isAnswered: Bool = false
    var score: Int = 0
    var isComplete: Bool = false

    var results: [Bool] = []

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

