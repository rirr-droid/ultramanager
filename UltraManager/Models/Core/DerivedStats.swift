import Foundation
import SwiftData

@Model
final class DerivedStats: Codable {
    var fatigue: Double // 0-100
    var fitness: Double // 0-100
    var form: Double // -20 to +20 (CTL - ATL)
    var injuryRisk: Double // 0.0-1.0
    var muscleDamage: Double // 0-100
    var gutTrainingLevel: Double // 0-100
    var fatAdaptation: Double // 0-100
    var weight: Double // kg
    var bodyFatPct: Double // percentage

    // Training load tracking (for TSB model)
    var chronicTrainingLoad: Double // CTL (42-day average)
    var acuteTrainingLoad: Double // ATL (7-day average)
    var weeklyTrainingLoad: [Double] // Last 42 weeks of training load

    init(fatigue: Double = 0,
         fitness: Double = 50,
         form: Double = 0,
         injuryRisk: Double = 0.05,
         muscleDamage: Double = 0,
         gutTrainingLevel: Double = 50,
         fatAdaptation: Double = 50,
         weight: Double = 70,
         bodyFatPct: Double = 12) {
        self.fatigue = fatigue
        self.fitness = fitness
        self.form = form
        self.injuryRisk = injuryRisk
        self.muscleDamage = muscleDamage
        self.gutTrainingLevel = gutTrainingLevel
        self.fatAdaptation = fatAdaptation
        self.weight = weight
        self.bodyFatPct = bodyFatPct
        self.chronicTrainingLoad = 0
        self.acuteTrainingLoad = 0
        self.weeklyTrainingLoad = Array(repeating: 0, count: 42)
    }

    enum CodingKeys: String, CodingKey {
        case fatigue, fitness, form, injuryRisk, muscleDamage
        case gutTrainingLevel, fatAdaptation, weight, bodyFatPct
        case chronicTrainingLoad, acuteTrainingLoad, weeklyTrainingLoad
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fatigue = try container.decode(Double.self, forKey: .fatigue)
        fitness = try container.decode(Double.self, forKey: .fitness)
        form = try container.decode(Double.self, forKey: .form)
        injuryRisk = try container.decode(Double.self, forKey: .injuryRisk)
        muscleDamage = try container.decode(Double.self, forKey: .muscleDamage)
        gutTrainingLevel = try container.decode(Double.self, forKey: .gutTrainingLevel)
        fatAdaptation = try container.decode(Double.self, forKey: .fatAdaptation)
        weight = try container.decode(Double.self, forKey: .weight)
        bodyFatPct = try container.decode(Double.self, forKey: .bodyFatPct)
        chronicTrainingLoad = try container.decode(Double.self, forKey: .chronicTrainingLoad)
        acuteTrainingLoad = try container.decode(Double.self, forKey: .acuteTrainingLoad)
        weeklyTrainingLoad = try container.decode([Double].self, forKey: .weeklyTrainingLoad)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fatigue, forKey: .fatigue)
        try container.encode(fitness, forKey: .fitness)
        try container.encode(form, forKey: .form)
        try container.encode(injuryRisk, forKey: .injuryRisk)
        try container.encode(muscleDamage, forKey: .muscleDamage)
        try container.encode(gutTrainingLevel, forKey: .gutTrainingLevel)
        try container.encode(fatAdaptation, forKey: .fatAdaptation)
        try container.encode(weight, forKey: .weight)
        try container.encode(bodyFatPct, forKey: .bodyFatPct)
        try container.encode(chronicTrainingLoad, forKey: .chronicTrainingLoad)
        try container.encode(acuteTrainingLoad, forKey: .acuteTrainingLoad)
        try container.encode(weeklyTrainingLoad, forKey: .weeklyTrainingLoad)
    }

    func addWeeklyLoad(_ load: Double) {
        weeklyTrainingLoad.append(load)
        if weeklyTrainingLoad.count > 42 {
            weeklyTrainingLoad.removeFirst()
        }
        recalculateTrainingLoads()
    }

    private func recalculateTrainingLoads() {
        // CTL: 42-day exponential weighted average
        if weeklyTrainingLoad.count >= 6 {
            chronicTrainingLoad = weeklyTrainingLoad.suffix(42).reduce(0, +) / Double(min(42, weeklyTrainingLoad.count))
        }

        // ATL: 7-day exponential weighted average
        if weeklyTrainingLoad.count >= 1 {
            acuteTrainingLoad = weeklyTrainingLoad.suffix(7).reduce(0, +) / Double(min(7, weeklyTrainingLoad.count))
        }

        // TSB (form) = CTL - ATL
        form = chronicTrainingLoad - acuteTrainingLoad
        form = min(max(form, -20), 20)
    }

    func updateInjuryRisk(attributes: RunnerAttributes, age: Int, trainingIntensity: Double, recurrenceFactor: Double = 1.0) {
        let fatigueMult = 1.0 + (fatigue / 80.0)
        let durabilityProtection = 1.0 - (attributes.durability * 0.07)
        let ageFactor = 1.0 + max(0, Double(age - 35) * 0.03)
        let formFactor: Double = form < -10 ? 1.5 : form < 0 ? 1.2 : 1.0

        injuryRisk = 0.05 * fatigueMult * durabilityProtection * ageFactor * trainingIntensity * recurrenceFactor * formFactor
        injuryRisk = min(max(injuryRisk, 0.0), 1.0)
    }
}
