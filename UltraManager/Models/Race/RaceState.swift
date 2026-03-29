import Foundation

class RaceState: ObservableObject {
    @Published var race: Race
    @Published var segments: [RaceSegment]
    @Published var currentSegmentIndex: Int = 0
    @Published var energy: Double = 100.0
    @Published var hydration: Double = 100.0
    @Published var morale: Double = 100.0
    @Published var muscleDamage: Double = 0.0
    @Published var elapsedTimeMinutes: Double = 0.0
    @Published var currentPlacement: Int = 1
    @Published var totalEntrants: Int
    @Published var raceFinished: Bool = false
    @Published var dnf: Bool = false
    @Published var dnfReason: String = ""
    @Published var raceNarrative: [String] = []

    var runner: Runner
    var raceNutritionPlan: RaceNutritionPlan?

    init(race: Race, runner: Runner) {
        self.race = race
        self.runner = runner
        self.totalEntrants = race.maxEntrants
        self.segments = RaceSegmentGenerator.generateSegments(for: race, runner: runner)

        // Apply archetype bonuses to starting state
        if runner.archetypeKey == ArchetypeKey.fatAdaptedOutlier.rawValue {
            self.energy = 120.0 // Start with bonus energy
        }
    }

    var currentSegment: RaceSegment? {
        guard currentSegmentIndex < segments.count else { return nil }
        return segments[currentSegmentIndex]
    }

    var progressPercentage: Double {
        Double(currentSegmentIndex) / Double(segments.count)
    }

    var isInFinalQuarter: Bool {
        progressPercentage >= 0.75
    }

    func executeChoice(_ choice: SegmentChoice, segment: RaceSegment) {
        // Roll for outcome based on probabilities and runner stats
        let outcomes = choice.outcomes
        let evaluatedProbabilities = outcomes.map { outcome in
            (outcome, outcome.evaluateProbability(runner: runner))
        }

        // Normalize probabilities
        let totalProb = evaluatedProbabilities.reduce(0.0) { $0 + $1.1 }
        let normalized = evaluatedProbabilities.map { ($0.0, $0.1 / totalProb) }

        // Roll dice
        let roll = Double.random(in: 0...1)
        var cumulative = 0.0
        var selectedOutcome: SegmentOutcome?

        for (outcome, prob) in normalized {
            cumulative += prob
            if roll <= cumulative {
                selectedOutcome = outcome
                break
            }
        }

        guard let outcome = selectedOutcome else {
            selectedOutcome = outcomes.first
        }

        applyOutcome(outcome!, choice: choice, segment: segment)
    }

    private func applyOutcome(_ outcome: SegmentOutcome, choice: SegmentChoice, segment: RaceSegment) {
        // Apply effects
        energy += outcome.effects.energy
        hydration += outcome.effects.hydration
        morale += outcome.effects.morale
        muscleDamage += outcome.effects.muscleDamage
        elapsedTimeMinutes += segment.baseTimeMinutes * choice.timeModifier + outcome.effects.timeBonusMinutes

        // Archetype passives
        if runner.archetypeKey == ArchetypeKey.negativeSplitMachine.rawValue && isInFinalQuarter {
            energy -= outcome.effects.energy * 0.2 // 20% less energy drain in final quarter
        }

        if runner.archetypeKey == ArchetypeKey.summitFever.rawValue && segment.segmentType == .majorClimb {
            morale += 5 // No morale penalty on big climbs
        }

        // Second Wind check (Comeback Kid)
        if runner.archetypeKey == ArchetypeKey.comebackKid.rawValue && morale < 15 && !runner.secondWindUsed {
            morale = 100.0
            runner.secondWindUsed = true
            raceNarrative.append("🔥 SECOND WIND ACTIVATED — You dig deep and find the fire again!")
        }

        // Apply race nutrition
        if let nutrition = raceNutritionPlan {
            let energyGain = nutrition.effectiveEnergyRate / 6.0 // Per segment (~1 hour)
            energy += energyGain

            // GI distress check
            if Double.random(in: 0...1) < nutrition.giDistressRisk {
                energy -= 15
                morale -= 10
                raceNarrative.append("💢 Your stomach rebels. Nutrition is not sitting well.")
            }
        }

        // Clamp values
        energy = min(max(energy, 0), 120)
        hydration = min(max(hydration, 0), 100)
        morale = min(max(morale, 0), 100)
        muscleDamage = min(max(muscleDamage, 0), 100)

        // Add narrative
        raceNarrative.append(outcome.narrative)

        // Check for DNF conditions
        checkDNF(segment: segment, injuryChance: outcome.effects.injuryChance)
    }

