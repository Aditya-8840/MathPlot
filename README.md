# 🎱 MathPlot

**Where Math Becomes a Game**

MathPlot is an interactive educational iOS app built with Swift Playgrounds that teaches mathematical functions through a gamified marble-rolling experience. Players manipulate equation parameters using sliders to shape curves on a coordinate graph, then roll a marble along the curve to collect stars and complete levels.

---

## ✨ Features

### 🎮 Core Gameplay
- **50 Levels** across 5 mathematical function categories (10 levels each)
- **Interactive Graph Manipulation** — adjust parameters (slope, amplitude, frequency, etc.) via sliders to shape the curve in real-time
- **Marble Physics Simulation** — roll a marble along your plotted curve with speed influenced by the derivative of the function
- **Star Collection** — position stars on the coordinate plane that the marble collects when the curve passes through them
- **Haptic Feedback** — proximity-based haptics when the curve approaches a star, with stronger feedback on a match

### 📐 Function Categories
| Category | Formula | Description |
|---|---|---|
| **Linear** | `y = mx + c` | Straight lines with slope and intercept |
| **Quadratic** | `y = ax² + bx + c` | Parabolas that open up or down |
| **Polynomial** | `y = ax³ + bx + c` | Cubic curves with twists and turns |
| **Trigonometric** | `y = a·sin(bx + c)` | Waves that oscillate up and down |
| **Exponential** | `y = a·bˣ + c` | Rapidly growing or decaying curves |

### 📊 2D & 3D Graph Visualization
- **2D Graph View** — Canvas-rendered coordinate plane with grid lines, axis labels, tick marks, and a smooth function curve with glow effects
- **3D Graph View** — Full SceneKit-powered 3D visualization with:
  - Drag to rotate and pinch to zoom
  - 3D tube-geometry curves with phong lighting
  - Animated star nodes floating above the grid plane
  - Marble with realistic rolling animation
  - Trail particles left behind the marble

### 🧠 Quiz System
- **25 quiz questions** (5 per function category)
- Quizzes unlock after completing all 10 levels in a category
- Multiple-choice questions with detailed explanations
- Star-rated results (0–3 stars) based on score
- Contributes to overall category completion progress

### 🎨 Premium UI/UX
- **Dark theme** with glassmorphism effects and vibrant gradients
- **Animated onboarding** — 3-page walkthrough introducing the game mechanics
- **Animated splash screen** — orbiting particles, pulsating marble, gradient title
- **Level path map** — curved path connecting level nodes with completion indicators
- **Particle celebration effects** on level completion
- **Smooth spring and transition animations** throughout
- **Animated background stars** with shooting star effects
- **Edge-swipe navigation** for going back between screens

### 📚 Educational Info Sheet
- Detailed explanations of each function type
- Standard form with interactive legend
- Live parameter value display with descriptions
- Example calculations showing x → y output
- Quick tips specific to each function category

---

## 🏗️ Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern with a clean separation of concerns:

```
MathPlot.swiftpm/
├── MathPlotApp.swift            # App entry point (@main)
├── Package.swift                # Swift Package Manager manifest
│
├── Models/
│   ├── FunctionCategory.swift   # Enum: linear, quadratic, polynomial, trig, exponential
│   ├── GraphPoint.swift         # Simple x, y coordinate struct
│   ├── Level.swift              # Level & SliderConfig definitions
│   ├── Particle.swift           # Celebration particle model
│   ├── QuizQuestion.swift       # Quiz question with options & explanation
│   └── Star.swift               # Collectible star with position & state
│
├── ViewModel/
│   ├── GameViewModel.swift      # Core game logic, marble simulation, function evaluation
│   └── QuizViewModel.swift      # Quiz state management, scoring
│
├── Views/
│   ├── Root/
│   │   └── ContentView.swift    # Navigation controller (AppScreen state machine)
│   ├── Splash/
│   │   └── SplashView.swift     # Animated launch screen
│   ├── Onboarding/
│   │   └── OnboardingView.swift # 3-page tutorial with animated demos
│   ├── LevelSelection/
│   │   ├── CategorySelectionView.swift  # Function type chooser
│   │   ├── CategoryCard.swift           # Individual category card UI
│   │   └── LevelListView.swift          # Curved path level map
│   ├── Game/
│   │   ├── GameView.swift       # Main gameplay screen
│   │   ├── HUDView.swift        # Level info & star progress display
│   │   └── LevelCompleteView.swift  # Victory overlay with next actions
│   ├── Graph/
│   │   ├── GraphView.swift          # 2D Canvas-based graph renderer
│   │   ├── Graph3DView.swift        # SceneKit 3D graph (UIViewRepresentable)
│   │   └── Graph3DContainerView.swift # 2D/3D toggle container
│   ├── Quiz/
│   │   ├── QuizView.swift       # Quiz gameplay with animated transitions
│   │   └── QuizResultView.swift # Score display with star rating
│   ├── Components/
│   │   ├── EquationInfoSheet.swift  # Detailed function info bottom sheet
│   │   ├── MarbleView.swift         # Animated marble with glow & rotation
│   │   ├── MathSlider.swift         # Styled parameter slider control
│   │   └── StarShapeView.swift      # Animated collectible star
│   └── Effects/
│       ├── BackgroundStarsView.swift # Twinkling star field with shooting stars
│       └── ParticleView.swift       # Celebration particle burst effect
│
├── Data/
│   ├── LevelData.swift          # All 50 level definitions with star positions
│   └── QuizData.swift           # All 25 quiz questions with explanations
│
├── Theme/
│   └── AppColors.swift          # Centralized color palette & gradients
│
├── Utilities/
│   ├── HapticManager.swift      # UIKit haptic feedback triggers
│   └── SeededRandomGenerator.swift  # Deterministic RNG for background stars
│
└── Assets.xcassets/             # App icon
```

