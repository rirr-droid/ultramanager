import Foundation

struct DailyNutritionPlan: Identifiable, Codable {
    let id: String
    let label: String
    let description: String
    let weeklyEffects: [String: Double]
    let costPerWeek: Double
    let gutTrainingMod: Double
    let fatAdaptationMod: Double
    let weightMod: Double
    let speedPenalty: Double

    static let all: [DailyNutritionPlan] = [
        DailyNutritionPlan(
            id: "standard",
            label: "Standard Mixed Diet",
            description: "50/30/20 carb/fat/protein. Nothing fancy.",
            weeklyEffects: ["nutrition": 0.02, "recovery": 0.01],
            costPerWeek: 100,
            gutTrainingMod: 0,
            fatAdaptationMod: 0,
            weightMod: 0,
            speedPenalty: 0
        ),
        DailyNutritionPlan(
            id: "high_carb_performance",
            label: "High Carb Performance",
            description: "60-70% carbs. Glycogen-optimized. Per Claire Shorenstein on HPO: gut training enables 90-120g/hr race fueling.",
            weeklyEffects: ["nutrition": 0.08, "endurance": 0.03, "speed": 0.02],
            costPerWeek: 180,
            gutTrainingMod: 3.0,
            fatAdaptationMod: -2.0,
            weightMod: 0.1,
            speedPenalty: 0
        ),
        DailyNutritionPlan(
            id: "low_carb_fat_adapted",
            label: "Low Carb / Fat Adapted",
            description: "Per Zach Bitter: 100-150g carbs/day with periodized carb timing. Not strict keto, but trains fat oxidation.",
            weeklyEffects: ["endurance": 0.04, "recovery": 0.04],
            costPerWeek: 160,
            gutTrainingMod: -1.0,
            fatAdaptationMod: 4.0,
            weightMod: -0.2,
            speedPenalty: -0.02
        ),
        DailyNutritionPlan(
            id: "whole_food_clean",
            label: "Whole Food / Anti-Inflammatory",
            description: "Emphasis on nutrient density, recovery foods, anti-inflammatory properties.",
            weeklyEffects: ["recovery": 0.06, "durability": 0.04],
            costPerWeek: 200,
            gutTrainingMod: 1.0,
            fatAdaptationMod: 1.0,
            weightMod: 0,
            speedPenalty: 0
        ),
        DailyNutritionPlan(
            id: "race_week_carb_load",
            label: "Race Week Carb Load",
            description: "3-day carb loading protocol before a race. +20% starting energy in race. Only effective during taper week.",
            weeklyEffects: ["nutrition": 0.02],
            costPerWeek: 150,
            gutTrainingMod: 0,
            fatAdaptationMod: 0,
            weightMod: 1.0,
            speedPenalty: 0
        )
    ]

    static func get(_ id: String) -> DailyNutritionPlan? {
        all.first { $0.id == id }
    }
}

struct NutritionProduct: Identifiable, Codable {
    let id: String
    let name: String
    let type: ProductType
    let carbs: Double
    let caffeine: Double
    let giRisk: Double
    let cost: Double
    let brandID: String
    let electrolyteBonus: Double
    let hiddenRisk: Double?
    let flavorText: String?

    static let catalog: [NutritionProduct] = [
        NutritionProduct(
            id: "beta_fuel_gel",
            name: "SiS Beta Fuel Gel",
            type: .gel,
            carbs: 40,
            caffeine: 0,
            giRisk: 0.05,
            cost: 3,
            brandID: "endurance_fuel_co",
            electrolyteBonus: 0,
            hiddenRisk: nil,
            flavorText: nil
        ),
        NutritionProduct(
            id: "maurten_caf_gel",
            name: "Maurten Caf 100",
            type: .gel,
            carbs: 25,
            caffeine: 100,
            giRisk: 0.03,
            cost: 4,
            brandID: "hydro_science",
            electrolyteBonus: 0,
            hiddenRisk: nil,
            flavorText: nil
        ),
        NutritionProduct(
            id: "never2nd_c90",
            name: "Never2nd C90",
            type: .drinkMix,
            carbs: 90,
            caffeine: 0,
            giRisk: 0.08,
            cost: 3,
            brandID: "generic",
            electrolyteBonus: 0,
            hiddenRisk: nil,
            flavorText: nil
        ),
        NutritionProduct(
            id: "pb_tortilla",
            name: "PB&J Tortilla Wrap",
            type: .realFood,
            carbs: 35,
            caffeine: 0,
            giRisk: 0.15,
            cost: 1,
            brandID: "generic",
            electrolyteBonus: 0,
            hiddenRisk: nil,
            flavorText: nil
        ),
        NutritionProduct(
            id: "boiled_potato",
            name: "Salted Boiled Potato",
            type: .realFood,
            carbs: 25,
            caffeine: 0,
            giRisk: 0.02,
            cost: 0.5,
            brandID: "generic",
            electrolyteBonus: 0.2,
            hiddenRisk: nil,
            flavorText: nil
        ),
        NutritionProduct(
            id: "tailwind",
            name: "Tailwind Endurance Fuel",
            type: .drinkMix,
            carbs: 50,
            caffeine: 0,
            giRisk: 0.04,
            cost: 2,
            brandID: "simple_fuel",
            electrolyteBonus: 0.5,
            hiddenRisk: nil,
            flavorText: nil
        ),
        NutritionProduct(
            id: "lmnt",
            name: "LMNT Electrolytes",
            type: .electrolyte,
            carbs: 0,
            caffeine: 0,
            giRisk: 0.01,
            cost: 2,
            brandID: "electro_pure",
            electrolyteBonus: 1.3,
            hiddenRisk: nil,
            flavorText: nil
        ),
        NutritionProduct(
            id: "questionable_superfuel",
            name: "UltraFuel Supreme",
            type: .gel,
            carbs: 45,
            caffeine: 0,
            giRisk: 0.02,
            cost: 5,
            brandID: "spring_supreme",
            electrolyteBonus: 0,
            hiddenRisk: 0.15,
            flavorText: "Claims 45g carbs per serving. Lab tests pending."
        )
    ]

    static func get(_ id: String) -> NutritionProduct? {
        catalog.first { $0.id == id }
    }
}

enum ProductType: String, Codable {
    case gel
    case drinkMix
    case realFood
    case electrolyte
}
