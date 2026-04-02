import Foundation

struct LevelData {

    static func allLevels() -> [Level] {
        var all: [Level] = []
        all.append(contentsOf: linearLevels())
        all.append(contentsOf: quadraticLevels())
        all.append(contentsOf: polynomialLevels())
        all.append(contentsOf: trigonometricLevels())
        all.append(contentsOf: exponentialLevels())
        return all
    }

    static func levels(for category: FunctionCategory) -> [Level] {
        allLevels().filter { $0.category == category }
    }

    private static func linearLevels() -> [Level] {
        let c = FunctionCategory.linear
        return [
            
            Level(id: "lin_1", number: 1, title: "First Roll",
                  description: "Set the slope to reach the star!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 3, y: 3))],
                  sliderConfig: SliderConfig(showM: true, mLabel: "m (slope)"),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -5...5),

            Level(id: "lin_2", number: 2, title: "Downhill",
                  description: "Try a negative slope!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 2, y: -2))],
                  sliderConfig: SliderConfig(showM: true, mLabel: "m (slope)"),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -5...5),

            Level(id: "lin_3", number: 3, title: "Steep Climb",
                  description: "Collect both stars on a steep line!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 1, y: 2)), Star(position: GraphPoint(x: 2, y: 4))],
                  sliderConfig: SliderConfig(showM: true, mLabel: "m (slope)"),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -6...6),

            Level(id: "lin_4", number: 4, title: "Lift Off",
                  description: "Use the intercept to shift your line up!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 0, y: 2)), Star(position: GraphPoint(x: 4, y: 4))],
                  sliderConfig: SliderConfig(showM: true, showC: true, mLabel: "m (slope)", cLabel: "c (intercept)"),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -6...6),

            Level(id: "lin_5", number: 5, title: "Crossing Zero",
                  description: "Stars above and below — find the line!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: -1)), Star(position: GraphPoint(x: 2, y: 1))],
                  sliderConfig: SliderConfig(showM: true, showC: true, mLabel: "m (slope)", cLabel: "c (intercept)"),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -6...6),

            Level(id: "lin_6", number: 6, title: "Precision Line",
                  description: "Align precisely to get all stars.",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: 1)), Star(position: GraphPoint(x: 1, y: 2.5)), Star(position: GraphPoint(x: 3, y: 3.5))],
                  sliderConfig: SliderConfig(showM: true, showC: true, mLabel: "m (slope)", cLabel: "c (intercept)"),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -6...6),

            Level(id: "lin_7", number: 7, title: "Triple Catch",
                  description: "Three stars, one perfect line!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: -3)), Star(position: GraphPoint(x: 0, y: 1)), Star(position: GraphPoint(x: 2, y: 5))],
                  sliderConfig: SliderConfig(showM: true, showC: true, mLabel: "m (slope)", cLabel: "c (intercept)"),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -7...7),

            Level(id: "lin_8", number: 8, title: "Gentle Slope",
                  description: "Sometimes less is more.",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -4, y: -1)), Star(position: GraphPoint(x: 0, y: 1)), Star(position: GraphPoint(x: 4, y: 3))],
                  sliderConfig: SliderConfig(showM: true, showC: true, mLabel: "m (slope)", cLabel: "c (intercept)"),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -7...7),

            Level(id: "lin_9", number: 9, title: "The Gauntlet",
                  description: "Four stars — extreme precision!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: 7)), Star(position: GraphPoint(x: 0, y: 3)), Star(position: GraphPoint(x: 1, y: 1)), Star(position: GraphPoint(x: 3, y: -3))],
                  sliderConfig: SliderConfig(showM: true, showC: true, mLabel: "m (slope)", cLabel: "c (intercept)"),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -8...8),

            Level(id: "lin_10", number: 10, title: "Linear Master",
                  description: "The ultimate linear challenge!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -4, y: -8)), Star(position: GraphPoint(x: -1, y: -3.5)), Star(position: GraphPoint(x: 2, y: 1)), Star(position: GraphPoint(x: 4, y: 4))],
                  sliderConfig: SliderConfig(showM: true, showC: true, mLabel: "m (slope)", cLabel: "c (intercept)", mRange: -5...5, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -10...10),
        ]
    }

    private static func quadraticLevels() -> [Level] {
        let c = FunctionCategory.quadratic
        return [
            
            Level(id: "quad_1", number: 1, title: "Curve Ahead",
                  description: "Adjust 'a' to create a curve!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 2, y: 4))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (curve)", aRange: -3...3),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -6...6),

            Level(id: "quad_2", number: 2, title: "Valley Run",
                  description: "Catch stars on both sides!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: 4)), Star(position: GraphPoint(x: 2, y: 4))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (curve)", aRange: -3...3),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -6...6),

            Level(id: "quad_3", number: 3, title: "Mountain",
                  description: "Flip the curve upside down!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: -4)), Star(position: GraphPoint(x: 2, y: -4))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (curve)", aRange: -3...3),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -6...6),

            Level(id: "quad_4", number: 4, title: "Shifted Bowl",
                  description: "Move the parabola up or down!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 0, y: 2)), Star(position: GraphPoint(x: 2, y: 6))],
                  sliderConfig: SliderConfig(showA: true, showC: true, aLabel: "a (curve)", cLabel: "c (shift)", aRange: -3...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -6...6),

            Level(id: "quad_5", number: 5, title: "Arch Shot",
                  description: "Create an arch over the stars.",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: 0)), Star(position: GraphPoint(x: 0, y: 4)), Star(position: GraphPoint(x: 2, y: 0))],
                  sliderConfig: SliderConfig(showA: true, showC: true, aLabel: "a (curve)", cLabel: "c (shift)", aRange: -3...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -6...6),

            Level(id: "quad_6", number: 6, title: "Deep Valley",
                  description: "Reach stars at the bottom!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 0, y: -3)), Star(position: GraphPoint(x: 3, y: 6))],
                  sliderConfig: SliderConfig(showA: true, showC: true, aLabel: "a (curve)", cLabel: "c (shift)", aRange: -3...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -7...7),

            Level(id: "quad_7", number: 7, title: "Tilted Curve",
                  description: "Add tilt to your parabola!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 1, y: -1)), Star(position: GraphPoint(x: 3, y: 3))],
                  sliderConfig: SliderConfig(showM: true, showA: true, showC: true, mLabel: "b (tilt)", aLabel: "a (curve)", cLabel: "c (shift)", mRange: -5...5, aRange: -3...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -7...7),

            Level(id: "quad_8", number: 8, title: "Full Control",
                  description: "Use all sliders for the perfect parabola!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: 5)), Star(position: GraphPoint(x: 0, y: 1)), Star(position: GraphPoint(x: 2, y: 5))],
                  sliderConfig: SliderConfig(showM: true, showA: true, showC: true, mLabel: "b (tilt)", aLabel: "a (curve)", cLabel: "c (shift)", mRange: -5...5, aRange: -3...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -8...8),

            Level(id: "quad_9", number: 9, title: "Razor Parabola",
                  description: "Threading the needle with curves!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -3, y: 2.5)), Star(position: GraphPoint(x: -2, y: 0)), Star(position: GraphPoint(x: 2, y: 0)), Star(position: GraphPoint(x: 3, y: 2.5))],
                  sliderConfig: SliderConfig(showM: true, showA: true, showC: true, mLabel: "b (tilt)", aLabel: "a (curve)", cLabel: "c (shift)", mRange: -5...5, aRange: -3...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -8...8),

            Level(id: "quad_10", number: 10, title: "Parabola Master",
                  description: "The ultimate quadratic challenge!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -3, y: 5.5)), Star(position: GraphPoint(x: -1, y: -0.5)), Star(position: GraphPoint(x: 1, y: -2.5)), Star(position: GraphPoint(x: 4, y: 2))],
                  sliderConfig: SliderConfig(showM: true, showA: true, showC: true, mLabel: "b (tilt)", aLabel: "a (curve)", cLabel: "c (shift)", mRange: -5...5, aRange: -3...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -8...8),
        ]
    }

    private static func polynomialLevels() -> [Level] {
        let c = FunctionCategory.polynomial
        return [
         
            Level(id: "poly_1", number: 1, title: "First Twist",
                  description: "Adjust 'a' for a gentle S-curve!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 1, y: 1))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (cubic)", aRange: -2...2),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -5...5),

            Level(id: "poly_2", number: 2, title: "S-Curve",
                  description: "The classic cubic shape!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -1, y: -1)), Star(position: GraphPoint(x: 1, y: 1))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (cubic)", aRange: -2...2),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -5...5),

            Level(id: "poly_3", number: 3, title: "Reverse Twist",
                  description: "Try a negative cubic coefficient!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -1, y: 1)), Star(position: GraphPoint(x: 1, y: -1))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (cubic)", aRange: -2...2),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -5...5),

            Level(id: "poly_4", number: 4, title: "Twisted Path",
                  description: "Add a linear term to shift the twist!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 1, y: -1)), Star(position: GraphPoint(x: 2, y: 4))],
                  sliderConfig: SliderConfig(showA: true, showB: true, aLabel: "a (cubic)", bLabel: "b (linear)", aRange: -2...2, bRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -6...6),

            Level(id: "poly_5", number: 5, title: "Smooth Ride",
                  description: "Navigate the gentle S-curve!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: -4)), Star(position: GraphPoint(x: 0, y: 0)), Star(position: GraphPoint(x: 2, y: 4))],
                  sliderConfig: SliderConfig(showA: true, showB: true, aLabel: "a (cubic)", bLabel: "b (linear)", aRange: -2...2, bRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -7...7),

            Level(id: "poly_6", number: 6, title: "Wave Rider",
                  description: "Ride the cubic wave!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -1, y: 2)), Star(position: GraphPoint(x: 1, y: -2)), Star(position: GraphPoint(x: 2, y: 2))],
                  sliderConfig: SliderConfig(showA: true, showB: true, aLabel: "a (cubic)", bLabel: "b (linear)", aRange: -2...2, bRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -6...6),

            Level(id: "poly_7", number: 7, title: "Full Cubic",
                  description: "All controls unlocked!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: -6)), Star(position: GraphPoint(x: 0, y: 2)), Star(position: GraphPoint(x: 2, y: 10))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a (cubic)", bLabel: "b (linear)", cLabel: "c (shift)", aRange: -2...2, bRange: -5...5, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -8...8),

            Level(id: "poly_8", number: 8, title: "Serpentine",
                  description: "Thread through a zigzag of stars!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: 0)), Star(position: GraphPoint(x: -1, y: -1.5)), Star(position: GraphPoint(x: 1, y: 1.5)), Star(position: GraphPoint(x: 2, y: 0))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a (cubic)", bLabel: "b (linear)", cLabel: "c (shift)", aRange: -2...2, bRange: -5...5, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -8...8),

            Level(id: "poly_9", number: 9, title: "Deep Snake",
                  description: "Navigate the deep curves!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: 3)), Star(position: GraphPoint(x: -1, y: 3.5)), Star(position: GraphPoint(x: 1, y: -1.5)), Star(position: GraphPoint(x: 2, y: -1))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a (cubic)", bLabel: "b (linear)", cLabel: "c (shift)", aRange: -2...2, bRange: -5...5, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -8...8),

            Level(id: "poly_10", number: 10, title: "Polynomial Master",
                  description: "The ultimate polynomial challenge!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2, y: 2)), Star(position: GraphPoint(x: -1, y: -2)), Star(position: GraphPoint(x: 1, y: 2)), Star(position: GraphPoint(x: 2, y: -2))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a", bLabel: "b", cLabel: "c", aRange: -2...2, bRange: -5...5, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0, initialH: 0, initialK: 0,
                  gridRange: -10...10),
        ]
    }

    private static func trigonometricLevels() -> [Level] {
        let c = FunctionCategory.trigonometric
        return [
            Level(id: "trig_1", number: 1, title: "First Wave",
                  description: "Adjust amplitude to reach the star!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 1.57, y: 2))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (amplitude)", aRange: -4...4),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 1, initialH: 0, initialK: 0,
                  gridRange: -7...7),

            Level(id: "trig_2", number: 2, title: "Wave Peaks",
                  description: "Catch stars at the peaks!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 1.57, y: 1)), Star(position: GraphPoint(x: 4.71, y: -1))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (amplitude)", aRange: -4...4),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 1, initialH: 0, initialK: 0,
                  gridRange: -7...7),

            Level(id: "trig_3", number: 3, title: "Flip Wave",
                  description: "Try negative amplitude!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 1.57, y: -2)), Star(position: GraphPoint(x: 4.71, y: 2))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (amplitude)", aRange: -4...4),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 1, initialH: 0, initialK: 0,
                  gridRange: -7...7),

            Level(id: "trig_4", number: 4, title: "Frequency Shift",
                  description: "Change how fast the wave oscillates!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 0.785, y: 2)), Star(position: GraphPoint(x: 2.356, y: -2))],
                  sliderConfig: SliderConfig(showA: true, showB: true, aLabel: "a (amplitude)", bLabel: "b (frequency)", aRange: -4...4, bRange: 0.5...4),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0.5, initialH: 0, initialK: 0,
                  gridRange: -7...7),

            Level(id: "trig_5", number: 5, title: "Wave Match",
                  description: "Match the wave to three stars!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 0, y: 0)), Star(position: GraphPoint(x: 1.57, y: 2)), Star(position: GraphPoint(x: 3.14, y: 0))],
                  sliderConfig: SliderConfig(showA: true, showB: true, aLabel: "a (amplitude)", bLabel: "b (frequency)", aRange: -4...4, bRange: 0.5...4),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0.5, initialH: 0, initialK: 0,
                  gridRange: -7...7),

            Level(id: "trig_6", number: 6, title: "Tight Waves",
                  description: "High frequency challenge!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 0.785, y: 1.5)), Star(position: GraphPoint(x: 2.356, y: -1.5)), Star(position: GraphPoint(x: 3.927, y: 1.5))],
                  sliderConfig: SliderConfig(showA: true, showB: true, aLabel: "a (amplitude)", bLabel: "b (frequency)", aRange: -4...4, bRange: 0.5...4),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0.5, initialH: 0, initialK: 0,
                  gridRange: -7...7),

            Level(id: "trig_7", number: 7, title: "Phase Shift",
                  description: "Slide the wave left or right!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 0, y: 2)), Star(position: GraphPoint(x: 3.14, y: -2))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a (amp)", bLabel: "b (freq)", cLabel: "c (phase)", aRange: -4...4, bRange: 0.5...4, cRange: -3.14...3.14),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0.5, initialH: 0, initialK: 0,
                  gridRange: -8...8),

            Level(id: "trig_8", number: 8, title: "Full Wave",
                  description: "All controls — ride the wave!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -1.57, y: -3)), Star(position: GraphPoint(x: 0, y: 0)), Star(position: GraphPoint(x: 1.57, y: 3))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a (amp)", bLabel: "b (freq)", cLabel: "c (phase)", aRange: -4...4, bRange: 0.5...4, cRange: -3.14...3.14),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0.5, initialH: 0, initialK: 0,
                  gridRange: -8...8),

            Level(id: "trig_9", number: 9, title: "Sine Slalom",
                  description: "Weave through the stars!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -2.09, y: -2)), Star(position: GraphPoint(x: 0, y: 0)), Star(position: GraphPoint(x: 1.047, y: 2)), Star(position: GraphPoint(x: 3.14, y: 0))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a (amp)", bLabel: "b (freq)", cLabel: "c (phase)", aRange: -4...4, bRange: 0.5...4, cRange: -3.14...3.14),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0.5, initialH: 0, initialK: 0,
                  gridRange: -8...8),

            Level(id: "trig_10", number: 10, title: "Trig Master",
                  description: "The ultimate trigonometric challenge!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -0.5, y: 0)), Star(position: GraphPoint(x: 0.285, y: 2)), Star(position: GraphPoint(x: 1.07, y: 0)), Star(position: GraphPoint(x: 1.856, y: -2))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a (amp)", bLabel: "b (freq)", cLabel: "c (phase)", aRange: -4...4, bRange: 0.5...4, cRange: -3.14...3.14),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 0.5, initialH: 0, initialK: 0,
                  gridRange: -8...8),
        ]
    }

    private static func exponentialLevels() -> [Level] {
        let c = FunctionCategory.exponential
        return [
            Level(id: "exp_1", number: 1, title: "Growth Curve",
                  description: "Adjust 'a' for exponential growth!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 2, y: 4))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (scale)", aRange: -4...4),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 2, initialH: 0, initialK: 0,
                  gridRange: -4...6),

            Level(id: "exp_2", number: 2, title: "Rapid Rise",
                  description: "Watch it shoot upward!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 1, y: 2)), Star(position: GraphPoint(x: 3, y: 8))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (scale)", aRange: -4...4),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 2, initialH: 0, initialK: 0,
                  gridRange: -4...6),

            Level(id: "exp_3", number: 3, title: "Decay",
                  description: "Negative 'a' flips the curve!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 1, y: -2)), Star(position: GraphPoint(x: 2, y: -4))],
                  sliderConfig: SliderConfig(showA: true, aLabel: "a (scale)", aRange: -4...4),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 2, initialH: 0, initialK: 0,
                  gridRange: -4...6),

            Level(id: "exp_4", number: 4, title: "Base Change",
                  description: "Change the base of the exponent!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 1, y: 3)), Star(position: GraphPoint(x: 2, y: 9))],
                  sliderConfig: SliderConfig(showA: true, showB: true, aLabel: "a (scale)", bLabel: "b (base)", aRange: -4...4, bRange: 1.1...3),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 1.1, initialH: 0, initialK: 0,
                  gridRange: -4...6),

            Level(id: "exp_5", number: 5, title: "Shifted Growth",
                  description: "Lift the curve up or down!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 0, y: 3)), Star(position: GraphPoint(x: 2, y: 6))],
                  sliderConfig: SliderConfig(showA: true, showC: true, aLabel: "a (scale)", cLabel: "c (shift ↑)", aRange: -4...4, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 2, initialH: 0, initialK: 0,
                  gridRange: -4...6),

            Level(id: "exp_6", number: 6, title: "Exp Precision",
                  description: "All parameters for precise aiming!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 0, y: 2)), Star(position: GraphPoint(x: 2, y: 5)), Star(position: GraphPoint(x: 3, y: 9))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a", bLabel: "b (base)", cLabel: "c (shift)", aRange: -4...4, bRange: 1.1...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 1.1, initialH: 0, initialK: 0,
                  gridRange: -4...8),

            Level(id: "exp_7", number: 7, title: "Full Exponential",
                  description: "All controls — master the curve!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 0, y: 2)), Star(position: GraphPoint(x: 1, y: 4)), Star(position: GraphPoint(x: 2, y: 8))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a", bLabel: "b (base)", cLabel: "c (shift)", aRange: -4...4, bRange: 1.1...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 1.1, initialH: 0, initialK: 0,
                  gridRange: -4...10),

            Level(id: "exp_8", number: 8, title: "Exp Thread",
                  description: "Thread through the exponential!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: 0, y: 0)), Star(position: GraphPoint(x: 1, y: 1)), Star(position: GraphPoint(x: 3, y: 7))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a", bLabel: "b (base)", cLabel: "c (shift)", aRange: -4...4, bRange: 1.1...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 1.1, initialH: 0, initialK: 0,
                  gridRange: -4...10),

            Level(id: "exp_9", number: 9, title: "Steep Climb",
                  description: "Navigate the steep exponential!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -1, y: 0.75)), Star(position: GraphPoint(x: 1, y: 3)), Star(position: GraphPoint(x: 2, y: 6)), Star(position: GraphPoint(x: 3, y: 12))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a", bLabel: "b (base)", cLabel: "c (shift)", aRange: -4...4, bRange: 1.1...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 1.1, initialH: 0, initialK: 0,
                  gridRange: -4...10),

            Level(id: "exp_10", number: 10, title: "Exp Master",
                  description: "The ultimate exponential challenge!",
                  category: c,
                  stars: [Star(position: GraphPoint(x: -1, y: -2)), Star(position: GraphPoint(x: 0, y: -1)), Star(position: GraphPoint(x: 1, y: 1)), Star(position: GraphPoint(x: 3, y: 13))],
                  sliderConfig: SliderConfig(showA: true, showB: true, showC: true, aLabel: "a", bLabel: "b (base)", cLabel: "c (shift)", aRange: -4...4, bRange: 1.1...3, cRange: -5...5),
                  initialM: 0, initialC: 0, initialA: 0, initialB: 1.1, initialH: 0, initialK: 0,
                  gridRange: -4...10),
        ]
    }
}

