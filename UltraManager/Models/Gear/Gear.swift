import Foundation

protocol GearItem: Identifiable, Codable {
    var id: String { get }
    var name: String { get }
    var brandID: String { get }
    var cost: Double { get }
}

struct Shoe: GearItem {
    let id: String
    let name: String
    let brandID: String
    let category: ShoeCategory
    let cost: Double

    // Stats
    let speedMod: Double
    let durabilityMod: Double
    let technicalMod: Double
    let climbingMod: Double
    let descendingMod: Double
    let comfort: Double
    let grip: Double
    let weight: Int // grams

    // Degradation
    let lifespanMiles: Double
    var currentMiles: Double

    var condition: Double {
        1.0 - (currentMiles / lifespanMiles)
    }

    var effectiveSpeedMod: Double {
        let degradation = calculateDegradation()
        return speedMod * degradation
    }

    var effectiveGrip: Double {
        let degradation = calculateDegradation()
        return grip * degradation
    }

    private func calculateDegradation() -> Double {
        let condition = condition
        switch condition {
        case 0.7...1.0: return 1.0
        case 0.3..<0.7: return 0.9
        case 0.15..<0.3: return 0.75
        default: return 0.5
        }
    }

    mutating func addMiles(_ miles: Double) {
        currentMiles += miles
    }

    static let starter = Shoe(
        id: "starter_trail_shoe",
        name: "Trail Runner 3000",
        brandID: "generic",
        category: .trail,
        cost: 0,
        speedMod: 0,
        durabilityMod: 0,
        technicalMod: 0,
        climbingMod: 0,
        descendingMod: 0,
        comfort: 5,
        grip: 5,
        weight: 280,
        lifespanMiles: 350,
        currentMiles: 0
    )

    static let catalog: [Shoe] = [
        starter,
        Shoe(
            id: "summit_athletics_speedgoat",
            name: "Summit Speedgoat",
            brandID: "summit_athletics",
            category: .mountain,
            cost: 155,
            speedMod: 0.3,
            durabilityMod: 0.5,
            technicalMod: 0.8,
            climbingMod: 0.5,
            descendingMod: 0.4,
            comfort: 8,
            grip: 9,
            weight: 265,
            lifespanMiles: 400,
            currentMiles: 0
        ),
        Shoe(
            id: "alpine_speed_sense",
            name: "Alpine Speed Sense Pro",
            brandID: "alpine_speed",
            category: .racing,
            cost: 180,
            speedMod: 1.2,
            durabilityMod: -0.3,
            technicalMod: 0.6,
            climbingMod: 0.3,
            descendingMod: 0.7,
            comfort: 7,
            grip: 8,
            weight: 220,
            lifespanMiles: 300,
            currentMiles: 0
        ),
        Shoe(
            id: "vapor_trail_pegasus",
            name: "Vapor Trail Pegasus Ultra",
            brandID: "vapor_trail_co",
            category: .trail,
            cost: 170,
            speedMod: 0.8,
            durabilityMod: 0.2,
            technicalMod: 0.4,
            climbingMod: 0.2,
            descendingMod: 0.5,
            comfort: 9,
            grip: 7,
            weight: 250,
            lifespanMiles: 380,
            currentMiles: 0
        ),
        Shoe(
            id: "natural_stride_lone_peak",
            name: "Natural Stride Lone Peak",
            brandID: "natural_stride",
            category: .trail,
            cost: 140,
            speedMod: 0.2,
            durabilityMod: 0.6,
            technicalMod: 0.5,
            climbingMod: 0.3,
            descendingMod: 0.3,
            comfort: 9,
            grip: 8,
            weight: 290,
            lifespanMiles: 450,
            currentMiles: 0
        )
    ]

    static func get(_ id: String) -> Shoe? {
        catalog.first { $0.id == id }
    }
}

enum ShoeCategory: String, Codable {
    case road
    case trail
    case mountain
    case racing
    case maximalist
}

struct Vest: GearItem {
    let id: String
    let name: String
    let brandID: String
    let cost: Double

    let capacityLiters: Double
    let comfort: Double
    let weightEmpty: Int // grams
    let waterCarry: Int // ml
    let foodSlots: Int
    let poleCarry: Bool

    static let basic = Vest(
        id: "basic_vest",
        name: "Basic Trail Vest",
        brandID: "generic",
        cost: 0,
        capacityLiters: 8,
        comfort: 5,
        weightEmpty: 250,
        waterCarry: 1000,
        foodSlots: 4,
        poleCarry: false
    )

    static let catalog: [Vest] = [
        basic,
        Vest(
            id: "alpine_speed_adv_skin",
            name: "Alpine Advanced Skin 12",
            brandID: "alpine_speed",
            cost: 180,
            capacityLiters: 12,
            comfort: 9,
            weightEmpty: 195,
            waterCarry: 1500,
            foodSlots: 8,
            poleCarry: true
        ),
        Vest(
            id: "summit_athletics_vest",
            name: "Summit Race Vest 2.0",
            brandID: "summit_athletics",
            cost: 150,
            capacityLiters: 10,
            comfort: 8,
            weightEmpty: 220,
            waterCarry: 1500,
            foodSlots: 6,
            poleCarry: true
        )
    ]

    static func get(_ id: String) -> Vest? {
        catalog.first { $0.id == id }
    }
}

struct TrekkingPoles: GearItem {
    let id: String
    let name: String
    let brandID: String
    let cost: Double

    let weight: Int // grams per pole
    let climbingBonus: Double
    let descendingBonus: Double
    let collapsible: Bool

    static let catalog: [TrekkingPoles] = [
        TrekkingPoles(
            id: "carbon_ultralight",
            name: "Carbon Ultralight Poles",
            brandID: "generic",
            cost: 120,
            weight: 180,
            climbingBonus: 0.4,
            descendingBonus: 0.6,
            collapsible: true
        ),
        TrekkingPoles(
            id: "black_diamond_z",
            name: "Alpine Z-Poles",
            brandID: "alpine_outfitters",
            cost: 170,
            weight: 150,
            climbingBonus: 0.5,
            descendingBonus: 0.7,
            collapsible: true
        )
    ]

    static func get(_ id: String) -> TrekkingPoles? {
        catalog.first { $0.id == id }
    }
}
