import SwiftUI

struct CareerView: View {
    @Binding var runner: Runner

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Runner Info
                runnerInfoCard

                // Attributes
                attributesCard

                // Career Stats
                careerStatsCard

                Spacer()
            }
            .padding()
        }
    }

    private var runnerInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RUNNER INFO")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    infoRow("Name", value: runner.name)
                    infoRow("Age", value: "\(runner.age)")
                    infoRow("Archetype", value: runner.archetype.name)
                    infoRow("Level", value: "\(runner.level)")
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    infoRow("Prestige", value: String(format: "%.0f", runner.prestige))
                    infoRow("Money", value: "$\(Int(runner.money))")
                    infoRow("Career Earnings", value: "$\(Int(runner.careerEarnings))")
                    infoRow("Followers", value: "\(runner.socialMediaFollowers)")
                }
            }

            Divider()
                .background(Color.gray.opacity(0.3))

            Text(runner.backstory)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
                .italic()

            Text(runner.archetype.passive.rawValue)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.orange)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    private var attributesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ATTRIBUTES")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)

            if let attributes = runner.attributes {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    attributeBar("Speed", value: attributes.speed, icon: "⚡")
                    attributeBar("Endurance", value: attributes.endurance, icon: "🏃")
                    attributeBar("Climbing", value: attributes.climbing, icon: "⛰️")
                    attributeBar("Descending", value: attributes.descending, icon: "⬇️")
                    attributeBar("Durability", value: attributes.durability, icon: "🛡️")
                    attributeBar("Mental", value: attributes.mental, icon: "🧠")
                    attributeBar("Technical", value: attributes.technical, icon: "🌲")
                    attributeBar("Recovery", value: attributes.recovery, icon: "💊")
                    attributeBar("Heat Tol.", value: attributes.heatTolerance, icon: "🔥")
                    attributeBar("Cold Tol.", value: attributes.coldTolerance, icon: "❄️")
                    attributeBar("Altitude", value: attributes.altitude, icon: "🏔️")
                    attributeBar("Nutrition", value: attributes.nutrition, icon: "🍎")
                    attributeBar("Race Craft", value: attributes.raceCraft, icon: "🎯")
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    private var careerStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CAREER STATS")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)

            if let derived = runner.derived {
                VStack(spacing: 8) {
                    careerStatRow("Fatigue", value: String(format: "%.0f", derived.fatigue), max: "100", color: derived.fatigue > 70 ? .red : .yellow)
                    careerStatRow("Fitness", value: String(format: "%.0f", derived.fitness), max: "100", color: .green)
                    careerStatRow("Form (TSB)", value: String(format: "%.1f", derived.form), max: "±20", color: formColor(derived.form))
                    careerStatRow("Muscle Damage", value: String(format: "%.0f", derived.muscleDamage), max: "100", color: .red)
                    careerStatRow("Gut Training", value: String(format: "%.0f", derived.gutTrainingLevel), max: "100", color: .blue)
                    careerStatRow("Fat Adaptation", value: String(format: "%.0f", derived.fatAdaptation), max: "100", color: .purple)
                    careerStatRow("Weight", value: String(format: "%.1f kg", derived.weight), max: "", color: .white)
                    careerStatRow("Body Fat", value: String(format: "%.1f%%", derived.bodyFatPct), max: "", color: .white)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
    }

    private func attributeBar(_ label: String, value: Double, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(icon)
                    .font(.system(size: 12))
                Text(label)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
            }

            HStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))

                        Rectangle()
                            .fill(attributeColor(value))
                            .frame(width: geometry.size.width * (value / 10.0))
                    }
                }
                .frame(height: 6)
                .cornerRadius(3)

                Text(String(format: "%.1f", value))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: 35, alignment: .trailing)
            }
        }
    }

    private func attributeColor(_ value: Double) -> Color {
        switch value {
        case 8...: return .green
        case 6..<8: return .orange
        case 4..<6: return .yellow
        default: return .red
        }
    }

    private func careerStatRow(_ label: String, value: String, max: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            if !max.isEmpty {
                Text("/ \(max)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
    }

    private func formColor(_ value: Double) -> Color {
        if value > 10 { return .green }
        if value > 0 { return .orange }
        if value > -10 { return .yellow }
        return .red
    }
}
