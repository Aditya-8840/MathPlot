
import SwiftUI

struct Graph3DContainerView: View {
    @ObservedObject var viewModel: GameViewModel
    let size: CGSize
    @Binding var is3DMode: Bool

    @State private var rotateHint = true

    var body: some View {
        ZStack {
            if is3DMode {
                Graph3DView(viewModel: viewModel, size: size)
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppColors.accent.opacity(0.4),
                                        AppColors.functionLine.opacity(0.2),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: AppColors.accent.opacity(0.15), radius: 20, y: 4)
                    .overlay(alignment: .topLeading) {
                        HStack(spacing: 4) {
                            Image(systemName: "cube.fill")
                                .font(.system(size: 10))
                            Text("3D")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(AppColors.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(AppColors.accent.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(AppColors.accent.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(10)
                    }
                    .overlay(alignment: .bottom) {
                        if rotateHint {
                            HStack(spacing: 6) {
                                Image(systemName: "hand.draw.fill")
                                    .font(.system(size: 12))
                                Text("Drag to rotate · Pinch to zoom")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.6))
                            )
                            .padding(.bottom, 10)
                            .transition(.opacity)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        rotateHint = false
                                    }
                                }
                            }
                        }
                    }
            } else {
                GraphView(viewModel: viewModel, size: size)
                    .frame(width: size.width, height: size.height)
            }
        }
    }
}
