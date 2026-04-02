import SwiftUI

@MainActor
class GameViewModel: ObservableObject {

    @Published var currentLevel: Level
    @Published var paramM: Double = 0 { didSet { checkStarProximity() } }
    @Published var paramC: Double = 0 { didSet { checkStarProximity() } }
    @Published var paramA: Double = 0 { didSet { checkStarProximity() } }
    @Published var paramB: Double = 0 { didSet { checkStarProximity() } }
    @Published var paramH: Double = 0 { didSet { checkStarProximity() } }
    @Published var paramK: Double = 0 { didSet { checkStarProximity() } }
    @Published var stars: [Star] = []
    @Published var isRunning: Bool = false
    @Published var marbleX: Double = -5
    @Published var marbleY: Double = 0
    @Published var levelComplete: Bool = false
    @Published var marbleTrail: [GraphPoint] = []
    @Published var showCelebration: Bool = false
    @Published var completedLevelIds: Set<String> = []
    @Published var selectedCategory: FunctionCategory? = nil
    @Published var completedQuizCategories: Set<String> = []

    let allLevels = LevelData.allLevels()

    private var simulationCurrentX: Double = 0
    private var simulationStepIndex: Int = 0
    private var simulationTask: Task<Void, Never>?

    private var starsCurrentlyMatched: Set<UUID> = []
    private var starsCurrentlyNear: Set<UUID> = []

    private let collisionRadius: Double = 0.55
    private let marbleStep: Double = 0.04
    private let baseInterval: Double = 0.016
    private let maxTrailLength: Int = 120

    private let starMatchThreshold: Double = 0.15
    private let starProximityThreshold: Double = 0.5

    init() {
        let firstLevel = LevelData.allLevels()[0]
        self.currentLevel = firstLevel
        self.paramM = firstLevel.initialM
        self.paramC = firstLevel.initialC
        self.paramA = firstLevel.initialA
        self.paramB = firstLevel.initialB
        self.paramH = firstLevel.initialH
        self.paramK = firstLevel.initialK
        self.stars = firstLevel.stars
        let startX = firstLevel.gridRange.lowerBound
        self.marbleX = startX
        self.marbleY = 0
    }

    private func checkStarProximity() {
        guard !isRunning else { return }

        for star in stars {
            guard !star.isCollected else { continue }

            let curveY = evaluateFunction(at: star.position.x)
            let distance = abs(curveY - star.position.y)
            let starId = star.id

            if distance < starMatchThreshold {
                if !starsCurrentlyMatched.contains(starId) {
                    starsCurrentlyMatched.insert(starId)
                    starsCurrentlyNear.insert(starId)
                    HapticManager.shared.starMatchHit()
                }
            } else if distance < starProximityThreshold {
                if starsCurrentlyMatched.contains(starId) {
                    starsCurrentlyMatched.remove(starId)
                }
                if !starsCurrentlyNear.contains(starId) {
                    starsCurrentlyNear.insert(starId)
                    HapticManager.shared.starProximityTap()
                }
            } else {
                starsCurrentlyMatched.remove(starId)
                starsCurrentlyNear.remove(starId)
            }
        }
    }

    func levels(for category: FunctionCategory) -> [Level] {
        allLevels.filter { $0.category == category }
    }

    func completedCount(for category: FunctionCategory) -> Int {
        let ids = levels(for: category).map { $0.id }
        let levelCount = ids.filter { completedLevelIds.contains($0) }.count
        let quizBonus = completedQuizCategories.contains(category.rawValue) ? 1 : 0
        return levelCount + quizBonus
    }

    func totalCount(for category: FunctionCategory) -> Int {
        levels(for: category).count + 1
    }

    func isQuizUnlocked(for category: FunctionCategory) -> Bool {
        let categoryLevels = levels(for: category)
        return categoryLevels.allSatisfy { completedLevelIds.contains($0.id) }
    }

    func isQuizCompleted(for category: FunctionCategory) -> Bool {
        completedQuizCategories.contains(category.rawValue)
    }

