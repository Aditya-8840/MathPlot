import SwiftUI

struct GraphView: View {
    @ObservedObject var viewModel: GameViewModel
    let size: CGSize

    private var gridRange: ClosedRange<Double> { viewModel.currentLevel.gridRange }
    private var rangeSpan: Double { gridRange.upperBound - gridRange.lowerBound }

    func toScreenX(_ x: Double) -> CGFloat {
        CGFloat((x - gridRange.lowerBound) / rangeSpan) * size.width
    }

    func toScreenY(_ y: Double) -> CGFloat {
        size.height - CGFloat((y - gridRange.lowerBound) / rangeSpan) * size.height
    }

    var body: some View {
        ZStack {
            gridAndCurveCanvas
            axisLabelsOverlay
            trailLayer
            starsLayer
            MarbleView(screenX: toScreenX(viewModel.marbleX), screenY: toScreenY(viewModel.marbleY))
        }
        .frame(width: size.width, height: size.height)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.background.opacity(0.7))
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [
                            viewModel.currentLevel.category.color.opacity(0.3),
                            viewModel.currentLevel.category.color.opacity(0.05),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: viewModel.currentLevel.category.color.opacity(0.1), radius: 20, y: 4)
    }

    private var gridAndCurveCanvas: some View {
        Canvas { context, canvasSize in
            let lower = Int(gridRange.lowerBound)
            let upper = Int(gridRange.upperBound)

            for i in lower...upper {
                let x = toScreenX(Double(i))
                let isAxis = i == 0

                var vPath = Path()
                vPath.move(to: CGPoint(x: x, y: 0))
                vPath.addLine(to: CGPoint(x: x, y: canvasSize.height))
                context.stroke(
                    vPath,
                    with: .color(isAxis ? AppColors.gridMajor : Color.white.opacity(0.12)),
                    lineWidth: isAxis ? 1.5 : 0.5
                )

                let y = toScreenY(Double(i))
                var hPath = Path()
                hPath.move(to: CGPoint(x: 0, y: y))
                hPath.addLine(to: CGPoint(x: canvasSize.width, y: y))
                context.stroke(
                    hPath,
                    with: .color(isAxis ? AppColors.gridMajor : Color.white.opacity(0.12)),
                    lineWidth: isAxis ? 1.5 : 0.5
                )

                if i != 0 {
                    let originY = toScreenY(0)
                    var xTick = Path()
                    xTick.move(to: CGPoint(x: x, y: originY - 4))
                    xTick.addLine(to: CGPoint(x: x, y: originY + 4))
                    context.stroke(xTick, with: .color(Color.white.opacity(0.3)), lineWidth: 1)

                    let originX = toScreenX(0)
                    var yTick = Path()
                    yTick.move(to: CGPoint(x: originX - 4, y: y))
                    yTick.addLine(to: CGPoint(x: originX + 4, y: y))
                    context.stroke(yTick, with: .color(Color.white.opacity(0.3)), lineWidth: 1)
                }
            }

            let steps = 400
            var curvePath = Path()
            var started = false

            for s in 0...steps {
                let x = gridRange.lowerBound + rangeSpan * Double(s) / Double(steps)
                let y = viewModel.evaluateFunction(at: x)
                guard y.isFinite && abs(y) < 100 else {
                    started = false
                    continue
                }
                let screenPoint = CGPoint(x: toScreenX(x), y: toScreenY(y))
                if !started {
                    curvePath.move(to: screenPoint)
                    started = true
                } else {
                    curvePath.addLine(to: screenPoint)
                }
            }

            context.stroke(curvePath, with: .color(AppColors.functionLine.opacity(0.12)), lineWidth: 12)
            context.stroke(curvePath, with: .color(AppColors.functionLine.opacity(0.25)), lineWidth: 5)
            context.stroke(curvePath, with: .color(AppColors.functionLine), lineWidth: 2)
        }
    }

    private var axisLabelsOverlay: some View {
        let lower = Int(gridRange.lowerBound)
        let upper = Int(gridRange.upperBound)
        let originX = toScreenX(0)
        let originY = toScreenY(0)

        return ZStack {
            ForEach(lower...upper, id: \.self) { i in
                if i != 0 {
                    Text("\(i)")
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.7))
                        .position(
                            x: toScreenX(Double(i)),
                            y: min(max(originY + 12, 12), size.height - 6)
                        )
                }
            }

            ForEach(lower...upper, id: \.self) { i in
                if i != 0 {
                    Text("\(i)")
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 0.4, green: 1.0, blue: 0.6).opacity(0.7))
                        .position(
                            x: min(max(originX + 12, 14), size.width - 10),
                            y: toScreenY(Double(i))
                        )
                }
            }

            Text("x")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.8))
                .position(
                    x: size.width - 10,
                    y: min(max(originY - 10, 10), size.height - 10)
                )

            Text("y")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.4, green: 1.0, blue: 0.6).opacity(0.8))
                .position(
                    x: min(max(originX + 12, 14), size.width - 10),
                    y: 10
                )

            Text("0")
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.35))
                .position(
                    x: originX + 8,
                    y: originY + 10
                )
        }
    }

    private var trailLayer: some View {
        ForEach(
            Array(viewModel.marbleTrail.enumerated()),
            id: \.offset
        ) { index, point in
            let opacity = Double(index) / Double(max(viewModel.marbleTrail.count, 1))
            Circle()
                .fill(viewModel.currentLevel.category.color.opacity(opacity * 0.5))
                .frame(width: 3, height: 3)
                .position(x: toScreenX(point.x), y: toScreenY(point.y))
        }
    }

    private var starsLayer: some View {
        ForEach(viewModel.stars) { star in
            StarShapeView(
                star: star,
                screenX: toScreenX(star.position.x),
                screenY: toScreenY(star.position.y)
            )
        }
    }
}

