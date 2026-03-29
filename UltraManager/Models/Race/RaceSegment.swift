import Foundation

struct RaceSegment: Identifiable, Codable {
    let id: String
    let mileStart: Double
    let mileEnd: Double
    let segmentType: SegmentType
    let terrain: TerrainType
    let elevationChange: Int
    let distance: Double
    let description: String

    // Environmental
    let temperature: Int
    let wind: Int
    let precipitation: Precipitation
    let timeOfDay: TimeOfDay
    let altitude: Int

    // Base costs
    let baseEnergyCost: Double
    let baseTimeMinutes: Double

    // Choices
    let choices: [SegmentChoice]

    // Cutoff
    let cutoffCheckpoint: Bool
    let cutoffTimeHours: Double?

    var distanceMiles: Double {
        mileEnd - mileStart
    }
}

enum SegmentType: String, Codable {
    case flatRunnable
    case rollingHills
    case majorClimb
    case technicalClimb
    case steep Descent
    case technicalDescent
    case aidStation
    case night
    case riverCrossing
    case exposed
    case canyonHeat
}

enum Precipitation: String, Codable {
    case none
    case lightRain
    case heavyRain
    case snow
    case hail
}

enum TimeOfDay: String, Codable {
    case dawn
    case morning
    case midday
    case afternoon
    case dusk
    case night
    case deepNight
}

struct SegmentChoice: Identifiable, Codable {
    let id: String
    let label: String
    let description: String
    let icon: String

    // Requirements
    let preferredStat: String
    let preferredStatMin: Double

    // Outcomes
    let outcomes: [SegmentOutcome]

    // Resource modifiers
    let energyModifier: Double
    let timeModifier: Double
    let moraleModifier: Double
    let hydrationModifier: Double
    let muscleDamageModifier: Double
}

struct SegmentOutcome: Identifiable, Codable {
    let id: String
    let probabilityBase: Double
    let statModifier: String
    let statThreshold: Double
    let narrative: String
    let effects: OutcomeEffects
    let outcomeType: OutcomeType

    func evaluateProbability(runner: Runner) -> Double {
        guard let attributes = runner.attributes else { return probabilityBase }
        let statValue = attributes.getValue(for: statModifier)

        // Adjust probability based on stat vs threshold
        let statDiff = statValue - statThreshold
        let adjustment = statDiff * 0.05 // 5% per point above/below

        return min(max(probabilityBase + adjustment, 0.05), 0.95)
    }
}

struct OutcomeEffects: Codable {
    let energy: Double
    let morale: Double
    let hydration: Double
    let muscleDamage: Double
    let timeBonusMinutes: Double
    let injuryChance: Double
}

enum OutcomeType: String, Codable {
    case great
    case good
    case neutral
    case bad
    case terrible
}

// Race Segment Generator
struct RaceSegmentGenerator {
    static func generateSegments(for race: Race, runner: Runner) -> [RaceSegment] {
        var segments: [RaceSegment] = []
        let segmentCount = Int(race.distanceMiles / 8) + 4 // 8-mile avg segments
        let milesPerSegment = race.distanceMiles / Double(segmentCount)

        for i in 0..<segmentCount {
            let mileStart = Double(i) * milesPerSegment
            let mileEnd = mileStart + milesPerSegment

            // Determine segment type based on position and race characteristics
            let segmentType = determineSegmentType(
                progress: Double(i) / Double(segmentCount),
                elevationGain: race.elevationGain,
                terrain: race.terrainProfile
            )

            // Determine time of day
            let timeOfDay = determineTimeOfDay(
                mile: mileStart,
                totalMiles: race.distanceMiles,
                hasNight: race.nightSections
            )

            // Generate choices for this segment
            let choices = generateChoices(for: segmentType, timeOfDay: timeOfDay, runner: runner)

            let segment = RaceSegment(
                id: "\(race.id)_segment_\(i)",
                mileStart: mileStart,
                mileEnd: mileEnd,
                segmentType: segmentType,
                terrain: race.terrainProfile.randomElement() ?? .trail,
                elevationChange: Int.random(in: -1000...2000),
                distance: milesPerSegment,
                description: generateNarrative(for: segmentType, mile: mileStart, race: race),
                temperature: race.heatFactor * 10 + Int.random(in: -10...10),
                wind: Int.random(in: 0...20),
                precipitation: .none,
                timeOfDay: timeOfDay,
                altitude: race.altitudeAvg,
                baseEnergyCost: calculateBaseEnergy(segmentType: segmentType, distance: milesPerSegment),
                baseTimeMinutes: milesPerSegment * 15, // ~15 min/mile average
                choices: choices,
                cutoffCheckpoint: i % 4 == 3 && race.hasCutoffs,
                cutoffTimeHours: race.hasCutoffs ? (race.cutoffHours ?? 24) * (Double(i) / Double(segmentCount)) : nil
            )

            segments.append(segment)
        }

        return segments
    }

