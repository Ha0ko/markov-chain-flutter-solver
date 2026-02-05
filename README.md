# Markov Chain Solver (Flutter)

Interactive Flutter app for building and simulating discrete-time Markov chains, with validation, detailed calculations, and probability visualizations.

## Features

- Define the number of states and generate a transition matrix of that size.
- Enter transition probabilities and automatically validate that each row sums to 1.
- Choose initial state distribution at instant t and a target instant k.
- Simulate the Markov chain by repeatedly multiplying the transition matrix by the state vector until instant k.
- Visualize state probabilities over time using charts.
- Display detailed intermediate calculations and a graph representation of the chain.
- Export the generated graph/visualization as an image.

## App Flow

1. **State count screen**  
   Choose the number of states; the app initializes the transition matrix.

2. **Transition matrix screen**  
   Fill in the transition probabilities; each row is checked to ensure it sums to 1.

3. **Simulation setup screen**  
   Set the initial probability vector at instant t and choose the target instant k.

4. **Results & visualization screen**  
   See the resulting probability distribution, a chart of probabilities per state, the graph of the chain, and detailed calculations. You can also export the graph.

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Architecture:** Multi-screen navigation with separate screens for setup, input, simulation, and visualization
- **Charts/Graphing:** (Add the packages you used here, e.g. `charts_flutter`, `fl_chart`, `graphview`, etc.)

## Getting Started

### Prerequisites

- Flutter SDK installed
- A working device/emulator

### Installation

```bash
git clone https://github.com/Ha0ko/markov-chain-flutter-solver.git
cd markov-chain-flutter-solver
flutter pub get
flutter run
