import Foundation

let allQuizQuestions: [QuizQuestion] = [

    QuizQuestion(
        question: "In y = mx + c, what does 'm' represent?",
        options: ["The y-intercept", "The slope of the line", "The x-intercept", "The length of the line"],
        correctIndex: 1,
        explanation: "In a linear equation y = mx + c, 'm' is the slope (gradient). It tells you how steep the line is — how much y changes for each unit increase in x.",
        category: .linear
    ),
    QuizQuestion(
        question: "What is the y-intercept of the equation y = 3x + 7?",
        options: ["3", "7", "0", "–7"],
        correctIndex: 1,
        explanation: "The y-intercept is the value of y when x = 0. Substituting x = 0 into y = 3(0) + 7 gives y = 7. This is where the line crosses the y-axis.",
        category: .linear
    ),
    QuizQuestion(
        question: "What does the graph of a linear function look like?",
        options: ["A curve", "A straight line", "A parabola", "A wave"],
        correctIndex: 1,
        explanation: "Linear functions always produce straight lines. The word 'linear' itself comes from 'line'. The slope stays constant throughout.",
        category: .linear
    ),
    QuizQuestion(
        question: "If a line has slope m = 0, the line is:",
        options: ["Vertical", "Horizontal", "Diagonal at 45°", "Not a valid line"],
        correctIndex: 1,
        explanation: "When the slope m = 0, the equation becomes y = c, which is a horizontal line. The y-value stays constant no matter what x is.",
        category: .linear
    ),
    QuizQuestion(
        question: "Two lines are parallel when they have:",
        options: ["The same y-intercept", "Opposite slopes", "The same slope", "Perpendicular slopes"],
        correctIndex: 2,
        explanation: "Parallel lines never intersect because they rise at the same rate — they have equal slopes. For example, y = 2x + 1 and y = 2x + 5 are parallel.",
        category: .linear
    ),

    QuizQuestion(
        question: "In y = ax² + bx + c, what determines if the parabola opens up or down?",
        options: ["The value of b", "The value of c", "The sign of a", "The value of x"],
        correctIndex: 2,
        explanation: "If 'a' is positive, the parabola opens upward (smile shape). If 'a' is negative, it opens downward (frown shape). The sign of 'a' controls this.",
        category: .quadratic
    ),
    QuizQuestion(
        question: "What is the vertex of a parabola?",
        options: [
            "Where the curve crosses the x-axis",
            "The highest or lowest point on the curve",
            "Where the curve crosses the y-axis",
            "The steepest point on the curve"
        ],
        correctIndex: 1,
        explanation: "The vertex is the turning point of the parabola — its maximum (if opening down) or minimum (if opening up). It's the point where the curve changes direction.",
        category: .quadratic
    ),
    QuizQuestion(
        question: "How many roots (x-intercepts) can a quadratic equation have?",
        options: ["Always exactly 2", "Only 1", "0, 1, or 2", "Infinite"],
        correctIndex: 2,
        explanation: "A quadratic can have 0 roots (curve doesn't cross x-axis), 1 root (touches x-axis at vertex), or 2 roots (crosses x-axis twice). The discriminant b²−4ac determines which.",
        category: .quadratic
    ),
    QuizQuestion(
        question: "In y = ax², increasing |a| makes the parabola:",
        options: ["Wider", "Narrower (steeper)", "Move left", "Move up"],
        correctIndex: 1,
        explanation: "A larger |a| value compresses the parabola, making it narrower/steeper. A smaller |a| stretches it wider. Think of |a| as controlling the 'squeeze'.",
        category: .quadratic
    ),
    QuizQuestion(
        question: "What is the axis of symmetry for y = ax² + bx + c?",
        options: ["x = c", "x = –b/(2a)", "y = a", "x = b"],
        correctIndex: 1,
        explanation: "Every parabola has a vertical line of symmetry passing through its vertex. This line is at x = –b/(2a), which divides the parabola into two mirror halves.",
        category: .quadratic
    ),

    QuizQuestion(
        question: "What is the degree of the polynomial y = ax³ + bx + c?",
        options: ["1", "2", "3", "4"],
        correctIndex: 2,
        explanation: "The degree of a polynomial is the highest power of x. Here the highest power is x³, so the degree is 3. This makes it a cubic polynomial.",
        category: .polynomial
    ),
    QuizQuestion(
        question: "How many turning points can a cubic function have at most?",
        options: ["1", "2", "3", "0"],
        correctIndex: 1,
        explanation: "A polynomial of degree n can have at most n−1 turning points. For a cubic (degree 3), that's at most 2 turning points — one local maximum and one local minimum.",
        category: .polynomial
    ),
    QuizQuestion(
        question: "What happens to a cubic y = ax³ as x → +∞ when a > 0?",
        options: ["y → 0", "y → −∞", "y → +∞", "y stays constant"],
        correctIndex: 2,
        explanation: "For a positive leading coefficient, as x grows very large, x³ grows even larger. So y heads toward positive infinity. The curve rises to the upper right.",
        category: .polynomial
    ),
    QuizQuestion(
        question: "In y = ax³ + bx + c, the coefficient 'a' controls:",
        options: [
            "The y-intercept",
            "The steepness and direction of the S-curve",
            "Only the horizontal shift",
            "The number of roots"
        ],
        correctIndex: 1,
        explanation: "'a' controls how stretched or compressed the cubic is and whether it goes from bottom-left to top-right (a > 0) or top-left to bottom-right (a < 0).",
        category: .polynomial
    ),
    QuizQuestion(
        question: "A cubic polynomial always has at least how many real roots?",
        options: ["0", "1", "2", "3"],
        correctIndex: 1,
        explanation: "A cubic is an odd-degree polynomial, so it must cross the x-axis at least once. Its ends go in opposite directions (one to +∞, one to −∞), guaranteeing at least 1 real root.",
        category: .polynomial
    ),

    QuizQuestion(
        question: "In y = a·sin(bx + c), what does 'a' control?",
        options: ["Period", "Amplitude", "Phase shift", "Vertical shift"],
        correctIndex: 1,
        explanation: "'a' is the amplitude — it controls the height of the wave peaks. An amplitude of 3 means the wave goes from –3 to +3. Larger |a| = taller waves.",
        category: .trigonometric
    ),
    QuizQuestion(
        question: "What is the period of sin(x)?",
        options: ["π", "2π", "π/2", "1"],
        correctIndex: 1,
        explanation: "The basic sin(x) completes one full cycle every 2π radians (≈ 360°). After traveling 2π along the x-axis, the wave pattern repeats exactly.",
        category: .trigonometric
    ),
    QuizQuestion(
        question: "In y = sin(bx), increasing 'b' makes the wave:",
        options: [
            "Taller",
            "Oscillate faster (shorter period)",
            "Oscillate slower (longer period)",
            "Shift to the right"
        ],
        correctIndex: 1,
        explanation: "The period becomes 2π/b. So a larger 'b' shrinks the period, making the wave oscillate more frequently. More cycles are squeezed into the same width.",
        category: .trigonometric
    ),
    QuizQuestion(
        question: "What does the 'c' in y = a·sin(bx + c) do?",
        options: [
            "Changes the amplitude",
            "Shifts the curve horizontally (phase shift)",
            "Changes the period",
            "Flips the curve"
        ],
        correctIndex: 1,
        explanation: "'c' creates a phase shift — it moves the entire wave left or right. A positive c shifts left, a negative c shifts right. The shift amount is c/b.",
        category: .trigonometric
    ),
    QuizQuestion(
        question: "sin(x) and cos(x) are related by:",
        options: [
            "They are identical",
            "cos(x) = sin(x + π/2)",
            "cos(x) = sin(x) × 2",
            "They have different periods"
        ],
        correctIndex: 1,
        explanation: "cos(x) is just sin(x) shifted left by π/2 radians (90°). They have the same shape, amplitude, and period — they're just offset from each other.",
        category: .trigonometric
    ),

    QuizQuestion(
        question: "In y = a·bˣ + c, when b > 1 the function shows:",
        options: ["Exponential decay", "Linear growth", "Exponential growth", "No change"],
        correctIndex: 2,
        explanation: "When the base b is greater than 1, each increase in x multiplies y by b, causing rapid growth. For example, 2ˣ doubles with each step: 1, 2, 4, 8, 16...",
        category: .exponential
    ),
    QuizQuestion(
        question: "What happens when 0 < b < 1 in y = a·bˣ?",
        options: ["The function grows", "The function decays toward 0", "The function is linear", "The function oscillates"],
        correctIndex: 1,
        explanation: "When 0 < b < 1, multiplying by b repeatedly makes y smaller and smaller, approaching (but never reaching) zero. This is exponential decay.",
        category: .exponential
    ),
    QuizQuestion(
        question: "What is the horizontal asymptote of y = a·bˣ + c?",
        options: ["y = 0", "y = a", "y = c", "y = b"],
        correctIndex: 2,
        explanation: "As x → −∞ (for growth) or x → +∞ (for decay), a·bˣ approaches 0, so the function approaches y = c. The graph never actually reaches this line.",
        category: .exponential
    ),
    QuizQuestion(
        question: "In y = a·bˣ, the coefficient 'a' controls:",
        options: [
            "The growth rate",
            "The initial value (y-intercept stretch)",
            "The horizontal asymptote",
            "The base"
        ],
        correctIndex: 1,
        explanation: "'a' scales the entire curve vertically. At x = 0, y = a·b⁰ = a, so 'a' determines the starting value. If a < 0, the curve is also flipped.",
        category: .exponential
    ),
    QuizQuestion(
        question: "Which real-world scenario follows exponential growth?",
        options: [
            "A car traveling at constant speed",
            "Filling a pool at a steady rate",
            "Bacteria doubling every hour",
            "Walking up a staircase"
        ],
        correctIndex: 2,
        explanation: "Bacteria doubling every hour is classic exponential growth (y = 2ˣ). Each generation doubles, leading to rapid acceleration: 1 → 2 → 4 → 8 → 16 → ...",
        category: .exponential
    )
]

func quizQuestions(for category: FunctionCategory) -> [QuizQuestion] {
    allQuizQuestions.filter { $0.category == category }
}