    private static func determineSegmentType(progress: Double, elevationGain: Int, terrain: [TerrainType]) -> SegmentType {
        switch progress {
        case 0..<0.2:
            return .flatRunnable
        case 0.2..<0.4:
            return elevationGain > 15000 ? .majorClimb : .rollingHills
        case 0.4..<0.6:
            return .technicalClimb
        case 0.6..<0.8:
            return .steepDescent
        default:
            return .flatRunnable
        }
    }

    private static func determineTimeOfDay(mile: Double, totalMiles: Double, hasNight: Bool) -> TimeOfDay {
        if !hasNight { return .morning }

        let hoursElapsed = mile / 6.0 // assume 10 min/mile = 6 mph
        let hour = Int(hoursElapsed) % 24

        switch hour {
        case 0..<5: return .deepNight
        case 5..<7: return .dawn
        case 7..<11: return .morning
        case 11..<14: return .midday
        case 14..<17: return .afternoon
        case 17..<19: return .dusk
        default: return .night
        }
    }

    private static func generateNarrative(for type: SegmentType, mile: Double, race: Race) -> String {
        let templates: [SegmentType: [String]] = [
            .majorClimb: [
                "The climb stretches endlessly ahead. Switchbacks carved into granite. Your quads are already protesting.",
                "3,000 feet of vertical in the next 8 miles. The trail is exposed. Sun beats down. Other runners are reduced to a crawl.",
                "The altitude is starting to show. Each step feels heavier. The summit seems to mock you from above."
            ],
            .flatRunnable: [
                "Finally, some runnable trail. Your legs remember what turnover feels like. Time to make up some ground.",
                "Fire road stretches ahead. You can see other runners ahead. The competitive instinct kicks in.",
                "Smooth singletrack through the trees. This is why you love trail running. Flow state incoming."
            ],
            .steepDescent: [
                "The descent is brutal. Every footfall sends shockwaves through tired quads. The trail is loose and technical.",
                "3,000 feet of descent. Some runners fly down this. Others death march. Your choice.",
                "Steep, rocky, unrelenting. Your poles click rhythmically. Knees are screaming."
            ],
            .aidStation: [
                "Aid station ahead. You can see the lights, hear the cowbells. Crew is waiting. Time to refuel and reset.",
                "The volunteers are angels. Food, water, encouragement. You have 5 minutes until cutoff.",
                "Your crew is here. They look worried but hopeful. 'You got this!' they shout."
            ]
        ]

        let options = templates[type] ?? ["Mile \(Int(mile)). The journey continues."]
        return options.randomElement() ?? ""
    }

