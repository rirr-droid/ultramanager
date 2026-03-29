import Foundation

struct TrainingType: Identifiable, Codable {
    let id: String
    let label: String
    let icon: String
    let category: TrainingCategory
    let description: String
    let primaryEffects: [String: Double]
    let secondaryEffects: [String: Double]
    let fatigueCost: Double
    let fitnessGain: Double
    let injuryRiskBase: Double
    let bestInBlocks: [TrainingBlock]
    let variants: [TrainingVariant]?
    let cost: Double?
    let locationRequired: Bool?
    let consecutiveBonus: Bool?
    let maxConsecutiveWeeks: Int?

    static let all: [TrainingType] = [
        TrainingType(
            id: "long_run",
            label: "Long Run",
            icon: "🏃",
            category: .endurance,
            description: "The bread and butter. 2-4 hours of steady running.",
            primaryEffects: ["endurance": 0.18, "mental": 0.06],
            secondaryEffects: ["fatAdaptation": 2.0, "gutTrainingLevel": 1.0],
            fatigueCost: 18,
            fitnessGain: 8,
            injuryRiskBase: 0.05,
            bestInBlocks: [.base, .build],
            variants: nil,
            cost: nil,
            locationRequired: nil,
            consecutiveBonus: nil,
            maxConsecutiveWeeks: nil
        ),
        TrainingType(
            id: "speed_work",
            label: "Speed / Intervals",
            icon: "💨",
            category: .intensity,
            description: "Tempo runs, VO2max intervals, threshold work. Per KoopCast research on interval types for ultrarunners.",
            primaryEffects: ["speed": 0.22, "endurance": 0.04],
            secondaryEffects: ["fitness": 10],
            fatigueCost: 22,
            fitnessGain: 12,
            injuryRiskBase: 0.10,
            bestInBlocks: [.build, .peak],
            variants: [
                TrainingVariant(name: "Tempo Run", speedEmphasis: 0.15, enduranceEmphasis: 0.10, durabilityEmphasis: 0, injuryRiskMod: 1.0),
                TrainingVariant(name: "VO2max Intervals", speedEmphasis: 0.25, enduranceEmphasis: 0.02, durabilityEmphasis: 0, injuryRiskMod: 1.3),
                TrainingVariant(name: "Progression Run", speedEmphasis: 0.12, enduranceEmphasis: 0.08, durabilityEmphasis: 0.06, injuryRiskMod: 1.0)
            ],
            cost: nil,
            locationRequired: nil,
            consecutiveBonus: nil,
            maxConsecutiveWeeks: nil
        ),
        TrainingType(
            id: "vertical_training",
            label: "Vert Training",
            icon: "🧗",
            category: .climbing,
            description: "Hill repeats, stairclimbing, mountain runs.",
            primaryEffects: ["climbing": 0.20, "endurance": 0.06, "descending": 0.08],
            secondaryEffects: ["muscleDamage": 8],
            fatigueCost: 22,
            fitnessGain: 9,
            injuryRiskBase: 0.06,
            bestInBlocks: [.base, .build],
            variants: nil,
            cost: nil,
            locationRequired: nil,
            consecutiveBonus: nil,
            maxConsecutiveWeeks: nil
        ),
        TrainingType(
            id: "technical_trail",
            label: "Technical Trail",
            icon: "🌲",
            category: .skill,
            description: "Rocky singletrack, root networks, scrambles. Train where the race demands it.",
            primaryEffects: ["technical": 0.20, "descending": 0.10, "durability": 0.04],
            secondaryEffects: [:],
            fatigueCost: 16,
            fitnessGain: 6,
            injuryRiskBase: 0.08,
            bestInBlocks: [.base, .build],
            variants: nil,
            cost: nil,
            locationRequired: nil,
            consecutiveBonus: nil,
            maxConsecutiveWeeks: nil
        ),
        TrainingType(
            id: "strength",
            label: "Strength & Gym",
            icon: "🏋️",
            category: .strength,
            description: "Per KoopCast research: strength combats muscular fatigue, improves durability, especially for downhill.",
            primaryEffects: ["durability": 0.18, "climbing": 0.05, "descending": 0.08],
            secondaryEffects: ["weight": 0.1, "injuryRiskReduction": 0.02],
            fatigueCost: 10,
            fitnessGain: 3,
            injuryRiskBase: 0.02,
            bestInBlocks: [.base, .offSeason],
            variants: nil,
            cost: nil,
            locationRequired: nil,
            consecutiveBonus: nil,
            maxConsecutiveWeeks: nil
        ),
        TrainingType(
            id: "easy_recovery",
            label: "Easy / Recovery Run",
            icon: "🚶",
            category: .recovery,
            description: "Zone 1-2 running. Active recovery, blood flow, mental health.",
            primaryEffects: ["recovery": 0.08, "endurance": 0.03],
            secondaryEffects: ["fatigue": -12, "mental": 0.02],
            fatigueCost: -8,
            fitnessGain: 2,
            injuryRiskBase: 0.01,
            bestInBlocks: [.taper, .recovery],
            variants: nil,
            cost: nil,
            locationRequired: nil,
            consecutiveBonus: nil,
            maxConsecutiveWeeks: nil
        ),
        TrainingType(
            id: "rest",
            label: "Full Rest",
            icon: "🛌",
            category: .recovery,
            description: "Complete rest. Sleep, recover, let adaptations happen.",
            primaryEffects: ["recovery": 0.04],
            secondaryEffects: ["fatigue": -20, "muscleDamage": -15, "form": 3],
            fatigueCost: -20,
            fitnessGain: -1,
            injuryRiskBase: 0,
            bestInBlocks: [.taper, .recovery],
            variants: nil,
            cost: nil,
            locationRequired: nil,
            consecutiveBonus: nil,
            maxConsecutiveWeeks: nil
        ),
        TrainingType(
            id: "heat_acclimation",
            label: "Heat Acclimation",
            icon: "♨️",
            category: .environmental,
            description: "Sauna protocols, midday runs, overdressing. Per Julian Perriard research (KoopCast): 10-14 days needed.",
            primaryEffects: ["heatTolerance": 0.25],
            secondaryEffects: ["endurance": 0.02],
            fatigueCost: 14,
            fitnessGain: 3,
            injuryRiskBase: 0.03,
            bestInBlocks: [.peak],
            variants: nil,
            cost: nil,
            locationRequired: nil,
            consecutiveBonus: true,
            maxConsecutiveWeeks: 3
        ),
        TrainingType(
            id: "altitude_training",
            label: "Altitude Camp",
            icon: "🏔️",
            category: .environmental,
            description: "Train high, sleep high. Boosts red blood cell production and altitude tolerance. Requires travel (costs money).",
            primaryEffects: ["altitude": 0.20, "endurance": 0.08],
            secondaryEffects: ["speed": -0.05],
            fatigueCost: 16,
            fitnessGain: 7,
            injuryRiskBase: 0.04,
            bestInBlocks: [.build],
            variants: nil,
            cost: 500,
            locationRequired: true,
            consecutiveBonus: nil,
            maxConsecutiveWeeks: nil
        ),
        TrainingType(
            id: "cross_training",
            label: "Cross Training",
            icon: "🚴",
            category: .endurance,
            description: "Cycling, swimming, ski touring. Per Everyday Ultra: biking is becoming a bigger performance tool.",
            primaryEffects: ["endurance": 0.10, "recovery": 0.04],
            secondaryEffects: ["fatigue": -5, "muscleDamage": -5],
            fatigueCost: 8,
            fitnessGain: 5,
            injuryRiskBase: 0.01,
            bestInBlocks: [.base, .recovery],
            variants: nil,
            cost: nil,
            locationRequired: nil,
            consecutiveBonus: nil,
            maxConsecutiveWeeks: nil
        ),
        TrainingType(
            id: "race_simulation",
            label: "Race Simulation",
            icon: "🎯",
            category: .racePrep,
            description: "Back-to-back long runs, overnight runs, cutoff pace practice.",
            primaryEffects: ["raceCraft": 0.15, "mental": 0.08, "endurance": 0.05, "nutrition": 0.05],
            secondaryEffects: ["gutTrainingLevel": 3.0],
            fatigueCost: 28,
            fitnessGain: 10,
            injuryRiskBase: 0.08,
            bestInBlocks: [.build],
            variants: nil,
            cost: nil,
            locationRequired: nil,
            consecutiveBonus: nil,
            maxConsecutiveWeeks: nil
        ),
        TrainingType(
            id: "mobility_yoga",
            label: "Mobility & Yoga",
            icon: "🧘",
            category: .recovery,
            description: "Per Trail Runner Nation: flexibility is an underrated performance tool.",
            primaryEffects: ["durability": 0.06, "recovery": 0.06],
            secondaryEffects: ["fatigue": -6, "mental": 0.03, "injuryRiskReduction": 0.03],
            fatigueCost: -5,
            fitnessGain: 1,
            injuryRiskBase: 0,
            bestInBlocks: [.base, .taper, .recovery],
            variants: nil,
            cost: nil,
            locationRequired: nil,
            consecutiveBonus: nil,
            maxConsecutiveWeeks: nil
        )
    ]

    static func get(_ id: String) -> TrainingType? {
        all.first { $0.id == id }
    }
}

enum TrainingCategory: String, Codable {
    case endurance
    case intensity
    case climbing
    case skill
    case strength
    case recovery
    case environmental
    case racePrep
}

enum TrainingBlock: String, Codable, CaseIterable {
    case base
    case build
    case peak
    case taper
    case recovery
    case offSeason
}

struct TrainingVariant: Codable {
    let name: String
    let speedEmphasis: Double
    let enduranceEmphasis: Double
    let durabilityEmphasis: Double
    let injuryRiskMod: Double
}
