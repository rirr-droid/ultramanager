import SwiftUI

struct RaceCalendarView: View {
    @Binding var runner: Runner
    @State private var selectedRace: Race?
    @State private var showingRaceExecution = false

    var availableRaces: [Race] {
        Race.available(for: runner)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("RACE CALENDAR")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(availableRaces, id: \.id) { race in
                    RaceCard(race: race) {
                        selectedRace = race
                        showingRaceExecution = true
                    }
                }

                if availableRaces.isEmpty {
                    Text("No races available yet.\nIncrease your prestige and endurance to unlock more races.")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                }
            }
            .padding()
        }
        .fullScreenCover(item: $selectedRace) { race in
            RaceExecutionView(race: race, runner: runner) { result in
                // Handle race completion
                processRaceResult(result)
                selectedRace = nil
            }
        }
    }

    private func processRaceResult(_ result: RaceResult) {
        runner.xp += result.xpEarned
        runner.prestige += result.prestigeEarned
        runner.money += result.prizeMoney
        runner.careerEarnings += result.prizeMoney

        // Post-race recovery
        if let derived = runner.derived {
            derived.fatigue += 40
            derived.muscleDamage += 30
        }

        // Check for post-race blues
        if !result.finished || (result.placement ?? 999) > 50 {
            let roll = Double.random(in: 0...1)
            let mental = runner.attributes?.mental ?? 5.0
            let bluesChance = !result.finished ? 0.4 : 0.25
            let mentalProtection = mental / 20.0

            if roll < (bluesChance - mentalProtection) {
                runner.postRaceBlues = true
                runner.postRaceBluesWeeksLeft = Int.random(in: 2...4)
                runner.postRaceBluesSeverity = result.finished ? "mild" : "moderate"
            }
        }
    }
}

struct RaceCard: View {
    let race: Race
    let onEnter: () -> Void

    var body: some View {
        Button(action: onEnter) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(race.name)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        Text(race.distance)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.orange)
                    }

                    Spacer()

                    difficultyBadge
                }

                // Stats
                HStack(spacing: 16) {
                    raceStatItem(icon: "arrow.up.right", label: "\(race.elevationGain)ft", color: .red)
                    raceStatItem(icon: "clock", label: "\(Int(race.cutoffHours ?? 24))h", color: .blue)
                    raceStatItem(icon: "flag.checkered", label: "\(race.maxEntrants)", color: .green)
                }

                // Requirements
                VStack(alignment: .leading, spacing: 4) {
                    Text("Requirements:")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)

                    HStack(spacing: 12) {
                        requirementBadge(label: "END \(String(format: "%.1f", race.minEndurance))", met: (runner.attributes?.endurance ?? 0) >= race.minEndurance)
                        requirementBadge(label: "PRE \(Int(race.minPrestige))", met: runner.prestige >= race.minPrestige)
                        requirementBadge(label: "$\(Int(race.entryFee))", met: runner.money >= race.entryFee)
                    }
                }

                // Rewards
                HStack(spacing: 8) {
                    Text("Rewards:")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)

                    Text("+\(Int(race.prestigeReward)) prestige")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.purple)

                    if race.prizeMoney[0] > 0 {
                        Text("$\(Int(race.prizeMoney[0])) (1st)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.green)
                    }

                    if race.goldenTicket {
                        Text("🎫 Golden Ticket")
                            .font(.system(size: 11, design: .monospaced))
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var difficultyBadge: some View {
        let color: Color = switch race.difficulty {
        case 1...3: .green
        case 4...6: .yellow
        case 7...8: .orange
        default: .red
        }

        return Text("D\(race.difficulty)")
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .cornerRadius(4)
    }

    private func raceStatItem(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white)
        }
    }

    private func requirementBadge(label: String, met: Bool) -> some View {
        Text(label)
            .font(.system(size: 10, design: .monospaced))
            .foregroundColor(met ? .green : .red)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background((met ? Color.green : Color.red).opacity(0.2))
            .cornerRadius(4)
    }
}
