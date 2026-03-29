import Foundation

struct Sponsorship: Identifiable, Codable {
    let id: String
    let brandID: String
    let tier: SponsorshipTier
    let annualValue: Double
    let durationSeasons: Int
    let requirements: [SponsorshipRequirement]
    let perks: [String]
    let gearProvidedIDs: [String]
    let exclusivityCategories: [String]
    var relationshipScore: Double
    let contentObligations: Int // posts per month

    var brand: Brand {
        Brand.get(brandID)
    }
}

struct Brand: Identifiable, Codable {
    let id: String
    let name: String
    let analog: String
    let category: BrandCategory
    let personality: String
    let budget: BrandBudget

    static let catalog: [Brand] = [
        // Shoes
        Brand(id: "summit_athletics", name: "Summit Athletics", analog: "HOKA", category: .shoes, personality: "accessible, max cushion", budget: .high),
        Brand(id: "alpine_speed", name: "Alpine Speed", analog: "Salomon", category: .shoes, personality: "euro mountain, technical", budget: .high),
        Brand(id: "vapor_trail_co", name: "Vapor Trail Co", analog: "Nike Trail", category: .shoes, personality: "speed, innovation, carbon plates", budget: .veryHigh),
        Brand(id: "natural_stride", name: "Natural Stride", analog: "Altra", category: .shoes, personality: "zero drop, natural movement", budget: .medium),

        // Nutrition
        Brand(id: "hydro_science", name: "HydroScience", analog: "Maurten", category: .nutrition, personality: "hydrogel technology, premium", budget: .medium),
        Brand(id: "endurance_fuel_co", name: "Endurance Fuel Co", analog: "SiS", category: .nutrition, personality: "beta fuel, science-backed", budget: .medium),
        Brand(id: "simple_fuel", name: "Simple Fuel", analog: "Tailwind", category: .nutrition, personality: "simple, one-product, grassroots", budget: .low),
        Brand(id: "electro_pure", name: "ElectroPure", analog: "LMNT", category: .nutrition, personality: "electrolytes, keto-friendly, podcast-heavy", budget: .medium),
        Brand(id: "spring_supreme", name: "Spring Supreme", analog: "Spring Energy", category: .nutrition, personality: "real food gels, controversial lab results", budget: .low),

        // Apparel
        Brand(id: "alpine_outfitters", name: "Alpine Outfitters", analog: "Patagonia", category: .apparel, personality: "sustainability, premium, trail culture", budget: .high),
        Brand(id: "north_ridge", name: "North Ridge", analog: "The North Face", category: .apparel, personality: "legacy outdoor, UTMB title sponsor", budget: .veryHigh)
    ]

    static func get(_ id: String) -> Brand {
        catalog.first { $0.id == id } ?? catalog[0]
    }

    static func available(for runner: Runner) -> [Brand] {
        catalog.filter { brand in
            switch brand.budget {
            case .low: return runner.prestige >= 0
            case .medium: return runner.prestige >= 100
            case .high: return runner.prestige >= 300
            case .veryHigh: return runner.prestige >= 600
            }
        }
    }
}

enum BrandCategory: String, Codable {
    case shoes
    case nutrition
    case apparel
    case recovery
    case tech
}

enum BrandBudget: String, Codable {
    case low
    case medium
    case high
    case veryHigh
}

enum SponsorshipTier: String, Codable {
    case grassroots
    case regional
    case national
    case elite
    case signature

    var prestigeRequired: Double {
        switch self {
        case .grassroots: return 0
        case .regional: return 100
        case .national: return 300
        case .elite: return 600
        case .signature: return 1000
        }
    }

    var annualValueRange: ClosedRange<Double> {
        switch self {
        case .grassroots: return 0...0 // Gear only
        case .regional: return 2000...5000
        case .national: return 10000...30000
        case .elite: return 30000...80000
        case .signature: return 80000...200000
        }
    }
}

struct SponsorshipRequirement: Codable {
    let type: RequirementType
    let frequency: String
    let description: String
}

enum RequirementType: String, Codable {
    case socialMediaPost
    case localAppearance
    case productFeedback
    case photoshoot
    case brandCamp
    case wearBrandedKit
}

struct SponsorshipOffer: Identifiable, Codable {
    let id: String
    let brandID: String
    let tier: SponsorshipTier
    let annualValue: Double
    let durationSeasons: Int
    let expiresWeek: Int

    static func generate(for runner: Runner) -> [SponsorshipOffer] {
        let availableBrands = Brand.available(for: runner)
        var offers: [SponsorshipOffer] = []

        for brand in availableBrands.prefix(3) {
            let tier = determineTier(prestige: runner.prestige)
            let value = Double.random(in: tier.annualValueRange)

            offers.append(SponsorshipOffer(
                id: UUID().uuidString,
                brandID: brand.id,
                tier: tier,
                annualValue: value,
                durationSeasons: tier == .grassroots ? 1 : Int.random(in: 1...3),
                expiresWeek: runner.week + 4
            ))
        }

        return offers
    }

    private static func determineTier(prestige: Double) -> SponsorshipTier {
        if prestige >= 1000 { return .signature }
        if prestige >= 600 { return .elite }
        if prestige >= 300 { return .national }
        if prestige >= 100 { return .regional }
        return .grassroots
    }
}
