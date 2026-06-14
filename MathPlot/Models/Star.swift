
import Foundation

struct Star: Identifiable {
    let id = UUID()
    var position: GraphPoint
    var isCollected: Bool = false
    var collectTime: Date? = nil
}