    private static func generateChoices(for type: SegmentType, timeOfDay: TimeOfDay, runner: Runner) -> [SegmentChoice] {
        switch type {
        case .majorClimb:
            return [
                SegmentChoice(
                    id: "power_hike",
                    label: "Power Hike",
                    description: "Aggressive hiking pace. High energy cost but fast.",
                    icon: "⚡",
                    preferredStat: "climbing",
                    preferredStatMin: 7.0,
                    outcomes: [
                        SegmentOutcome(
                            id: "power_hike_success",
                            probabilityBase: 0.4,
                            statModifier: "climbing",
                            statThreshold: 7.0,
                            narrative: "You find a rhythm. Passing other runners. Your climbing fitness pays off.",
                            effects: OutcomeEffects(energy: -18, morale: 5, hydration: -8, muscleDamage: 10, timeBonusMinutes: -15, injuryChance: 0.02),
                            outcomeType: .great
                        ),
                        SegmentOutcome(
                            id: "power_hike_medium",
                            probabilityBase: 0.35,
                            statModifier: "climbing",
                            statThreshold: 5.0,
                            narrative: "Steady climb. You're moving well but it's costing energy.",
                            effects: OutcomeEffects(energy: -22, morale: 0, hydration: -10, muscleDamage: 12, timeBonusMinutes: 0, injuryChance: 0.03),
                            outcomeType: .good
                        ),
                        SegmentOutcome(
                            id: "power_hike_fail",
                            probabilityBase: 0.25,
                            statModifier: "climbing",
                            statThreshold: 3.0,
                            narrative: "Your legs are screaming. Every switchback feels eternal. Runners pass you.",
                            effects: OutcomeEffects(energy: -28, morale: -10, hydration: -12, muscleDamage: 18, timeBonusMinutes: 15, injuryChance: 0.05),
                            outcomeType: .bad
                        )
                    ],
                    energyModifier: 1.2,
                    timeModifier: 0.85,
                    moraleModifier: 0,
                    hydrationModifier: -1,
                    muscleDamageModifier: 1.1
                ),
                SegmentChoice(
                    id: "conservative_climb",
                    label: "Conserve Energy",
                    description: "Slow and steady. Save the legs for later.",
                    icon: "🐢",
                    preferredStat: "mental",
                    preferredStatMin: 5.0,
                    outcomes: [
                        SegmentOutcome(
                            id: "conserve_success",
                            probabilityBase: 0.5,
                            statModifier: "mental",
                            statThreshold: 6.0,
                            narrative: "Smart pacing. You eat and drink at every switchback. This is a 100-mile game.",
                            effects: OutcomeEffects(energy: -12, morale: 3, hydration: -4, muscleDamage: 6, timeBonusMinutes: 10, injuryChance: 0.01),
                            outcomeType: .good
                        )
                    ],
                    energyModifier: 0.7,
                    timeModifier: 1.15,
                    moraleModifier: -2,
                    hydrationModifier: 0,
                    muscleDamageModifier: 0.7
                )
            ]
        case .flatRunnable:
            return [
                SegmentChoice(
                    id: "push_pace",
                    label: "Push the Pace",
                    description: "Open it up. This is free speed.",
                    icon: "💨",
                    preferredStat: "speed",
                    preferredStatMin: 6.0,
                    outcomes: [
                        SegmentOutcome(
                            id: "push_success",
                            probabilityBase: 0.5,
                            statModifier: "speed",
                            statThreshold: 6.0,
                            narrative: "Legs feel fresh. You're flying. Passing runner after runner.",
                            effects: OutcomeEffects(energy: -12, morale: 8, hydration: -6, muscleDamage: 5, timeBonusMinutes: -10, injuryChance: 0.02),
                            outcomeType: .great
                        )
                    ],
                    energyModifier: 1.1,
                    timeModifier: 0.7,
                    moraleModifier: 2,
                    hydrationModifier: -1,
                    muscleDamageModifier: 0.9
                ),
                SegmentChoice(
                    id: "steady_run",
                    label: "Steady Effort",
                    description: "Maintain your pace. Don't blow up.",
                    icon: "🏃",
                    preferredStat: "endurance",
                    preferredStatMin: 5.0,
                    outcomes: [
                        SegmentOutcome(
                            id: "steady_success",
                            probabilityBase: 0.7,
                            statModifier: "endurance",
                            statThreshold: 5.0,
                            narrative: "You hold a solid pace. Efficient, relaxed, controlled.",
                            effects: OutcomeEffects(energy: -10, morale: 2, hydration: -5, muscleDamage: 4, timeBonusMinutes: 0, injuryChance: 0.01),
                            outcomeType: .good
                        )
                    ],
                    energyModifier: 1.0,
                    timeModifier: 1.0,
                    moraleModifier: 0,
                    hydrationModifier: 0,
                    muscleDamageModifier: 1.0
                )
            ]
        case .steepDescent:
            return [
                SegmentChoice(
                    id: "bomb_descent",
                    label: "Bomb It",
                    description: "Send it down. High risk, high reward.",
                    icon: "💥",
                    preferredStat: "descending",
                    preferredStatMin: 7.0,
                    outcomes: [
                        SegmentOutcome(
                            id: "bomb_success",
                            probabilityBase: 0.3,
                            statModifier: "descending",
                            statThreshold: 7.0,
                            narrative: "You're a descending machine. Flying past slower runners. This is your superpower.",
                            effects: OutcomeEffects(energy: -8, morale: 10, hydration: -4, muscleDamage: 18, timeBonusMinutes: -20, injuryChance: 0.08),
                            outcomeType: .great
                        ),
                        SegmentOutcome(
                            id: "bomb_fail",
                            probabilityBase: 0.4,
                            statModifier: "descending",
                            statThreshold: 4.0,
                            narrative: "You roll an ankle on a rock. Not bad but scary. You slow way down.",
                            effects: OutcomeEffects(energy: -12, morale: -8, hydration: -6, muscleDamage: 25, timeBonusMinutes: 10, injuryChance: 0.15),
                            outcomeType: .bad
                        )
                    ],
                    energyModifier: 0.8,
                    timeModifier: 0.6,
                    moraleModifier: 0,
                    hydrationModifier: 0,
                    muscleDamageModifier: 1.8
                ),
                SegmentChoice(
                    id: "controlled_descent",
                    label: "Stay Controlled",
                    description: "Safe and steady. Protect the quads.",
                    icon: "🛡️",
                    preferredStat: "durability",
                    preferredStatMin: 5.0,
                    outcomes: [
                        SegmentOutcome(
                            id: "controlled_success",
                            probabilityBase: 0.7,
                            statModifier: "durability",
                            statThreshold: 5.0,
                            narrative: "Smart descending. You're slower but your legs will thank you at mile 80.",
                            effects: OutcomeEffects(energy: -10, morale: 0, hydration: -4, muscleDamage: 10, timeBonusMinutes: 5, injuryChance: 0.02),
                            outcomeType: .good
                        )
                    ],
                    energyModifier: 1.0,
                    timeModifier: 1.1,
                    moraleModifier: -1,
                    hydrationModifier: 0,
                    muscleDamageModifier: 1.0
                )
            ]
        default:
            return []
        }
    }

    private static func calculateBaseEnergy(segmentType: SegmentType, distance: Double) -> Double {
        let baseCost = distance * 3.0 // 3 energy per mile base
        let typeMult: Double = switch segmentType {
        case .majorClimb, .technicalClimb: 2.0
        case .steepDescent: 1.5
        case .flatRunnable: 0.8
        default: 1.0
        }
        return baseCost * typeMult
    }
}
