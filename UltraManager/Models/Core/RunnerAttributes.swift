import Foundation
import SwiftData

@Model
final class RunnerAttributes: Codable {
    // Primary Attributes (1.0 - 10.0)
    var speed: Double
    var endurance: Double
    var climbing: Double
    var descending: Double
    var durability: Double
    var mental: Double
    var technical: Double
    var recovery: Double
    var heatTolerance: Double
    var coldTolerance: Double
    var altitude: Double
    var nutrition: Double
    var raceCraft: Double

    init(speed: Double = 5.0,
         endurance: Double = 5.0,
         climbing: Double = 5.0,
         descending: Double = 5.0,
         durability: Double = 5.0,
         mental: Double = 5.0,
         technical: Double = 5.0,
         recovery: Double = 5.0,
         heatTolerance: Double = 5.0,
         coldTolerance: Double = 5.0,
         altitude: Double = 5.0,
         nutrition: Double = 5.0,
         raceCraft: Double = 5.0) {
        self.speed = speed
        self.endurance = endurance
        self.climbing = climbing
        self.descending = descending
        self.durability = durability
        self.mental = mental
        self.technical = technical
        self.recovery = recovery
        self.heatTolerance = heatTolerance
        self.coldTolerance = coldTolerance
        self.altitude = altitude
        self.nutrition = nutrition
        self.raceCraft = raceCraft
    }

    enum CodingKeys: String, CodingKey {
        case speed, endurance, climbing, descending, durability, mental, technical
        case recovery, heatTolerance, coldTolerance, altitude, nutrition, raceCraft
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        speed = try container.decode(Double.self, forKey: .speed)
        endurance = try container.decode(Double.self, forKey: .endurance)
        climbing = try container.decode(Double.self, forKey: .climbing)
        descending = try container.decode(Double.self, forKey: .descending)
        durability = try container.decode(Double.self, forKey: .durability)
        mental = try container.decode(Double.self, forKey: .mental)
        technical = try container.decode(Double.self, forKey: .technical)
        recovery = try container.decode(Double.self, forKey: .recovery)
        heatTolerance = try container.decode(Double.self, forKey: .heatTolerance)
        coldTolerance = try container.decode(Double.self, forKey: .coldTolerance)
        altitude = try container.decode(Double.self, forKey: .altitude)
        nutrition = try container.decode(Double.self, forKey: .nutrition)
        raceCraft = try container.decode(Double.self, forKey: .raceCraft)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(speed, forKey: .speed)
        try container.encode(endurance, forKey: .endurance)
        try container.encode(climbing, forKey: .climbing)
        try container.encode(descending, forKey: .descending)
        try container.encode(durability, forKey: .durability)
        try container.encode(mental, forKey: .mental)
        try container.encode(technical, forKey: .technical)
        try container.encode(recovery, forKey: .recovery)
        try container.encode(heatTolerance, forKey: .heatTolerance)
        try container.encode(coldTolerance, forKey: .coldTolerance)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(nutrition, forKey: .nutrition)
        try container.encode(raceCraft, forKey: .raceCraft)
    }

    func getValue(for key: String) -> Double {
        switch key {
        case "speed": return speed
        case "endurance": return endurance
        case "climbing": return climbing
        case "descending": return descending
        case "durability": return durability
        case "mental": return mental
        case "technical": return technical
        case "recovery": return recovery
        case "heatTolerance": return heatTolerance
        case "coldTolerance": return coldTolerance
        case "altitude": return altitude
        case "nutrition": return nutrition
        case "raceCraft": return raceCraft
        default: return 0.0
        }
    }

    func setValue(for key: String, value: Double) {
        let clamped = min(max(value, 1.0), 10.0)
        switch key {
        case "speed": speed = clamped
        case "endurance": endurance = clamped
        case "climbing": climbing = clamped
        case "descending": descending = clamped
        case "durability": durability = clamped
        case "mental": mental = clamped
        case "technical": technical = clamped
        case "recovery": recovery = clamped
        case "heatTolerance": heatTolerance = clamped
        case "coldTolerance": coldTolerance = clamped
        case "altitude": altitude = clamped
        case "nutrition": nutrition = clamped
        case "raceCraft": raceCraft = clamped
        default: break
        }
    }

    func applyGrowth(stat: String, amount: Double, age: Int, form: Double, diminishingFactor: Bool = true) {
        let current = getValue(for: stat)
        var growth = amount

        // Diminishing returns
        if diminishingFactor {
            let factor = 1.0 - (current / 12.0)
            growth *= factor
        }

        // Age modifier
        let ageMod: Double = switch age {
        case ...30: 1.0
        case 31...35: 0.95
        case 36...40: 0.85
        case 41...45: 0.75
        default: 0.65
        }
        growth *= ageMod

        // Form modifier
        let formMod: Double = switch form {
        case 10...: 1.15
        case 0..<10: 1.0
        case -10..<0: 0.85
        default: 0.70
        }
        growth *= formMod

        let newValue = current + growth
        setValue(for: stat, value: newValue)
    }

    func applyDecay(stat: String, amount: Double = 0.02) {
        let current = getValue(for: stat)
        let newValue = current - amount
        setValue(for: stat, value: newValue)
    }
}