    func markQuizCompleted(for category: FunctionCategory) {
        completedQuizCategories.insert(category.rawValue)
    }

    var isLastLevelInCategory: Bool {
        let categoryLevels = levels(for: currentLevel.category)
        return currentLevel.number == categoryLevels.count
    }

    func isLevelUnlocked(_ level: Level) -> Bool {
        if level.number == 1 { return true }
        let categoryLevels = levels(for: level.category)
        guard let previousLevel = categoryLevels.first(where: { $0.number == level.number - 1 }) else {
            return true
        }
        return completedLevelIds.contains(previousLevel.id)
    }

    func loadLevel(_ level: Level) {
        simulationTask?.cancel()
        simulationTask = nil

        currentLevel = level
        paramM = level.initialM
        paramC = level.initialC
        paramA = level.initialA
        paramB = level.initialB
        paramH = level.initialH
        paramK = level.initialK
        stars = level.stars
        isRunning = false
        levelComplete = false
        showCelebration = false
        marbleTrail = []

        starsCurrentlyMatched.removeAll()
        starsCurrentlyNear.removeAll()

        let startX = level.gridRange.lowerBound
        marbleX = startX
        marbleY = evaluateFunction(at: startX)
    }

    func resetLevel() {
        loadLevel(currentLevel)
    }

    func nextLevel() -> Bool {
        let categoryLevels = levels(for: currentLevel.category)
        if let idx = categoryLevels.firstIndex(where: { $0.id == currentLevel.id }),
           idx + 1 < categoryLevels.count {
            loadLevel(categoryLevels[idx + 1])
            return true
        }
        return false
    }

    var hasNextLevel: Bool {
        let categoryLevels = levels(for: currentLevel.category)
        if let idx = categoryLevels.firstIndex(where: { $0.id == currentLevel.id }),
           idx + 1 < categoryLevels.count {
            return true
        }
        return false
    }

    func evaluateFunction(at x: Double) -> Double {
        switch currentLevel.category {
        case .linear:
            return paramM * x + paramC
        case .quadratic:
            return paramA * x * x + paramM * x + paramC
        case .polynomial:
            return paramA * x * x * x + paramB * x + paramC
        case .trigonometric:
            return paramA * sin(paramB * x + paramC)
        case .exponential:
            let base = max(paramB, 0.1)
            let power = pow(base, x)
            let clamped = min(max(power, -1000), 1000)
            return paramA * clamped + paramC
        }
    }

    private func evaluateDerivative(at x: Double) -> Double {
        switch currentLevel.category {
        case .linear:
            return paramM
        case .quadratic:
            return 2 * paramA * x + paramM
        case .polynomial:
            return 3 * paramA * x * x + paramB
        case .trigonometric:
            return paramA * paramB * cos(paramB * x + paramC)
        case .exponential:
            let base = max(paramB, 0.1)
            let power = pow(base, x)
            let clamped = min(max(power, -1000), 1000)
            return paramA * log(base) * clamped
        }
    }

    var equationString: String {
        switch currentLevel.category {
        case .linear:        return formatLinear()
        case .quadratic:     return formatQuadratic()
        case .polynomial:    return formatPolynomial()
        case .trigonometric: return formatTrigonometric()
        case .exponential:   return formatExponential()
        }
    }

    private func formatLinear() -> String {
        let m = String(format: "%.1f", paramM)
        let c = String(format: "%.1f", paramC)
        if paramM == 0 && paramC == 0 { return "y = 0" }
        if paramM == 0 { return "y = \(c)" }
        if paramC == 0 { return "y = \(m)x" }
        return "y = \(m)x + \(c)"
    }

    private func formatQuadratic() -> String {
        let a = String(format: "%.1f", paramA)
        let b = String(format: "%.1f", paramM)
        let c = String(format: "%.1f", paramC)
        var parts: [String] = []
        if paramA != 0 { parts.append("\(a)x²") }
        if paramM != 0 {
            let sign = parts.isEmpty ? "" : (paramM > 0 ? " + " : " ")
            parts.append("\(sign)\(b)x")
        }
        if paramC != 0 {
            let sign = parts.isEmpty ? "" : (paramC > 0 ? " + " : " ")
            parts.append("\(sign)\(c)")
        }
        if parts.isEmpty { return "y = 0" }
        return "y = " + parts.joined()
    }