---

## 🔧 Technical Details

| Detail | Value |
|---|---|
| **Platform** | iOS 16.0+ |
| **Device Support** | iPhone & iPad |
| **Orientations** | Portrait, Landscape (iPad: all 4) |
| **Language** | Swift 6 |
| **Frameworks** | SwiftUI, SceneKit, UIKit |
| **App Category** | Education |
| **Bundle ID** | `in.galgotias.MathMarbelDemo` |
| **Architecture** | MVVM |
| **State Management** | `@StateObject`, `@ObservedObject`, `@Published`, `@AppStorage` |

### Key Technical Highlights

- **Async Marble Simulation** — The marble simulation runs via `Task` with `Task.sleep`, calculating position based on function evaluation and derivative-based speed modulation
- **SceneKit Integration** — Custom `UIViewRepresentable` wrapping `SCNView` with procedurally generated tube geometry for 3D curves, including incremental updates for performance
- **Canvas Rendering** — The 2D graph uses SwiftUI's `Canvas` API for high-performance grid and curve rendering with multi-pass glow effects
- **Seeded RNG** — Background star positions use a deterministic linear congruential generator to ensure consistent visuals across sessions
- **Haptic Proximity System** — Real-time distance checking between the curve and star positions with threshold-based haptic feedback

---

## 🚀 Getting Started

### Prerequisites
- **Xcode 15+** or **Swift Playgrounds 4.4+**
- macOS Ventura (14.0) or later
- iOS 16.0+ device or simulator

### Running the App

#### In Swift Playgrounds
1. Open the `MathPlot.swiftpm` folder directly in **Swift Playgrounds** on iPad or Mac
2. Tap **Run** to launch

#### In Xcode
1. Open `MathPlot.swiftpm` as a Swift Playground project in **Xcode**
2. Select a target device or simulator
3. Press `⌘R` to build and run

---

## 🎯 How to Play

1. **Choose a Category** — Select from Linear, Quadratic, Polynomial, Trigonometric, or Exponential functions
2. **Select a Level** — Levels unlock sequentially; locked levels require completing the previous one
3. **Adjust Parameters** — Use the sliders to shape the equation so the curve passes through all the stars
4. **Run the Marble** — Tap "Run Marble" to simulate the marble rolling along your curve
5. **Collect Stars** — If the curve passes close enough to a star, the marble collects it
6. **Complete the Level** — Collect all stars to complete the level and unlock the next one
7. **Take the Quiz** — After completing all 10 levels in a category, take a 5-question quiz to test your understanding
8. **Toggle 3D View** — Use the 3D button to visualize the graph from multiple angles

---

## 📝 Level Progression

Each function category has **10 levels** with progressively increasing difficulty:

- **Levels 1–3**: Single parameter, 1–2 stars
- **Levels 4–6**: Two parameters unlocked, 2–3 stars
- **Levels 7–10**: All parameters available, 3–4 stars, precision challenges

After completing all 10 levels, a **bonus quiz** unlocks with 5 multiple-choice questions.

---

## 📄 License

This project is for educational purposes.

---

<p align="center">
  Built with ❤️ using SwiftUI & SceneKit
</p>
