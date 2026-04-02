import Foundation

struct SliderConfig {
    var showM: Bool = false
    var showA: Bool = false
    var showB: Bool = false
    var showC: Bool = false
    var showH: Bool = false
    var showK: Bool = false

    var mLabel: String = "m"
    var aLabel: String = "a"
    var bLabel: String = "b"
    var cLabel: String = "c"
    var hLabel: String = "h"
    var kLabel: String = "k"

    var mRange: ClosedRange<Double> = -5...5
    var aRange: ClosedRange<Double> = -3...3
    var bRange: ClosedRange<Double> = -3...3
    var cRange: ClosedRange<Double> = -5...5
    var hRange: ClosedRange<Double> = -5...5
    var kRange: ClosedRange<Double> = -5...5
}

struct Level: Identifiable {
    let id: String
    let number: Int
    let title: String
    let description: String
    let category: FunctionCategory
    let stars: [Star]
    let sliderConfig: SliderConfig
    let initialM: Double
    let initialC: Double
    let initialA: Double
    let initialB: Double
    let initialH: Double
    let initialK: Double
    let gridRange: ClosedRange<Double>
}