    private func formatPolynomial() -> String {
        let a = String(format: "%.1f", paramA)
        let b = String(format: "%.1f", paramB)
        let c = String(format: "%.1f", paramC)
        var parts: [String] = []
        if paramA != 0 { parts.append("\(a)x³") }
        if paramB != 0 {
            let sign = parts.isEmpty ? "" : (paramB > 0 ? " + " : " ")
            parts.append("\(sign)\(b)x")
        }
        if paramC != 0 {
            let sign = parts.isEmpty ? "" : (paramC > 0 ? " + " : " ")
            parts.append("\(sign)\(c)")
        }
        if parts.isEmpty { return "y = 0" }
        return "y = " + parts.joined()
    }

    private func formatTrigonometric() -> String {
        let a = String(format: "%.1f", paramA)
        let b = String(format: "%.1f", paramB)
        let c = String(format: "%.1f", paramC)
        var inner = "\(b)x"
        if paramC != 0 {
            inner += paramC > 0 ? " + \(c)" : " \(c)"
        }
        return "y = \(a)·sin(\(inner))"
    }

    private func formatExponential() -> String {
        let a = String(format: "%.1f", paramA)
        let b = String(format: "%.1f", paramB)
        let c = String(format: "%.1f", paramC)
        var result = "y = \(a)·\(b)ˣ"
        if paramC != 0 {
            result += paramC > 0 ? " + \(c)" : " \(c)"
        }
        return result
    }

    var functionTypeDescription: String {
        switch currentLevel.category {
        case .linear:
            return "A linear function creates a straight line. The slope (m) controls the steepness and direction, while the intercept (c) shifts the line up or down."
        case .quadratic:
            return "A quadratic function creates a parabola (U-shape). The coefficient 'a' controls how wide or narrow it is and whether it opens up or down. 'b' tilts the parabola, and 'c' shifts it vertically."
        case .polynomial:
            return "A cubic polynomial creates an S-shaped curve. The coefficient 'a' controls the steepness of the twist, 'b' adds a linear component, and 'c' shifts it vertically."
        case .trigonometric:
            return "A sine function creates a repeating wave. 'a' controls the amplitude (height), 'b' controls the frequency (how many waves), and 'c' shifts the phase (slides left/right)."
        case .exponential:
            return "An exponential function grows (or decays) rapidly. 'a' scales the curve, 'b' is the base that controls growth rate, and 'c' shifts the curve vertically."
        }
    }

    var standardFormString: String {
        currentLevel.category.formula
    }

