import SwiftUI

struct RaceExecutionView: View {
    let race: Race
    let runner: Runner
    let onComplete: (RaceResult) -> Void

    @StateObject private var raceState: RaceState
    @State private var showingResult = false
    @Environment(\.dismiss) private var dismiss

    init(race: Race, runner: Runner, onComplete: @escaping (RaceResult) -> Void) {
        self.race = race
        self.runner = runner
        self.onComplete = onComplete
        _raceState = StateObject(wrappedValue: RaceState(race: race, runner: runner))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if raceState.raceFinished || raceState.dnf {
                RaceResultView(raceState: raceState) {
                    onComplete(raceState.getRaceResult())
                    dismiss()
                }
            } else if let segment = raceState.currentSegment {
                VStack(spacing: 0) {
                    // Race HUD
                    raceHUD

                    // Segment Content
                    ScrollView {
                        VStack(spacing: 20) {
                            segmentHeader(segment)
                            narrativeSection(segment)
                            choicesSection(segment)
                        }
                        .padding()
                    }
                }
            }
        }
    }

    private var raceHUD: some View {
        VStack(spacing: 12) {
            // Race name and progress
            HStack {
                Text(race.name)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                Text("Mile \(Int(raceState.currentSegment?.mileEnd ?? 0))/\(Int(race.distanceMiles))")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.gray)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))

                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: geometry.size.width * raceState.progressPercentage)
                }
            }
            .frame(height: 4)

            // Stats
            HStack(spacing: 8) {
                hudStat("⚡", value: raceState.energy, max: 100, color: .yellow)
                hudStat("💧", value: raceState.hydration, max: 100, color: .blue)
                hudStat("💪", value: raceState.morale, max: 100, color: .green)
                hudStat("🔥", value: raceState.muscleDamage, max: 100, color: .red)
            }

            // Time and placement
            HStack {
                Text("⏱️ \(formatTime(raceState.elapsedTimeMinutes))")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                Text("#\(raceState.currentPlacement)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color.black.opacity(0.95))
    }

    private func hudStat(_ icon: String, value: Double, max: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 16))

            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 50)

                Rectangle()
                    .fill(color)
                    .frame(width: 40, height: 50 * (value / max))
            }
            .cornerRadius(4)

            Text("\(Int(value))")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
    }

    private func segmentHeader(_ segment: RaceSegment) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MILE \(Int(segment.mileStart)) - \(Int(segment.mileEnd))")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)

            HStack(spacing: 12) {
                segmentBadge(icon: "arrow.up.right", label: "\(segment.elevationChange)ft", color: segment.elevationChange > 0 ? .red : .green)
                segmentBadge(icon: "thermometer", label: "\(segment.temperature)°F", color: .orange)
                segmentBadge(icon: "moon.stars", label: segment.timeOfDay.rawValue, color: .purple)
            }
        }
    }

    private func segmentBadge(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(label)
                .font(.system(size: 10, design: .monospaced))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .cornerRadius(4)
    }

    private func narrativeSection(_ segment: RaceSegment) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(segment.description)
                .font(.system(size: 15, design: .monospaced))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            // Recent narrative events
            if !raceState.raceNarrative.isEmpty {
                Divider()
                    .background(Color.gray.opacity(0.3))

                ForEach(raceState.raceNarrative.suffix(3).reversed(), id: \.self) { event in
                    Text(event)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.gray)
                        .italic()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    private func choicesSection(_ segment: RaceSegment) -> some View {
        VStack(spacing: 12) {
            Text("WHAT DO YOU DO?")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(segment.choices, id: \.id) { choice in
                ChoiceCard(choice: choice, runner: runner) {
                    executeChoice(choice, segment: segment)
                }
            }
        }
    }

    private func executeChoice(_ choice: SegmentChoice, segment: RaceSegment) {
        withAnimation {
            raceState.executeChoice(choice, segment: segment)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if !raceState.dnf && !raceState.raceFinished {
                withAnimation {
                    raceState.advanceSegment()
                }
            }
        }
    }

    private func formatTime(_ minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60
        return String(format: "%d:%02d", hours, mins)
    }
}

struct ChoiceCard: View {
    let choice: SegmentChoice
    let runner: Runner
    let onSelect: () -> Void

    private var isOptimal: Bool {
        guard let attributes = runner.attributes else { return false }
        let statValue = attributes.getValue(for: choice.preferredStat)
        return statValue >= choice.preferredStatMin
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(choice.icon)
                        .font(.system(size: 28))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(choice.label)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        Text("Tests: \(choice.preferredStat) (\(String(format: "%.1f", choice.preferredStatMin))+)")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(isOptimal ? .green : .orange)
                    }

                    Spacer()

                    if isOptimal {
                        Image(systemName: "star.fill")
                            .foregroundColor(.green)
                    }
                }

                Text(choice.description)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)

                // Resource impacts
                HStack(spacing: 8) {
                    if choice.energyModifier != 1.0 {
                        impactBadge(icon: "bolt.fill", value: choice.energyModifier, color: .yellow)
                    }
                    if choice.timeModifier != 1.0 {
                        impactBadge(icon: "clock.fill", value: choice.timeModifier, color: .blue)
                    }
                    if choice.muscleDamageModifier != 1.0 {
                        impactBadge(icon: "flame.fill", value: choice.muscleDamageModifier, color: .red)
                    }
                }
            }
            .padding()
            .background(isOptimal ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isOptimal ? Color.green : Color.gray.opacity(0.3), lineWidth: isOptimal ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func impactBadge(icon: String, value: Double, color: Color) -> some View {
        let displayValue = value > 1.0 ? "+\(Int((value - 1.0) * 100))%" : "\(Int((value - 1.0) * 100))%"

        return HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text(displayValue)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
        }
        .foregroundColor(value > 1.0 ? .red : .green)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.2))
        .cornerRadius(4)
    }
}

struct RaceResultView: View {
    @ObservedObject var raceState: RaceState
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Result Header
            if raceState.dnf {
                Text("DNF")
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
            } else {
                Text("FINISHED")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
            }

            // Details
            VStack(spacing: 16) {
                if !raceState.dnf {
                    resultRow("Placement", value: "#\(raceState.currentPlacement) / \(raceState.totalEntrants)")
                    resultRow("Time", value: formatTime(raceState.elapsedTimeMinutes))
                } else {
                    Text(raceState.dnfReason)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }

                let result = raceState.getRaceResult()
                resultRow("Prestige", value: "+\(Int(result.prestigeEarned))", color: .purple)
                resultRow("XP", value: "+\(Int(result.xpEarned))", color: .orange)
                if result.prizeMoney > 0 {
                    resultRow("Prize Money", value: "$\(Int(result.prizeMoney))", color: .green)
                }
            }

            Spacer()

            Button(action: onDismiss) {
                Text("CONTINUE")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    private func resultRow(_ label: String, value: String, color: Color = .white) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, design: .monospaced))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
        .padding(.horizontal, 40)
    }

    private func formatTime(_ minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60
        return String(format: "%d:%02d", hours, mins)
    }
}
