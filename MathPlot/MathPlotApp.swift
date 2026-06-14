//
//  MathPlotApp.swift
//  MathPlot
//
//  Created by Aditya Gupta on 10/06/26.
//

import SwiftUI

@main
struct MarbleMathApp: App {
    @State private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}

