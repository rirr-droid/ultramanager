import Foundation

class GameEngine: ObservableObject {
    @Published var runner: Runner
    @Published var weekLog: [WeekLogEntry] = []
    @Published var currentWeekTraining: [String] = []

    init(runner: Runner) {
        self.runner = runner
    }

    func advanceWeek() {
        var events: [String] = []

        // 1. Apply training effects
        applyTrainingEffects(training: currentWeekTraining, events: &events)

        // 2. Apply nutrition effects
        applyNutritionEffects(events: &events)

        // 3. Update fatigue, fitness, form
        updateFatigueAndForm(events: &events)

        // 4. Check for injuries
        checkForInjuries(events: &events)

        // 5. Recovery from injuries
        processInjuryRecovery(events: &events)

        // 6. Process post-race blues
        processPostRaceBlues(events: &events)

        // 7. Attribute decay for untrained stats
        applyAttributeDecay(events: &events)

        // 8. Update sponsorships
        updateSponsorships(events: &events)

        // 9. Advance week/season
        runner.week += 1
        if runner.week > 52 {
            runner.week = 1
            runner.season += 1
            runner.age += 1
            events.append("🎂 New season! You're now \(runner.age) years old.")
        }

        // 10. Log the week
        logWeek(events: events)

        // 11. Clear training selections
        currentWeekTraining = []
    }

    private func applyTrainingEffects(training: [String], events: inout [String]) {
        guard let attributes = runner.attributes, let derived = runner.derived else { return }

        var totalFatigueCost: Double = 0
        var totalFitnessGain: Double = 0
        var totalInjuryRisk: Double = 0
        var statGrowth: [String: Double] = [:]

        for trainingID in training {
            guard let trainingType = TrainingType.get(trainingID) else { continue }

            // Apply primary effects
            for (stat, growth) in trainingType.primaryEffects {
                let bonus = runner.archetype.passive == .adaptable ? 1.1 : 1.0
                let finalGrowth = growth * bonus

                attributes.applyGrowth(
                    stat: stat,
                    amount: finalGrowth,
                    age: runner.age,
                    form: derived.form
                )

                statGrowth[stat, default: 0] += finalGrowth
            }

            // Apply secondary effects
            for (key, value) in trainingType.secondaryEffects {
                switch key {
                case "fatigue":
                    derived.fatigue += value
                case "fitness":
                    derived.fitness += value
                case "muscleDamage":
                    derived.muscleDamage += value
                case "gutTrainingLevel":
                    derived.gutTrainingLevel += value
                case "fatAdaptation":
                    derived.fatAdaptation += value
                default:
                    break
                }
            }

            totalFatigueCost += trainingType.fatigueCost
            totalFitnessGain += trainingType.fitnessGain
            totalInjuryRisk += trainingType.injuryRiskBase

            events.append("✅ \(trainingType.label) completed")
        }

        // Apply fatigue and fitness
        derived.fatigue += totalFatigueCost
        derived.fitness += totalFitnessGain

        // Clamp values
        derived.fatigue = min(max(derived.fatigue, 0), 100)
        derived.fitness = min(max(derived.fitness, 0), 100)
        derived.gutTrainingLevel = min(max(derived.gutTrainingLevel, 0), 100)
        derived.fatAdaptation = min(max(derived.fatAdaptation, 0), 100)

        // Report stat gains
        for (stat, growth) in statGrowth.sorted(by: { $0.value > $1.value }) {
            if growth > 0.05 {
                events.append("📈 \(stat.capitalized): +\(String(format: "%.2f", growth))")
            }
        }

        runner.attributes = attributes
        runner.derived = derived
    }

    private func applyNutritionEffects(events: inout [String]) {
        guard let plan = DailyNutritionPlan.get(runner.dailyNutritionPlanID) else { return }
        guard let attributes = runner.attributes, let derived = runner.derived else { return }

        for (stat, effect) in plan.weeklyEffects {
            if let _ = Double(stat) {
                // It's a derived stat
                continue
            } else {
                // It's an attribute
                let current = attributes.getValue(for: stat)
                attributes.setValue(for: stat, value: current + effect)
            }
        }

        // Update derived stats from nutrition
        derived.gutTrainingLevel += plan.gutTrainingMod
        derived.fatAdaptation += plan.fatAdaptationMod
        derived.weight += plan.weightMod

        derived.gutTrainingLevel = min(max(derived.gutTrainingLevel, 0), 100)
        derived.fatAdaptation = min(max(derived.fatAdaptation, 0), 100)

        runner.money -= plan.costPerWeek
        runner.attributes = attributes
        runner.derived = derived
    }

