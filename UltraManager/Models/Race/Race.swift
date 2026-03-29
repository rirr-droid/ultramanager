import Foundation

struct Race: Identifiable, Codable {
    let id: String
    let name: String
    let realWorldAnalog: String
    let distance: String
    let distanceMiles: Double
    let elevationGain: Int
    let elevationLoss: Int
    let difficulty: Int
    let terrainProfile: [TerrainType]
    let aidStationCount: Int
    let hasCutoffs: Bool
    let cutoffHours: Double?
    let heatFactor: Int
    let coldFactor: Int
    let altitudeMax: Int
    let altitudeAvg: Int
    let nightSections: Bool
    let crewAllowed: Bool
    let pacerAllowedAfterMile: Double?
    let polesAllowed: Bool

    // Entry requirements
    let minEndurance: Double
    let minPrestige: Double
    let qualifierRaces: [String]
    let lottery: Bool
    let lotteryOdds: Double
    let entryFee: Double
    let maxEntrants: Int

    // Rewards
    let prestigeReward: Double
    let prizeMoney: [Double]
    let goldenTicket: Bool
    let goldenTicketRace: String?
    let buckleCutoffHours: Double?

    // Recovery
    let recoveryWeeks: Int

    var category: RaceCategory {
        if distanceMiles >= 200 { return .ultra200Plus }
        if distanceMiles >= 100 { return .hundredMile }
        if distanceMiles >= 60 { return .hundredK }
        if distanceMiles >= 45 { return .fiftyMile }
        return .fiftyK
    }

