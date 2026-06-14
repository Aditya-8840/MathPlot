import SwiftUI

private struct StarParticle {
    let x: CGFloat
    let y: CGFloat
    let radius: CGFloat
    let baseOpacity: Double
    let driftRadius: CGFloat
    let driftSpeed: Double
    let driftPhase: Double
    let twinkleSpeed: Double
}

private let starParticles: [StarParticle] = {
    var rng = SeededRandomGenerator(seed: 42)
    return (0..<100).map { _ in
        let duration = Double.random(in: 4...8, using: &rng)
        return StarParticle(
            x: CGFloat.random(in: 0...1, using: &rng),
            y: CGFloat.random(in: 0...1, using: &rng),
            radius: CGFloat.random(in: 0.5...2.5, using: &rng),
            baseOpacity: Double.random(in: 0.15...0.6, using: &rng),
            driftRadius: CGFloat.random(in: 3...6, using: &rng),
            driftSpeed: (2 * .pi) / duration,
            driftPhase: Double.random(in: 0...(2 * .pi), using: &rng),
            twinkleSpeed: (2 * .pi) / Double.random(in: 2...5, using: &rng)
        )
    }
}()

struct BackgroundStarsView: View {
    @State private var shootingStarPhase = false

    var body: some View {
        ZStack {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate

                    for star in starParticles {
                        let angle = t * star.driftSpeed + star.driftPhase
                        let baseX = star.x * size.width
                        let baseY = star.y * size.height
                        let dx = star.driftRadius * CGFloat(cos(angle))
                        let dy = star.driftRadius * CGFloat(sin(angle * 0.7))
                        let sx = baseX + dx
                        let sy = baseY + dy

                        let twinkle = (sin(t * star.twinkleSpeed + star.driftPhase) + 1) / 2
                        let opacity = star.baseOpacity * (0.4 + 0.6 * twinkle)

                        context.opacity = opacity

                        context.fill(
                            Path(
                                ellipseIn: CGRect(
                                    x: sx - star.radius * 2,
                                    y: sy - star.radius * 2,
                                    width: star.radius * 4,
                                    height: star.radius * 4
                                )
                            ),
                            with: .color(.white.opacity(0.03))
                        )

                        context.fill(
                            Path(
                                ellipseIn: CGRect(
                                    x: sx - star.radius,
                                    y: sy - star.radius,
                                    width: star.radius * 2,
                                    height: star.radius * 2
                                )
                            ),
                            with: .color(.white)
                        )
                    }
                }
            }

            RoundedRectangle(cornerRadius: 1)
                .fill(
                    LinearGradient(
                        colors: [.white, .white.opacity(0)],
                        startPoint: .trailing,
                        endPoint: .leading
                    )
                )
                .frame(width: 60, height: 1.5)
                .rotationEffect(.degrees(-35))
                .offset(
                    x: shootingStarPhase ? 400 : -200,
                    y: shootingStarPhase ? -200 : 100
                )
                .opacity(shootingStarPhase ? 0 : 0.8)
        }
        .onAppear {
            startShootingStarLoop()
        }
    }

    private func startShootingStarLoop() {
        shootingStarPhase = false

        withAnimation(.easeOut(duration: 1.2).delay(0.5)) {
            shootingStarPhase = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            startShootingStarLoop()
        }
    }
}

