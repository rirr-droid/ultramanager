import Foundation

struct Injury: Identifiable, Codable {
    let id: String
    let name: String
    let category: InjuryCategory
    let weeksOutMin: Int
    let weeksOutMax: Int
    let statHits: [String: Double]
    let recurrenceRisk: Double
    let careerThreatening: Bool
    let specialEffect: String?

    static let catalog: [Injury] = [
        // Overuse
        Injury(
            id: "plantar_fasciitis",
            name: "Plantar Fasciitis",
            category: .overuse,
            weeksOutMin: 3,
            weeksOutMax: 6,
            statHits: ["speed": -0.3, "durability": -0.2],
            recurrenceRisk: 0.3,
            careerThreatening: false,
            specialEffect: nil
        ),
        Injury(
            id: "it_band",
            name: "IT Band Syndrome",
            category: .overuse,
            weeksOutMin: 2,
            weeksOutMax: 4,
            statHits: ["climbing": -0.3, "descending": -0.3],
            recurrenceRisk: 0.25,
            careerThreatening: false,
            specialEffect: nil
        ),
        Injury(
            id: "achilles_tendinopathy",
            name: "Achilles Tendinopathy",
            category: .overuse,
            weeksOutMin: 4,
            weeksOutMax: 8,
            statHits: ["speed": -0.4, "climbing": -0.2],
            recurrenceRisk: 0.35,
            careerThreatening: false,
            specialEffect: nil
        ),
        Injury(
            id: "patellar_tendinitis",
            name: "Patellar Tendinitis",
            category: .overuse,
            weeksOutMin: 3,
            weeksOutMax: 5,
            statHits: ["descending": -0.4, "climbing": -0.2],
            recurrenceRisk: 0.2,
            careerThreatening: false,
            specialEffect: nil
        ),
        Injury(
            id: "tibial_stress_fracture",
            name: "Tibial Stress Fracture",
            category: .bone,
            weeksOutMin: 8,
            weeksOutMax: 12,
            statHits: ["speed": -0.5, "endurance": -0.3, "durability": -0.5],
            recurrenceRisk: 0.2,
            careerThreatening: false,
            specialEffect: nil
        ),
        Injury(
            id: "femoral_stress_fracture",
            name: "Femoral Stress Fracture",
            category: .bone,
            weeksOutMin: 10,
            weeksOutMax: 16,
            statHits: ["speed": -0.3, "endurance": -0.3, "climbing": -0.3, "durability": -0.3],
            recurrenceRisk: 0.1,
            careerThreatening: true,
            specialEffect: nil
        ),

        // Acute
        Injury(
            id: "ankle_sprain_grade1",
            name: "Ankle Sprain (Grade 1)",
            category: .acute,
            weeksOutMin: 1,
            weeksOutMax: 2,
            statHits: ["technical": -0.2],
            recurrenceRisk: 0.4,
            careerThreatening: false,
            specialEffect: nil
        ),
        Injury(
            id: "ankle_sprain_grade2",
            name: "Ankle Sprain (Grade 2)",
            category: .acute,
            weeksOutMin: 3,
            weeksOutMax: 5,
            statHits: ["technical": -0.4, "speed": -0.2],
            recurrenceRisk: 0.35,
            careerThreatening: false,
            specialEffect: nil
        ),
        Injury(
            id: "hamstring_strain",
            name: "Hamstring Strain",
            category: .acute,
            weeksOutMin: 2,
            weeksOutMax: 4,
            statHits: ["speed": -0.4, "climbing": -0.2],
            recurrenceRisk: 0.3,
            careerThreatening: false,
            specialEffect: nil
        ),
        Injury(
            id: "calf_strain",
            name: "Calf Strain",
            category: .acute,
            weeksOutMin: 2,
            weeksOutMax: 3,
            statHits: ["speed": -0.3],
            recurrenceRisk: 0.25,
            careerThreatening: false,
            specialEffect: nil
        ),

        // Systemic
        Injury(
            id: "overtraining_syndrome",
            name: "Overtraining Syndrome",
            category: .systemic,
            weeksOutMin: 6,
            weeksOutMax: 12,
            statHits: ["speed": -0.3, "endurance": -0.3, "mental": -0.4, "recovery": -0.3],
            recurrenceRisk: 0.4,
            careerThreatening: false,
            specialEffect: "All training effectiveness reduced by 50% for 8 weeks after return"
        ),
        Injury(
            id: "anemia",
            name: "Iron Deficiency / Anemia",
            category: .systemic,
            weeksOutMin: 4,
            weeksOutMax: 8,
            statHits: ["endurance": -0.5, "speed": -0.3],
            recurrenceRisk: 0.3,
            careerThreatening: false,
            specialEffect: nil
        ),
        Injury(
            id: "rhabdomyolysis",
            name: "Rhabdomyolysis",
            category: .systemic,
            weeksOutMin: 4,
            weeksOutMax: 8,
            statHits: ["endurance": -0.4, "durability": -0.3],
            recurrenceRisk: 0.1,
            careerThreatening: false,
            specialEffect: "Can only occur during/after races. Triggered by extreme heat + high effort + dehydration"
        )
    ]

    static func get(_ id: String) -> Injury? {
        catalog.first { $0.id == id }
    }

    static func roll(runner: Runner, trainingIntensity: Double, recurrenceFactor: Double = 1.0) -> Injury? {
        guard let derived = runner.derived, let attributes = runner.attributes else { return nil }

        // Update injury risk
        var mutableDerived = derived
        mutableDerived.updateInjuryRisk(attributes: attributes, age: runner.age, trainingIntensity: trainingIntensity, recurrenceFactor: recurrenceFactor)

        // Roll for injury
        let roll = Double.random(in: 0...1)
        if roll < mutableDerived.injuryRisk {
            // Select injury type based on training type and current stats
            let weightedInjuries = catalog.filter { !$0.careerThreatening || runner.age > 38 }
            return weightedInjuries.randomElement()
        }

        return nil
    }
}

enum InjuryCategory: String, Codable {
    case overuse
    case acute
    case bone
    case systemic
}

struct InjuryRecord: Codable {
    let injuryID: String
    let injuryName: String
    let season: Int
    let week: Int
    let weeksOut: Int
    let statHits: [String: Double]
}
