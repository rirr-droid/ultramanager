import SwiftUI

struct TrainingView: View {
    @Binding var runner: Runner
    @ObservedObject var gameEngine: GameEngine
    @State private var showingAdvanceConfirmation = false

    private let maxTrainingSlots = 3

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Training Block Selector
                trainingBlockCard

                // Selected Training
                selectedTrainingCard

                // Available Training Options
                Text("AVAILABLE TRAINING")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(TrainingType.all, id: \.id) { training in
                    TrainingCard(
                        training: training,
                        isSelected: gameEngine.currentWeekTraining.contains(training.id),
                        canSelect: gameEngine.currentWeekTraining.count < maxTrainingSlots,
                        currentBlock: TrainingBlock(rawValue: runner.currentTrainingBlock) ?? .base
                    ) {
                        toggleTraining(training.id)
                    }
                }

                // Advance Week Button
                Button {
                    if !gameEngine.currentWeekTraining.isEmpty {
                        showingAdvanceConfirmation = true
                    }
                } label: {
                    Text("ADVANCE WEEK")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(gameEngine.currentWeekTraining.isEmpty ? Color.gray : Color.orange)
                        .cornerRadius(8)
                }
                .disabled(gameEngine.currentWeekTraining.isEmpty)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .padding()
        }
        .alert("Advance Week?", isPresented: $showingAdvanceConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                advanceWeek()
            }
        } message: {
            Text("Training: \(gameEngine.currentWeekTraining.count) sessions\nThis will process your training, check for injuries, and advance to next week.")
        }
    }

    private var trainingBlockCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TRAINING BLOCK")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.gray)

            Picker("Block", selection: $runner.currentTrainingBlock) {
                ForEach(TrainingBlock.allCases, id: \.self) { block in
                    Text(block.rawValue.capitalized).tag(block.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Text(blockDescription(TrainingBlock(rawValue: runner.currentTrainingBlock) ?? .base))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    private var selectedTrainingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("THIS WEEK'S TRAINING")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(gameEngine.currentWeekTraining.count)/\(maxTrainingSlots)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }

            if gameEngine.currentWeekTraining.isEmpty {
                Text("No training selected")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(gameEngine.currentWeekTraining, id: \.self) { trainingID in
                    if let training = TrainingType.get(trainingID) {
                        HStack {
                            Text(training.icon)
                            Text(training.label)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: { toggleTraining(trainingID) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    private func toggleTraining(_ id: String) {
        if let index = gameEngine.currentWeekTraining.firstIndex(of: id) {
            gameEngine.currentWeekTraining.remove(at: index)
        } else if gameEngine.currentWeekTraining.count < maxTrainingSlots {
            gameEngine.currentWeekTraining.append(id)
        }
    }

    private func advanceWeek() {
        gameEngine.advanceWeek()
        runner = gameEngine.runner
    }

    private func blockDescription(_ block: TrainingBlock) -> String {
        switch block {
        case .base: return "Build aerobic base. Focus on volume and endurance."
        case .build: return "Add intensity. Prepare for upcoming races."
        case .peak: return "Race-specific training. Final preparations."
        case .taper: return "Reduce volume, maintain intensity. Rest before race."
        case .recovery: return "Active recovery. Let the body adapt."
        case .offSeason: return "Maintain fitness. Strength work. Mental break."
        }
    }
}

struct TrainingCard: View {
    let training: TrainingType
    let isSelected: Bool
    let canSelect: Bool
    let currentBlock: TrainingBlock

    let onToggle: () -> Void

    private var isRecommended: Bool {
        training.bestInBlocks.contains(currentBlock)
    }

    var body: some View {
        Button(action: {
            if isSelected || canSelect {
                onToggle()
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(training.icon)
                        .font(.system(size: 24))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(training.label)
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        HStack(spacing: 8) {
                            Label {
                                Text("\(Int(training.fatigueCost))")
                            } icon: {
                                Image(systemName: "bolt.fill")
                            }
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(training.fatigueCost > 0 ? .red : .green)

                            Label {
                                Text("+\(Int(training.fitnessGain))")
                            } icon: {
                                Image(systemName: "figure.run")
                            }
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.green)

                            if training.cost ?? 0 > 0 {
                                Label {
                                    Text("$\(Int(training.cost!))")
                                } icon: {
                                    Image(systemName: "dollarsign.circle")
                                }
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.yellow)
                            }
                        }
                    }

                    Spacer()

                    if isRecommended {
                        Text("RECOMMENDED")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 22))
                    }
                }

                Text(training.description)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)

                // Primary effects
                HStack(spacing: 8) {
                    ForEach(Array(training.primaryEffects.keys.sorted()), id: \.self) { key in
                        if let value = training.primaryEffects[key] {
                            statBadge(key, value: value)
                        }
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
            .opacity((!isSelected && !canSelect) ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(!isSelected && !canSelect)
    }

    private func statBadge(_ key: String, value: Double) -> some View {
        HStack(spacing: 2) {
            Text(key.prefix(3).uppercased())
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.gray)
            Text("+\(String(format: "%.2f", value))")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.green)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.green.opacity(0.1))
        .cornerRadius(4)
    }
}
