import SwiftUI

struct MainHubView: View {
    @State var runner: Runner
    @StateObject private var gameEngine: GameEngine
    @State private var selectedTab: Tab = .dashboard

    init(runner: Runner) {
        _runner = State(initialValue: runner)
        _gameEngine = StateObject(wrappedValue: GameEngine(runner: runner))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    headerView

                    // Content
                    TabView(selection: $selectedTab) {
                        DashboardView(runner: $runner, gameEngine: gameEngine)
                            .tag(Tab.dashboard)

                        TrainingView(runner: $runner, gameEngine: gameEngine)
                            .tag(Tab.training)

                        RaceCalendarView(runner: $runner)
                            .tag(Tab.races)

                        CareerView(runner: $runner)
                            .tag(Tab.career)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // Tab Bar
                    customTabBar
                }
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(runner.name)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("Season \(runner.season) • Week \(runner.week)")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Level \(runner.level)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                    Text("$\(Int(runner.money))")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // XP Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)

                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: geometry.size.width * (runner.xp / runner.xpForNextLevel()), height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .padding(.bottom, 12)
        .background(Color.black)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            TabButton(icon: "gauge", label: "Dashboard", isSelected: selectedTab == .dashboard) {
                selectedTab = .dashboard
            }
            TabButton(icon: "figure.run", label: "Training", isSelected: selectedTab == .training) {
                selectedTab = .training
            }
            TabButton(icon: "flag", label: "Races", isSelected: selectedTab == .races) {
                selectedTab = .races
            }
            TabButton(icon: "chart.line.uptrend.xyaxis", label: "Career", isSelected: selectedTab == .career) {
                selectedTab = .career
            }
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }

    enum Tab {
        case dashboard, training, races, career
    }
}

struct TabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.system(size: 10, design: .monospaced))
            }
            .foregroundColor(isSelected ? .orange : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

struct DashboardView: View {
    @Binding var runner: Runner
    @ObservedObject var gameEngine: GameEngine

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Status Cards
                statusCards

                // Injury/Blues Warnings
                if runner.injured {
                    warningCard(icon: "cross.case.fill", title: "INJURED", message: "\(runner.injuryName) - \(runner.injuryWeeksLeft) weeks remaining", color: .red)
                }

                if runner.postRaceBlues {
                    warningCard(icon: "cloud.rain.fill", title: "POST-RACE BLUES", message: "Training motivation reduced. \(runner.postRaceBluesWeeksLeft) weeks remaining", color: .blue)
                }

                if runner.overtraining {
                    warningCard(icon: "exclamationmark.triangle.fill", title: "OVERTRAINING", message: "High injury risk. Form: \(String(format: "%.1f", runner.derived?.form ?? 0))", color: .orange)
                }

                // Recent Events
                if !gameEngine.weekLog.isEmpty {
                    recentEventsCard
                }

                Spacer()
            }
            .padding()
        }
    }

    private var statusCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(label: "Fatigue", value: runner.derived?.fatigue ?? 0, max: 100, color: .red)
                StatCard(label: "Fitness", value: runner.derived?.fitness ?? 0, max: 100, color: .green)
            }

            HStack(spacing: 12) {
                StatCard(label: "Form", value: (runner.derived?.form ?? 0) + 20, max: 40, color: .orange)
                StatCard(label: "Prestige", value: runner.prestige, max: 1000, color: .purple)
            }
        }
    }

    private func warningCard(icon: String, title: String, message: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                Text(message)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding()
        .background(color.opacity(0.2))
        .cornerRadius(8)
    }

    private var recentEventsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT EVENTS")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)

            ForEach(gameEngine.weekLog.suffix(5).reversed(), id: \.id) { log in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Season \(log.season), Week \(log.week)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)

                    ForEach(log.events, id: \.self) { event in
                        Text(event)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct StatCard: View {
    let label: String
    let value: Double
    let max: Double
    let color: Color

    var percentage: Double {
        min(value / max, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)

            Text(String(format: "%.0f", value))
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))

                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
