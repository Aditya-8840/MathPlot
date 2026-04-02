import SwiftUI

struct ParticleView: View {
    @State private var particles: [Particle] = []

    let timer = Timer.publish(
        every: 0.05,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            Color(
                                hue: particle.hue,
                                saturation: 0.8,
                                brightness: 1.0
                            )
                        )
                        .frame(
                            width: 6 * particle.scale,
                            height: 6 * particle.scale
                        )
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onReceive(timer) { _ in
                updateParticles(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func updateParticles(in size: CGSize) {
        if particles.count < 40 {
            let newParticle = Particle(
                x: CGFloat.random(in: 0...size.width),
                y: size.height + 10,
                scale: CGFloat.random(in: 0.5...2.0),
                opacity: 1.0,
                rotation: Double.random(in: 0...360),
                hue: Double.random(in: 0...1)
            )
            particles.append(newParticle)
        }

        for i in particles.indices {
            particles[i].y -= CGFloat.random(in: 2...6)
            particles[i].x += CGFloat.random(in: -2...2)
            particles[i].opacity -= 0.02
            particles[i].rotation += Double.random(in: -5...5)
        }

        particles.removeAll { $0.opacity <= 0 || $0.y < -20 }
    }
}

