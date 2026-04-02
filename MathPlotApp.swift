import SwiftUI

@main
struct MarbleMathApp: App {
    @StateObject private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .preferredColorScheme(.dark)
        }
    }
}

