# MathPlot

MathPlot is an interactive, educational iOS game built with SwiftUI that makes learning mathematical functions fun and engaging. By manipulating equation parameters (like `m`, `c`, `h`, `k`) via intuitive sliders, players visually transform graphs to solve puzzles, collect stars, and complete levels across various function categories.

## 🚀 Features

- **Interactive Graphing**: Real-time visual feedback as you adjust variables for different math functions (Linear, Quadratic, Trigonometric, etc.).
- **Progressive Levels**: Hand-crafted levels that gradually introduce new mathematical concepts.
- **Engaging Gameplay**: Modify your function's curve to collect stars scattered across the coordinate plane.
- **Quizzes**: Test your knowledge after completing categories to reinforce learning.
- **Beautiful UI**: Modern, dark-mode optimized design with smooth SwiftUI animations and particle effects.
- **3D Graphing Capabilities**: Explore mathematical concepts in a three-dimensional space.
- **Onboarding Experience**: A smooth introduction to the game mechanics for new players.

## 🛠️ Technology Stack

- **Platform**: iOS
- **Framework**: SwiftUI
- **Language**: Swift 5.0+
- **Architecture**: MVVM (Model-View-ViewModel)

## 📁 Project Structure

The codebase is organized into several key directories:
- `Views/`: Contains all SwiftUI views, broken down by feature (`Game`, `Graph`, `LevelSelection`, `Quiz`, `Onboarding`, etc.).
- `ViewModel/`: Contains the core logic and state management (`GameViewModel`, `QuizViewModel`).
- `Models/`: Data structures representing game entities (`Level`, `Star`, `FunctionCategory`, `QuizQuestion`, `Particle`).
- `Data/`: Static content for levels and quizzes (`LevelData`, `QuizData`).
- `Theme/` & `Utilities/`: Shared colors, styling, and helper functions (like Haptic feedback).

## 🏃 Getting Started

### Prerequisites
- Xcode 15.0 or later.
- iOS 17.0+ deployment target.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Aditya-8840/MathPlot.git
   ```
2. Open `MathPlot.xcodeproj` in Xcode.
3. Select your target device or simulator.
4. Build and Run (`Cmd + R`).

## 🎮 How to Play

1. Select a **Function Category** (e.g., Linear).
2. Choose a **Level**.
3. Use the **Sliders** at the bottom of the screen to adjust the variables of the given equation.
4. Match the curve to intercept the **Stars** on the graph.
5. Once all stars are collected, you pass the level!

## 👨‍💻 Author

Aditya Gupta
