import SwiftUI

struct EquationInfoSheet: View {
    let viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var snapshotEquation: String = ""
    @State private var snapshotExampleY: Double = 0
    @State private var snapshotParams: [(symbol: String, name: String, value: Double, role: String)] = []

    var body: some View {
        sheetContent
            .onAppear {
                snapshotEquation = viewModel.equationString
                snapshotExampleY = viewModel.evaluateFunction(at: 2.0)
                snapshotParams = viewModel.parameterBreakdown
            }
    }

    private var sheetContent: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    aboutSection
                    standardFormSection
                    currentEquationSection
                    parametersSection
                    tipSection
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .presentationDetents([.large, .medium])
        .presentationDragIndicator(.visible)
        .modifier(ScrollableSheetModifier())
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(viewModel.currentLevel.category.color.opacity(0.15))
                    .frame(width: 64, height: 64)

                Circle()
                    .stroke(viewModel.currentLevel.category.color.opacity(0.4), lineWidth: 2)
                    .frame(width: 64, height: 64)

                Image(systemName: viewModel.currentLevel.category.icon)
                    .font(.system(size: 28))
                    .foregroundColor(viewModel.currentLevel.category.color)
            }

            Text(viewModel.currentLevel.category.rawValue + " Function")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Level \(viewModel.currentLevel.number) · \(viewModel.currentLevel.title)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "info.circle.fill", title: "About This Function", color: .blue)

            Text(viewModel.functionTypeDescription)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.75))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .infoCard()
    }

    private var standardFormSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "function", title: "Standard Form", color: .purple)

            HStack {
                Spacer()
                Text(viewModel.standardFormString)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                viewModel.currentLevel.category.color,
                                viewModel.currentLevel.category.color.opacity(0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.currentLevel.category.color.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.currentLevel.category.color.opacity(0.2), lineWidth: 1)
                    )
            )

            standardFormLegend
        }
        .infoCard()
    }

    private var standardFormLegend: some View {
        VStack(alignment: .leading, spacing: 6) {
            switch viewModel.currentLevel.category {
            case .linear:
                legendRow("m", "Slope (rate of change)")
                legendRow("x", "Independent variable")
                legendRow("c", "Y-intercept (starting value)")

            case .quadratic:
                legendRow("a", "Quadratic coefficient (curvature)")
                legendRow("b", "Linear coefficient (tilt)")
                legendRow("x", "Independent variable")
                legendRow("c", "Constant (vertical shift)")

            case .polynomial:
                legendRow("a", "Cubic coefficient (twist)")
                legendRow("b", "Linear coefficient")
                legendRow("x", "Independent variable")
                legendRow("c", "Constant (vertical shift)")

            case .trigonometric:
                legendRow("a", "Amplitude (wave height)")
                legendRow("b", "Frequency (wave count)")
                legendRow("x", "Independent variable (angle)")
                legendRow("c", "Phase shift (wave slide)")

            case .exponential:
                legendRow("a", "Scale factor")
                legendRow("b", "Base (growth rate)")
                legendRow("x", "Independent variable (exponent)")
                legendRow("c", "Vertical shift")
            }
        }
    }

    private func legendRow(_ symbol: String, _ description: String) -> some View {
        HStack(spacing: 8) {
            Text(symbol)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(viewModel.currentLevel.category.color)
                .frame(width: 20, alignment: .center)

            Text("→")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.3))

            Text(description)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))

            Spacer()
        }
    }

    private var currentEquationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "equal.circle.fill", title: "Your Current Equation", color: AppColors.functionLine)

            HStack {
                Spacer()
                Text(snapshotEquation)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.functionLine)
                Spacer()
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.functionLine.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.functionLine.opacity(0.3), lineWidth: 1)
                    )
            )

            exampleCalculation
        }
        .infoCard()
    }

    private var exampleCalculation: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Example Calculation")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))

            let testX = 2.0
            let testY = snapshotExampleY

            HStack(spacing: 4) {
                Text("When")
                    .foregroundColor(.white.opacity(0.5))
                Text("x = \(String(format: "%.1f", testX))")
                    .foregroundColor(viewModel.currentLevel.category.color)
                    .fontWeight(.bold)
                Text("→")
                    .foregroundColor(.white.opacity(0.3))
                Text("y = \(String(format: "%.2f", testY))")
                    .foregroundColor(AppColors.functionLine)
                    .fontWeight(.bold)
            }
            .font(.system(size: 13, design: .monospaced))
        }
        .padding(.top, 4)
    }

    private var parametersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "slider.horizontal.3", title: "Parameter Values", color: .orange)

            ForEach(Array(snapshotParams.enumerated()), id: \.offset) { index, param in
                parameterRow(param, index: index)
            }
        }
        .infoCard()
    }

    private func parameterRow(_ param: (symbol: String, name: String, value: Double, role: String), index: Int) -> some View {
        let isVariable = param.symbol == "x" || param.symbol == "y"

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(param.symbol)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(isVariable ? .white : viewModel.currentLevel.category.color)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                isVariable
                                    ? Color.white.opacity(0.08)
                                    : viewModel.currentLevel.category.color.opacity(0.15)
                            )
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(param.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Text(param.role)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .lineLimit(2)
                }

                Spacer()

                if !isVariable {
                    Text(String(format: "%.1f", param.value))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(viewModel.currentLevel.category.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.currentLevel.category.color.opacity(0.1))
                        )
                } else {
                    Text(param.symbol == "x" ? "Variable" : "f(x)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.05))
                        )
                }
            }

            if index < snapshotParams.count - 1 {
                Divider()
                    .background(Color.white.opacity(0.06))
            }
        }
    }

    private var tipSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(icon: "lightbulb.fill", title: "Quick Tip", color: .yellow)

            Text(tipForCategory)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.65))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .infoCard()
    }

    private var tipForCategory: String {
        switch viewModel.currentLevel.category {
        case .linear:
            return "💡 A slope of 1 means the line goes up 1 unit for every 1 unit to the right. A slope of -1 goes down. The intercept is where the line crosses the y-axis (x = 0)."
        case .quadratic:
            return "💡 When 'a' is positive, the parabola opens upward (valley). When negative, it opens downward (mountain). A larger |a| makes it narrower."
        case .polynomial:
            return "💡 Cubic functions always have an S-shape. Positive 'a' goes from bottom-left to top-right. The 'b' term can create bumps in the curve."
        case .trigonometric:
            return "💡 One full wave cycle = 2π/b. The wave peaks at amplitude 'a' and valleys at '-a'. Phase shift 'c' slides everything left or right."
        case .exponential:
            return "💡 When base b > 1 and a > 0, the curve grows rapidly. The curve always passes through (0, a + c) since b⁰ = 1."
        }
    }

    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

struct InfoCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func infoCard() -> some View {
        modifier(InfoCardModifier())
    }
}

struct ScrollableSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content.presentationContentInteraction(.scrolls)
        } else {
            content
        }
    }
}