    private func updateFatigueAndForm(events: inout [String]) {
        guard let derived = runner.derived else { return }

        // Calculate weekly training load
        let weeklyLoad = derived.fatigue

        // Add to training load history
        derived.addWeeklyLoad(weeklyLoad)

        // Check for overtraining
        if derived.form < -15 {
            runner.overtraining = true
            events.append("⚠️ OVERTRAINING WARNING — Your form is dangerously low. Rest or risk injury!")
        } else {
            runner.overtraining = false
        }

        // Fatigue natural decay
        if derived.fatigue > 20 {
            derived.fatigue -= 5 // Natural recovery
        }

        // Muscle damage recovery
        if derived.muscleDamage > 0 {
            let recoveryRate = runner.attributes?.recovery ?? 5.0
            derived.muscleDamage -= recoveryRate
            derived.muscleDamage = max(derived.muscleDamage, 0)
        }

        runner.derived = derived
    }

    private func checkForInjuries(events: inout [String]) {
        if runner.injured { return }

        let trainingIntensity = Double(currentWeekTraining.count) / 3.0 * 1.5

        if let injury = Injury.roll(runner: runner, trainingIntensity: trainingIntensity) {
            runner.injured = true
            runner.injuryName = injury.name
            runner.injuryWeeksLeft = Int.random(in: injury.weeksOutMin...injury.weeksOutMax)

            // Apply stat hits
            if let attributes = runner.attributes {
                for (stat, hit) in injury.statHits {
                    let current = attributes.getValue(for: stat)
                    attributes.setValue(for: stat, value: current + hit)
                }
                runner.attributes = attributes
            }

            events.append("🚑 INJURED — \(injury.name). Out for \(runner.injuryWeeksLeft) weeks.")
        }
    }

    private func processInjuryRecovery(events: inout [String]) {
        if runner.injured {
            runner.injuryWeeksLeft -= 1
            if runner.injuryWeeksLeft <= 0 {
                runner.injured = false
                runner.injuryName = ""
                events.append("✅ You're healthy again! Time to rebuild.")
            } else {
                events.append("🩹 Recovering from \(runner.injuryName). \(runner.injuryWeeksLeft) weeks remaining.")
            }
        }
    }

    private func processPostRaceBlues(events: inout [String]) {
        if runner.postRaceBlues {
            runner.postRaceBluesWeeksLeft -= 1
            if runner.postRaceBluesWeeksLeft <= 0 {
                runner.postRaceBlues = false
                runner.postRaceBluesSeverity = ""
                events.append("🌤️ The fog is lifting. You're feeling motivated again.")
            } else {
                events.append("😔 Still dealing with post-race blues. \(runner.postRaceBluesWeeksLeft) weeks remaining.")
            }
        }
    }

    private func applyAttributeDecay(events: inout [String]) {
        guard let attributes = runner.attributes else { return }

        // Attributes not trained this week decay slightly
        let trainedStats = currentWeekTraining.compactMap { trainingID -> [String]? in
            guard let training = TrainingType.get(trainingID) else { return nil }
            return Array(training.primaryEffects.keys)
        }.flatMap { $0 }

        let allStats = ["speed", "endurance", "climbing", "descending", "durability", "mental", "technical", "recovery"]

        for stat in allStats {
            if !trainedStats.contains(stat) && stat != "mental" {
                let decayAmount: Double = stat == "speed" ? 0.03 : stat == "technical" ? 0.01 : 0.02
                attributes.applyDecay(stat: stat, amount: decayAmount)
            }
        }

        runner.attributes = attributes
    }

    private func updateSponsorships(events: inout [String]) {
        // Generate new sponsorship offers every 8 weeks
        if runner.week % 8 == 0 {
            let offers = SponsorshipOffer.generate(for: runner)
            if !offers.isEmpty {
                events.append("📧 \(offers.count) new sponsorship offer(s) available!")
            }
        }

        // Process active sponsorships
        // (Content obligations, relationship decay, etc.)
    }

    private func logWeek(events: [String]) {
        let entry = WeekLogEntry(
            week: runner.week,
            season: runner.season,
            trainingCompleted: currentWeekTraining,
            nutritionPlanID: runner.dailyNutritionPlanID,
            fatigueDelta: runner.derived?.fatigue ?? 0,
            fitnessDelta: runner.derived?.fitness ?? 0,
            events: events,
            injury: runner.injured ? runner.injuryName : nil
        )
        weekLog.append(entry)
    }
}

struct WeekLogEntry: Identifiable, Codable {
    let id = UUID()
    let week: Int
    let season: Int
    let trainingCompleted: [String]
    let nutritionPlanID: String
    let fatigueDelta: Double
    let fitnessDelta: Double
    let events: [String]
    let injury: String?
}
