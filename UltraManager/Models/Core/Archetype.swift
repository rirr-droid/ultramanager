import Foundation

enum ArchetypeKey: String, Codable, CaseIterable {
    case speedster
    case mountainGoat
    case dieselEngine
    case allRounder
    case comebackKid
    case fatAdaptedOutlier
    case lateBloomer
    case thruHiker
}

struct Archetype: Codable, Identifiable {
    let id: ArchetypeKey
    let name: String
    let description: String
    let backstory: String
    let startingAge: Int
    let stats: [String: Double]
    let passive: ArchetypePassive

    static let all: [Archetype] = [
        Archetype(
            id: .speedster,
            name: "The Speedster",
            description: "Road marathon convert. Fast on flats, untested on mountains.",
            backstory: "Ran a 2:45 marathon and wants more. The trails are calling.",
            startingAge: 28,
            stats: [
                "speed": 8, "endurance": 5, "climbing": 3, "descending": 4,
                "durability": 3, "mental": 4, "technical": 2, "recovery": 5,
                "heatTolerance": 4, "coldTolerance": 4, "altitude": 3,
                "nutrition": 5, "raceCraft": 4
            ],
            passive: .roadLegs
        ),
        Archetype(
            id: .mountainGoat,
            name: "The Mountain Goat",
            description: "Born in the mountains. Lives for vert. Descents are just uphill in reverse.",
            backstory: "Grew up hiking 14ers. Started running them. Never looked back.",
            startingAge: 26,
            stats: [
                "speed": 3, "endurance": 5, "climbing": 9, "descending": 6,
                "durability": 5, "mental": 6, "technical": 7, "recovery": 4,
                "heatTolerance": 3, "coldTolerance": 6, "altitude": 7,
                "nutrition": 4, "raceCraft": 5
            ],
            passive: .summitFever
        ),
        Archetype(
            id: .dieselEngine,
            name: "The Diesel Engine",
            description: "Slow and steady wins the 100. Born to suffer, built to last.",
            backstory: "Never fast, but never stops. Ran first 100 on pure stubbornness.",
            startingAge: 30,
            stats: [
                "speed": 3, "endurance": 9, "climbing": 4, "descending": 4,
                "durability": 7, "mental": 8, "technical": 4, "recovery": 5,
                "heatTolerance": 5, "coldTolerance": 5, "altitude": 5,
                "nutrition": 7, "raceCraft": 6
            ],
            passive: .negativeSplitMachine
        ),
        Archetype(
            id: .allRounder,
            name: "The All-Rounder",
            description: "No weaknesses, no superpowers. A blank canvas with potential.",
            backstory: "Played every sport growing up. Found ultras last year. Hooked.",
            startingAge: 27,
            stats: [
                "speed": 5, "endurance": 5, "climbing": 5, "descending": 5,
                "durability": 5, "mental": 5, "technical": 5, "recovery": 5,
                "heatTolerance": 5, "coldTolerance": 5, "altitude": 5,
                "nutrition": 5, "raceCraft": 5
            ],
            passive: .adaptable
        ),
        Archetype(
            id: .comebackKid,
            name: "The Comeback Kid",
            description: "Former D1 runner who burned out. Rediscovering the joy on trails.",
            backstory: "Quit competitive running at 22. A decade later, the trails brought it back.",
            startingAge: 32,
            stats: [
                "speed": 6, "endurance": 4, "climbing": 3, "descending": 3,
                "durability": 4, "mental": 7, "technical": 3, "recovery": 6,
                "heatTolerance": 4, "coldTolerance": 4, "altitude": 3,
                "nutrition": 5, "raceCraft": 3
            ],
            passive: .secondWind
        ),
        Archetype(
            id: .fatAdaptedOutlier,
            name: "The Fat-Adapted Outlier",
            description: "Keto ultra machine. Doesn't need aid stations. Inspired by Zach Bitter.",
            backstory: "Read Volek & Phinney, went low-carb, ran 100 miles on beef jerky and MCT oil.",
            startingAge: 29,
            stats: [
                "speed": 5, "endurance": 7, "climbing": 4, "descending": 4,
                "durability": 5, "mental": 6, "technical": 4, "recovery": 6,
                "heatTolerance": 5, "coldTolerance": 5, "altitude": 4,
                "nutrition": 3, "raceCraft": 5
            ],
            passive: .fatBurningMachine
        ),
        Archetype(
            id: .lateBloomer,
            name: "The Late Bloomer",
            description: "Started running at 40 after a health scare. Unstoppable spirit.",
            backstory: "Doctor said 'exercise or else.' Signed up for a 50K on a dare. The rest is history.",
            startingAge: 40,
            stats: [
                "speed": 3, "endurance": 4, "climbing": 3, "descending": 3,
                "durability": 4, "mental": 9, "technical": 3, "recovery": 3,
                "heatTolerance": 4, "coldTolerance": 4, "altitude": 3,
                "nutrition": 4, "raceCraft": 3
            ],
            passive: .wisdomOfAge
        ),
        Archetype(
            id: .thruHiker,
            name: "The Thru-Hiker",
            description: "PCT, AT, CDT — done them all. Now wants to run them.",
            backstory: "2,650 miles on the PCT taught patience. Time to add speed.",
            startingAge: 27,
            stats: [
                "speed": 2, "endurance": 7, "climbing": 6, "descending": 5,
                "durability": 6, "mental": 7, "technical": 8, "recovery": 4,
                "heatTolerance": 5, "coldTolerance": 7, "altitude": 6,
                "nutrition": 6, "raceCraft": 4
            ],
            passive: .trailSavant
        )
    ]

    static func get(_ key: ArchetypeKey) -> Archetype {
        all.first { $0.id == key }!
    }
}

enum ArchetypePassive: String, Codable {
    case roadLegs = "Road Legs — +15% speed bonus on any course segment with >30% runnable trail"
    case summitFever = "Summit Fever — No morale penalty on climbs > 3000ft. +10% climbing efficiency above 8000ft"
    case negativeSplitMachine = "Negative Split Machine — Energy drain reduced by 20% in final 25% of any race"
    case adaptable = "Adaptable — Training gains are 10% more effective across all attributes"
    case secondWind = "Second Wind — Once per race, can fully restore morale when it drops below 15%"
    case fatBurningMachine = "Fat Burning Machine — Energy drain from nutrition failures reduced by 50%. Starts with 70 fat_adaptation"
    case wisdomOfAge = "Wisdom of Age — Mental attribute cannot drop below 7. +20% XP gain from all sources"
    case trailSavant = "Trail Savant — Technical terrain penalties reduced by 40%. Never fails river crossings"
}
