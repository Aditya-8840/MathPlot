import SwiftUI

struct CategoryCard: View {
    let category: FunctionCategory
    let completedCount: Int
    let totalCount: Int
    let delay: Double
    var cardHeight: CGFloat = 100

    @State private var appear = false
    @State private var iconPulse = false

    private var progress: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
    }

    private var isFullyCompleted: Bool {
        completedCount == totalCount && totalCount > 0
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.12))
                    .frame(width: 56, height: 56)
                    .blur(radius: 10)
                    .scaleEffect(iconPulse ? 1.2 : 1.0)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                category.color.opacity(0.25),
                                category.color.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        category.color.opacity(0.6),
                                        category.color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )

                if isFullyCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.accentGold, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                } else {
                    Image(systemName: category.icon)
                        .font(.system(size: 20))
                        .foregroundColor(category.color)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(category.formula)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(category.color)

                Text(category.description)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(1)
            }

            Spacer()

            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 3)
                        .frame(width: 38, height: 38)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            category.color,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 38, height: 38)
                        .rotationEffect(.degrees(-90))

                    Text("\(completedCount)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(
                            isFullyCompleted ? AppColors.accentGold : .white.opacity(0.6)
                        )
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.2))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .glassEffect(.regular.tint(category.color.opacity(0.10)), in: .rect(cornerRadius: 20))
            } else {
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            category.color.opacity(0.25),
                            category.color.opacity(0.05),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: category.color.opacity(0.08), radius: 20, y: 8)
        .scaleEffect(appear ? 1 : 0.92)
        .opacity(appear ? 1 : 0)
        .offset(x: appear ? 0 : 30)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(delay)) {
                appear = true
            }
            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
                .delay(delay)
            ) {
                iconPulse = true
            }
        }
    }
}