    private func checkDNF(segment: RaceSegment, injuryChance: Double) {
        // Energy depletion
        if energy <= 0 {
            dnf = true
            dnfReason = "Bonked — Complete energy depletion. Your body shut down."
            return
        }

        // Hydration crisis
        if hydration <= 0 {
            dnf = true
            dnfReason = "Severe dehydration. Medical pulled you from the race."
            return
        }

        // Morale collapse
        if morale <= 0 {
            dnf = true
            dnfReason = "Voluntary quit. The dark place won this time."
            return
        }

        // Cutoff missed
        if segment.cutoffCheckpoint, let cutoff = segment.cutoffTimeHours {
            if elapsedTimeMinutes / 60.0 > cutoff {
                dnf = true
                dnfReason = "Missed cutoff at mile \(Int(segment.mileEnd)). Time: \(String(format: "%.1f", elapsedTimeMinutes / 60.0))h / \(cutoff)h"
                return
            }
        }

        // Injury roll
        if Double.random(in: 0...1) < injuryChance {
            dnf = true
            dnfReason = "Race-ending injury. Body couldn't handle it."
            return
        }
    }

    func advanceSegment() {
        currentSegmentIndex += 1

        if currentSegmentIndex >= segments.count {
            finishRace()
        }
    }

    private func finishRace() {
        raceFinished = true

        // Calculate final placement (simplified)
        let performanceScore = (energy + morale - muscleDamage) / elapsedTimeMinutes * 100
        currentPlacement = max(1, Int(Double(totalEntrants) * (1.0 - (performanceScore / 10.0))))
        currentPlacement = min(currentPlacement, totalEntrants)
    }

    func getRaceResult() -> RaceResult {
        let finished = !dnf && raceFinished

        return RaceResult(
            raceID: race.id,
            raceName: race.name,
            season: runner.season,
            week: runner.week,
            finished: finished,
            placement: finished ? currentPlacement : nil,
            totalEntrants: totalEntrants,
            finishTimeMinutes: finished ? elapsedTimeMinutes : nil,
            dnfReason: dnf ? dnfReason : nil,
            segmentsCompleted: currentSegmentIndex,
            totalSegments: segments.count,
            prestigeEarned: finished ? race.prestigeReward : (race.prestigeReward * 0.1),
            xpEarned: finished ? Double(race.difficulty * 50) : Double(race.difficulty * 10),
            prizeMoney: finished && currentPlacement <= race.prizeMoney.count ? race.prizeMoney[currentPlacement - 1] : 0,
            performanceScore: (energy + morale - muscleDamage) / elapsedTimeMinutes * 100
        )
    }
}

struct RaceNutritionPlan: Codable {
    let carbsPerHour: Double
    let hydrationMLPerHour: Double
    let electrolyteStrategy: ElectrolyteStrategy
    let caffeineTimings: [Double] // miles at which to take caffeine
    let realFoodRatio: Double // 0-1
    let productIDs: [String]

    var effectiveEnergyRate: Double {
        carbsPerHour * 4.0 // 4 calories per gram of carb
    }

    var giDistressRisk: Double {
        // Risk increases if carbs exceed what gut can handle
        // This will be calculated against runner.derived.gutTrainingLevel
        let baseRisk = 0.05
        if carbsPerHour > 90 {
            return baseRisk * 2.0
        } else if carbsPerHour > 60 {
            return baseRisk * 1.5
        }
        return baseRisk
    }
}

enum ElectrolyteStrategy: String, Codable {
    case low
    case moderate
    case aggressive
}

struct RaceResult: Codable {
    let raceID: String
    let raceName: String
    let season: Int
    let week: Int
    let finished: Bool
    let placement: Int?
    let totalEntrants: Int
    let finishTimeMinutes: Double?
    let dnfReason: String?
    let segmentsCompleted: Int
    let totalSegments: Int
    let prestigeEarned: Double
    let xpEarned: Double
    let prizeMoney: Double
    let performanceScore: Double
}
