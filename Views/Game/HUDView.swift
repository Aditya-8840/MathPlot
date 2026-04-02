import SwiftUI

struct HUDView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.currentLevel.category.rawValue) · Level \(viewModel.currentLevel.number)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(viewModel.currentLevel.category.color)

                Text(viewModel.currentLevel.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()

            HStack(spacing: 4) {
                ForEach(viewModel.stars) { star in
                    Image(systemName: star.isCollected ? "star.fill" : "star")
                        .foregroundColor(
                            star.isCollected ? AppColors.starGlow : .white.opacity(0.3)
                        )
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal)
    }
}