    var parameterBreakdown: [(symbol: String, name: String, value: Double, role: String)] {
        switch currentLevel.category {
        case .linear:
            var items: [(String, String, Double, String)] = []
            if currentLevel.sliderConfig.showM {
                items.append(("m", "Slope", paramM, "Controls steepness — positive goes up, negative goes down"))
            }
            if currentLevel.sliderConfig.showC {
                items.append(("c", "Y-Intercept", paramC, "Where the line crosses the y-axis"))
            }
            items.append(("x", "Variable", 0, "The independent variable (horizontal axis)"))
            items.append(("y", "Output", 0, "The dependent variable (vertical axis)"))
            return items

        case .quadratic:
            var items: [(String, String, Double, String)] = []
            if currentLevel.sliderConfig.showA {
                items.append(("a", "Quadratic Coefficient", paramA, "Controls width and direction of parabola"))
            }
            if currentLevel.sliderConfig.showM {
                items.append(("b", "Linear Coefficient", paramM, "Tilts the parabola left or right"))
            }
            if currentLevel.sliderConfig.showC {
                items.append(("c", "Constant", paramC, "Shifts the parabola up or down"))
            }
            items.append(("x", "Variable", 0, "The independent variable"))
            items.append(("y", "Output", 0, "The dependent variable"))
            return items

        case .polynomial:
            var items: [(String, String, Double, String)] = []
            if currentLevel.sliderConfig.showA {
                items.append(("a", "Cubic Coefficient", paramA, "Controls the steepness of the S-curve"))
            }
            if currentLevel.sliderConfig.showB {
                items.append(("b", "Linear Coefficient", paramB, "Adds a straight-line component"))
            }
            if currentLevel.sliderConfig.showC {
                items.append(("c", "Constant", paramC, "Shifts the curve up or down"))
            }
            items.append(("x", "Variable", 0, "The independent variable"))
            items.append(("y", "Output", 0, "The dependent variable"))
            return items

        case .trigonometric:
            var items: [(String, String, Double, String)] = []
            if currentLevel.sliderConfig.showA {
                items.append(("a", "Amplitude", paramA, "Height of the wave peaks"))
            }
            if currentLevel.sliderConfig.showB {
                items.append(("b", "Frequency", paramB, "How many waves fit in the view"))
            }
            if currentLevel.sliderConfig.showC {
                items.append(("c", "Phase Shift", paramC, "Slides the wave left or right"))
            }
            items.append(("x", "Variable", 0, "The independent variable (angle in radians)"))
            items.append(("y", "Output", 0, "The dependent variable"))
            return items

        case .exponential:
            var items: [(String, String, Double, String)] = []
            if currentLevel.sliderConfig.showA {
                items.append(("a", "Scale", paramA, "Multiplies the entire curve"))
            }
            if currentLevel.sliderConfig.showB {
                items.append(("b", "Base", paramB, "The base of the exponent — controls growth rate"))
            }
            if currentLevel.sliderConfig.showC {
                items.append(("c", "Vertical Shift", paramC, "Shifts the curve up or down"))
            }
            items.append(("x", "Variable", 0, "The independent variable (exponent)"))
            items.append(("y", "Output", 0, "The dependent variable"))
            return items
        }
    }
}

extension GameViewModel {

    func runMarble() {
        guard !isRunning else { return }

        isRunning = true
        levelComplete = false
        showCelebration = false
        marbleTrail = []
        stars = currentLevel.stars

        let startX = currentLevel.gridRange.lowerBound
        marbleX = startX
        marbleY = evaluateFunction(at: startX)

        simulationCurrentX = startX
        simulationStepIndex = 0

        simulationTask = Task { [weak self] in
            await self?.runSimulationLoop()
        }
    }

    private func runSimulationLoop() async {
        let endX = currentLevel.gridRange.upperBound

        while isRunning {
            if Task.isCancelled { break }

            simulationCurrentX += marbleStep

            if simulationCurrentX > endX {
                isRunning = false
                checkCompletion()
                return
            }

            let y = evaluateFunction(at: simulationCurrentX)
            let derivative = abs(evaluateDerivative(at: simulationCurrentX))
            let speedMultiplier = max(0.3, min(2.0, 1.0 + derivative * 0.15))

            simulationStepIndex += 1

            withAnimation(.linear(duration: baseInterval)) {
                marbleX = simulationCurrentX
                marbleY = y
            }

            if simulationStepIndex % 2 == 0 {
                marbleTrail.append(GraphPoint(x: simulationCurrentX, y: y))
                if marbleTrail.count > maxTrailLength {
                    marbleTrail.removeFirst()
                }
            }

            checkCollisions()

            let delayNanoseconds = UInt64((baseInterval / speedMultiplier) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
    }

    func checkCollisions() {
        for i in 0..<stars.count {
            guard !stars[i].isCollected else { continue }
            let dx = marbleX - stars[i].position.x
            let dy = marbleY - stars[i].position.y
            let distance = sqrt(dx * dx + dy * dy)
            if distance < collisionRadius {
                stars[i].isCollected = true
                stars[i].collectTime = Date()
                HapticManager.shared.marbleCollision()
            }
        }
    }

    func checkCompletion() {
        if stars.allSatisfy({ $0.isCollected }) {
            levelComplete = true
            showCelebration = true
            completedLevelIds.insert(currentLevel.id)
        }
    }
}