    static let catalog: [Race] = [
        Race(
            id: "pine_ridge_50k",
            name: "Pine Ridge 50K",
            realWorldAnalog: "Generic starter",
            distance: "50K",
            distanceMiles: 31,
            elevationGain: 4500,
            elevationLoss: 4500,
            difficulty: 3,
            terrainProfile: [.trail, .fireRoad, .trail],
            aidStationCount: 5,
            hasCutoffs: true,
            cutoffHours: 9,
            heatFactor: 4,
            coldFactor: 3,
            altitudeMax: 3500,
            altitudeAvg: 2800,
            nightSections: false,
            crewAllowed: false,
            pacerAllowedAfterMile: nil,
            polesAllowed: true,
            minEndurance: 4.0,
            minPrestige: 0,
            qualifierRaces: [],
            lottery: false,
            lotteryOdds: 1.0,
            entryFee: 150,
            maxEntrants: 300,
            prestigeReward: 15,
            prizeMoney: [500, 300, 200, 100, 0],
            goldenTicket: false,
            goldenTicketRace: nil,
            buckleCutoffHours: nil,
            recoveryWeeks: 2
        ),
        Race(
            id: "sierra_crest_100",
            name: "Sierra Crest 100",
            realWorldAnalog: "Western States",
            distance: "100M",
            distanceMiles: 100.2,
            elevationGain: 18500,
            elevationLoss: 22500,
            difficulty: 8,
            terrainProfile: [.alpine, .technical, .canyon, .fireRoad],
            aidStationCount: 20,
            hasCutoffs: true,
            cutoffHours: 30,
            heatFactor: 9,
            coldFactor: 3,
            altitudeMax: 8700,
            altitudeAvg: 5000,
            nightSections: true,
            crewAllowed: true,
            pacerAllowedAfterMile: 62,
            polesAllowed: true,
            minEndurance: 7.5,
            minPrestige: 200,
            qualifierRaces: ["badger_peak_50m", "gorge_falls_100k"],
            lottery: true,
            lotteryOdds: 0.08,
            entryFee: 375,
            maxEntrants: 400,
            prestigeReward: 200,
            prizeMoney: [10000, 7500, 5000, 2500, 1000],
            goldenTicket: false,
            goldenTicketRace: nil,
            buckleCutoffHours: 24,
            recoveryWeeks: 8
        ),
        Race(
            id: "badger_peak_50m",
            name: "Badger Peak 50M",
            realWorldAnalog: "Badger Mountain",
            distance: "50M",
            distanceMiles: 50,
            elevationGain: 6000,
            elevationLoss: 6000,
            difficulty: 4,
            terrainProfile: [.desert, .fireRoad, .trail],
            aidStationCount: 8,
            hasCutoffs: true,
            cutoffHours: 13,
            heatFactor: 8,
            coldFactor: 2,
            altitudeMax: 4200,
            altitudeAvg: 3500,
            nightSections: false,
            crewAllowed: true,
            pacerAllowedAfterMile: 38,
            polesAllowed: true,
            minEndurance: 5.5,
            minPrestige: 25,
            qualifierRaces: [],
            lottery: false,
            lotteryOdds: 1.0,
            entryFee: 200,
            maxEntrants: 250,
            prestigeReward: 35,
            prizeMoney: [1000, 600, 400, 200, 0],
            goldenTicket: true,
            goldenTicketRace: "sierra_crest_100",
            buckleCutoffHours: nil,
            recoveryWeeks: 3
        ),
        Race(
            id: "mont_blanc_alpine_ultra",
            name: "Mont Blanc Alpine Ultra",
            realWorldAnalog: "UTMB",
            distance: "100M",
            distanceMiles: 103,
            elevationGain: 32000,
            elevationLoss: 32000,
            difficulty: 9,
            terrainProfile: [.alpine, .technical, .alpine],
            aidStationCount: 25,
            hasCutoffs: true,
            cutoffHours: 46,
            heatFactor: 3,
            coldFactor: 7,
            altitudeMax: 9600,
            altitudeAvg: 6500,
            nightSections: true,
            crewAllowed: false,
            pacerAllowedAfterMile: nil,
            polesAllowed: true,
            minEndurance: 8.0,
            minPrestige: 400,
            qualifierRaces: [],
            lottery: true,
            lotteryOdds: 0.05,
            entryFee: 450,
            maxEntrants: 2300,
            prestigeReward: 350,
            prizeMoney: [15000, 10000, 7500, 5000, 2500],
            goldenTicket: false,
            goldenTicketRace: nil,
            buckleCutoffHours: 40,
            recoveryWeeks: 10
        ),
        Race(
            id: "gorge_falls_100k",
            name: "Gorge Falls 100K",
            realWorldAnalog: "Gorge Waterfalls",
            distance: "100K",
            distanceMiles: 62,
            elevationGain: 10000,
            elevationLoss: 10000,
            difficulty: 5,
            terrainProfile: [.trail, .technical, .muddy],
            aidStationCount: 12,
            hasCutoffs: true,
            cutoffHours: 16,
            heatFactor: 4,
            coldFactor: 6,
            altitudeMax: 4000,
            altitudeAvg: 1500,
            nightSections: false,
            crewAllowed: true,
            pacerAllowedAfterMile: nil,
            polesAllowed: true,
            minEndurance: 6.5,
            minPrestige: 50,
            qualifierRaces: [],
            lottery: false,
            lotteryOdds: 1.0,
            entryFee: 225,
            maxEntrants: 350,
            prestigeReward: 60,
            prizeMoney: [1500, 1000, 700, 400, 0],
            goldenTicket: true,
            goldenTicketRace: "sierra_crest_100",
            buckleCutoffHours: nil,
            recoveryWeeks: 4
        ),
        Race(
            id: "san_juan_hundred",
            name: "San Juan Hundred",
            realWorldAnalog: "Hardrock 100",
            distance: "100M",
            distanceMiles: 100,
            elevationGain: 33000,
            elevationLoss: 33000,
            difficulty: 9,
            terrainProfile: [.alpine, .technical, .snow, .alpine],
            aidStationCount: 13,
            hasCutoffs: true,
            cutoffHours: 48,
            heatFactor: 2,
            coldFactor: 8,
            altitudeMax: 13000,
            altitudeAvg: 11000,
            nightSections: true,
            crewAllowed: true,
            pacerAllowedAfterMile: nil,
            polesAllowed: true,
            minEndurance: 8.5,
            minPrestige: 500,
            qualifierRaces: ["sierra_crest_100", "mont_blanc_alpine_ultra"],
            lottery: true,
            lotteryOdds: 0.03,
            entryFee: 450,
            maxEntrants: 140,
            prestigeReward: 400,
            prizeMoney: [0, 0, 0, 0, 0],
            goldenTicket: false,
            goldenTicketRace: nil,
            buckleCutoffHours: nil,
            recoveryWeeks: 12
        ),
        Race(
            id: "colorado_divide_100",
            name: "Colorado Divide 100",
            realWorldAnalog: "Leadville 100",
            distance: "100M",
            distanceMiles: 100,
            elevationGain: 15600,
            elevationLoss: 15600,
            difficulty: 7,
            terrainProfile: [.fireRoad, .alpine, .fireRoad],
            aidStationCount: 14,
            hasCutoffs: true,
            cutoffHours: 30,
            heatFactor: 5,
            coldFactor: 6,
            altitudeMax: 12600,
            altitudeAvg: 10000,
            nightSections: true,
            crewAllowed: true,
            pacerAllowedAfterMile: 50,
            polesAllowed: true,
            minEndurance: 7.5,
            minPrestige: 300,
            qualifierRaces: [],
            lottery: false,
            lotteryOdds: 1.0,
            entryFee: 400,
            maxEntrants: 800,
            prestigeReward: 250,
            prizeMoney: [5000, 3000, 2000, 1000, 500],
            goldenTicket: false,
            goldenTicketRace: nil,
            buckleCutoffHours: nil,
            recoveryWeeks: 8
        )
    ]

    static func get(_ id: String) -> Race? {
        catalog.first { $0.id == id }
    }

    static func available(for runner: Runner) -> [Race] {
        catalog.filter { race in
            guard let attributes = runner.attributes else { return false }
            return attributes.endurance >= race.minEndurance &&
                   runner.prestige >= race.minPrestige
        }
    }
}

enum RaceCategory: String {
    case fiftyK = "50K"
    case fiftyMile = "50M"
    case hundredK = "100K"
    case hundredMile = "100M"
    case ultra200Plus = "200M+"
}

enum TerrainType: String, Codable {
    case road
    case fireRoad
    case trail
    case technical
    case alpine
    case desert
    case canyon
    case muddy
    case snow
    case river
}
