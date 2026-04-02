import SwiftUI

struct LevelListView: View {
    @ObservedObject var viewModel: GameViewModel
    var onBack: () -> Void
    var onSelectLevel: () -> Void
    var onQuiz: () -> Void

    private var category: FunctionCategory {
        viewModel.selectedCategory ?? .linear
    }

    private var categoryLevels: [Level] {
        viewModel.levels(for: category)
    }

    var body: some View {
        ZStack {
            AppColors.meshGradient.ignoresSafeArea()
            BackgroundStarsView().ignoresSafeArea().opacity(0.5)

            Circle()
                .fill(category.color.opacity(0.06))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(y: -100)

            VStack(spacing: 0) {
                topBar
                    .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    ZStack {
                        CurvePathLine(
                            count: categoryLevels.count + 1,
                            categoryColor: category.color,
                            completedCount: viewModel.completedCount(for: category)
                        )

                        VStack(spacing: 0) {
                            ForEach(categoryLevels) { level in
                                let index = categoryLevels.firstIndex(where: { $0.id == level.id }) ?? 0
                                let isCompleted = viewModel.completedLevelIds.contains(level.id)
                                let isUnlocked = viewModel.isLevelUnlocked(level)
                                let isEven = index % 2 == 0

                                CurvePathNode(
                                    level: level,
                                    isCompleted: isCompleted,
                                    isUnlocked: isUnlocked,
                                    categoryColor: category.color,
                                    alignment: isEven ? .leading : .trailing,
                                    delay: Double(index) * 0.1
                                )
                                .onTapGesture {
                                    if isUnlocked {
                                        viewModel.loadLevel(level)
                                        onSelectLevel()
                                    }
                                }
                                .padding(.bottom, 20)
                            }

                            quizPathNode
                                .padding(.bottom, 20)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 60)
                    }
                }
            }
        }
    }

    private var quizPathNode: some View {
        let quizIndex = categoryLevels.count
        let isLeft = quizIndex % 2 == 0
        let isCompleted = viewModel.isQuizCompleted(for: category)
        let isUnlocked = viewModel.isQuizUnlocked(for: category)

        return HStack {
            if !isLeft { Spacer() }
            HStack(spacing: 12) {
                if isLeft { quizCircle(isCompleted: isCompleted, isUnlocked: isUnlocked); quizInfoView(isLeft: isLeft, isUnlocked: isUnlocked, isCompleted: isCompleted) }
                else { quizInfoView(isLeft: isLeft, isUnlocked: isUnlocked, isCompleted: isCompleted); quizCircle(isCompleted: isCompleted, isUnlocked: isUnlocked) }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .frame(maxWidth: 210)
            .background {
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .glassEffect(
                            .regular.tint(
                                isCompleted ? AppColors.accentGold.opacity(0.15) :
                                    isUnlocked ? category.color.opacity(0.15) :
                                    Color.white.opacity(0.08)
                            ),
                            in: .rect(cornerRadius: 20)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.glass)
                        .background(RoundedRectangle(cornerRadius: 20).fill(
                            isCompleted ? category.color.opacity(0.06) :
                                isUnlocked ? AppColors.cardBackground :
                                Color.white.opacity(0.06)
                        ))
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(
                LinearGradient(colors: [
                    isCompleted ? AppColors.accentGold.opacity(0.4) :
                        isUnlocked ? category.color.opacity(0.3) :
                        Color.white.opacity(0.12),
                    .clear
                ], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1
            ))
            .shadow(
                color: isCompleted ? AppColors.accentGold.opacity(0.12) :
                    isUnlocked ? category.color.opacity(0.08) : .clear,
                radius: 16, y: 4
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .opacity(isUnlocked ? 1 : 0.7)
            .onTapGesture {
                if isUnlocked {
                    onQuiz()
                }
            }
            if isLeft { Spacer() }
        }
    }

    private func quizCircle(isCompleted: Bool, isUnlocked: Bool) -> some View {
        ZStack {
            Circle().stroke(
                LinearGradient(
                    colors: isCompleted
                    ? [AppColors.accentGold, .orange]
                    : isUnlocked
                    ? [category.color, category.color.opacity(0.3)]
                    : [Color.white.opacity(0.25), Color.white.opacity(0.12)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                lineWidth: isCompleted ? 3 : 2
            ).frame(width: 46, height: 46)

            Circle().fill(
                isCompleted
                ? LinearGradient(colors: [AppColors.accentGold, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                : isUnlocked
                ? LinearGradient(colors: [category.color.opacity(0.15), category.color.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
            ).frame(width: 42, height: 42)

            if isCompleted {
                Image(systemName: "checkmark").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            } else if !isUnlocked {
                Image(systemName: "lock.fill").font(.system(size: 13)).foregroundColor(.white.opacity(0.45))
            } else {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 18))
                    .foregroundColor(category.color)
            }
        }
    }

    private func quizInfoView(isLeft: Bool, isUnlocked: Bool, isCompleted: Bool) -> some View {
        VStack(alignment: isLeft ? .leading : .trailing, spacing: 4) {
            Text("Take Quiz")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(isUnlocked ? .white : .white.opacity(0.55))
            Text("Test yourself!")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(isUnlocked ? .white.opacity(0.45) : .white.opacity(0.35))
                .lineLimit(1)
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { _ in
                    Image(systemName: isCompleted ? "star.fill" : "star")
                        .font(.system(size: 7))
                        .foregroundColor(
                            isCompleted ? AppColors.accentGold :
                                isUnlocked ? category.color.opacity(0.35) :
                                    .white.opacity(0.25)
                        )
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: { onBack() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background {
                        if #available(iOS 26.0, *) {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .glassEffect(.regular.tint(Color.white.opacity(0.1)), in: .circle)
                        } else {
                            Circle()
                                .fill(AppColors.glass)
                                .overlay(
                                    Circle()
                                        .stroke(AppColors.glassBorder, lineWidth: 1)
                                )
                        }
                    }
            }

            Spacer()

            VStack(spacing: 3) {
                HStack(spacing: 6) {
                    Image(systemName: category.icon)
                        .font(.system(size: 14))
                        .foregroundColor(category.color)
                    Text(category.rawValue)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Text(category.formula)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(category.color.opacity(0.7))
            }

            Spacer()

            HStack(spacing: 4) {
                Text("\(viewModel.completedCount(for: category))")
                    .foregroundColor(category.color)
                Text("/")
                    .foregroundColor(.white.opacity(0.3))
                Text("\(viewModel.totalCount(for: category))")
                    .foregroundColor(.white.opacity(0.5))
            }
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                if #available(iOS 26.0, *) {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .glassEffect(.regular.tint(category.color.opacity(0.15)), in: .capsule)
                } else {
                    Capsule()
                        .fill(AppColors.glass)
                        .overlay(
                            Capsule()
                                .stroke(category.color.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal)
    }
}

struct CurvePathLine: View {
    let count: Int
    let categoryColor: Color
    let completedCount: Int

    private let nodeHeight: CGFloat = 100
    private let horizontalPadding: CGFloat = 60

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let centerX = width / 2

            Canvas { context, size in
                guard count > 1 else { return }

                let startY: CGFloat = 80
                var points: [CGPoint] = []
                for i in 0..<count {
                    let y = startY + CGFloat(i) * nodeHeight
                    let isEven = i % 2 == 0
                    let offsetX: CGFloat = isEven ? -horizontalPadding : horizontalPadding
                    points.append(CGPoint(x: centerX + offsetX, y: y))
                }

                if completedCount > 0 {
                    var completedPath = Path()
                    let endIdx = min(completedCount, points.count)
                    for i in 0..<endIdx {
                        if i == 0 {
                            completedPath.move(to: points[i])
                        } else {
                            let prev = points[i - 1]
                            let curr = points[i]
                            let controlY = (prev.y + curr.y) / 2
                            completedPath.addCurve(
                                to: curr,
                                control1: CGPoint(x: prev.x, y: controlY),
                                control2: CGPoint(x: curr.x, y: controlY)
                            )
                        }
                    }

                    context.stroke(
                        completedPath,
                        with: .color(categoryColor.opacity(0.15)),
                        lineWidth: 16
                    )
                    context.stroke(
                        completedPath,
                        with: .color(categoryColor.opacity(0.3)),
                        lineWidth: 6
                    )
                    context.stroke(
                        completedPath,
                        with: .color(categoryColor.opacity(0.9)),
                        lineWidth: 2.5
                    )
                }

                let startFrom = max(completedCount - 1, 0)
                if startFrom < points.count - 1 {
                    var remainingPath = Path()
                    remainingPath.move(to: points[startFrom])
                    for i in (startFrom + 1)..<points.count {
                        let prev = points[i - 1]
                        let curr = points[i]
                        let controlY = (prev.y + curr.y) / 2
                        remainingPath.addCurve(
                            to: curr,
                            control1: CGPoint(x: prev.x, y: controlY),
                            control2: CGPoint(x: curr.x, y: controlY)
                        )
                    }
                    context.stroke(
                        remainingPath,
                        with: .color(Color.white.opacity(0.08)),
                        style: StrokeStyle(lineWidth: 2, dash: [8, 8])
                    )
                }
            }
        }
        .frame(height: CGFloat(count) * nodeHeight + 120)
        .allowsHitTesting(false)
    }
}

struct CurvePathNode: View {
    let level: Level
    let isCompleted: Bool
    let isUnlocked: Bool
    let categoryColor: Color
    let alignment: HorizontalAlignment
    let delay: Double
    
    @State private var appear = false
    @State private var pulse = false
    private var isLeft: Bool { alignment == .leading }
    
    var body: some View {
        HStack {
            if !isLeft { Spacer() }
            HStack(spacing: 12) {
                if isLeft { nodeCircle; nodeInfo } else { nodeInfo; nodeCircle }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .frame(maxWidth: 210)
            .background {
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .glassEffect(
                            .regular.tint(
                                isCompleted ? AppColors.accentGold.opacity(0.15) :
                                    isUnlocked ? categoryColor.opacity(0.15) :
                                    Color.white.opacity(0.08)
                            ),
                            in: .rect(cornerRadius: 20)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.glass)
                        .background(RoundedRectangle(cornerRadius: 20).fill(
                            isCompleted ? categoryColor.opacity(0.06) :
                                isUnlocked ? AppColors.cardBackground :
                                Color.white.opacity(0.06)
                        ))
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(
                LinearGradient(colors: [
                    isCompleted ? AppColors.accentGold.opacity(0.4) :
                        isUnlocked ? categoryColor.opacity(0.3) :
                        Color.white.opacity(0.12),
                    .clear
                ], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1
            ))
            .shadow(
                color: isCompleted ? AppColors.accentGold.opacity(0.12) :
                    isUnlocked ? categoryColor.opacity(0.08) : .clear,
                radius: 16, y: 4
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .opacity(isUnlocked ? 1 : 0.7)
            if isLeft { Spacer() }
        }
        .scaleEffect(appear ? 1 : 0.8).opacity(appear ? 1 : 0).offset(x: appear ? 0 : (isLeft ? -50 : 50))
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(delay)) { appear = true }
            if isUnlocked && !isCompleted {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(delay)) { pulse = true }
            }
        }
    }
    
    private var nodeCircle: some View {
        ZStack {
            if isUnlocked && !isCompleted {
                Circle().stroke(categoryColor.opacity(0.25), lineWidth: 2).frame(width: 54, height: 54)
                    .scaleEffect(pulse ? 1.4 : 1.0).opacity(pulse ? 0 : 0.7)
            }
            Circle().stroke(
                LinearGradient(
                    colors: isCompleted
                    ? [AppColors.accentGold, .orange]
                    : isUnlocked
                    ? [categoryColor, categoryColor.opacity(0.3)]
                    : [Color.white.opacity(0.25), Color.white.opacity(0.12)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                lineWidth: isCompleted ? 3 : 2
            ).frame(width: 46, height: 46)
            
            Circle().fill(
                isCompleted
                ? LinearGradient(colors: [AppColors.accentGold, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                : isUnlocked
                ? LinearGradient(colors: [categoryColor.opacity(0.15), categoryColor.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
            ).frame(width: 42, height: 42)
            
            if isCompleted {
                Image(systemName: "checkmark").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            } else if !isUnlocked {
                Image(systemName: "lock.fill").font(.system(size: 13)).foregroundColor(.white.opacity(0.45))
            } else {
                Text("\(level.number)").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(categoryColor)
            }
        }
    }
    
    private var nodeInfo: some View {
        VStack(alignment: isLeft ? .leading : .trailing, spacing: 4) {
            Text(level.title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(isUnlocked ? .white : .white.opacity(0.55))
            Text(level.description)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(isUnlocked ? .white.opacity(0.45) : .white.opacity(0.35))
                .lineLimit(2)
                .multilineTextAlignment(isLeft ? .leading : .trailing)
            HStack(spacing: 3) {
                ForEach(0..<level.stars.count, id: \.self) { _ in
                    Image(systemName: isCompleted ? "star.fill" : "star")
                        .font(.system(size: 7))
                        .foregroundColor(
                            isCompleted ? AppColors.accentGold :
                                isUnlocked ? categoryColor.opacity(0.35) :
                                    .white.opacity(0.25)
                        )
                }
            }
        }
    }
}

