import Foundation
import SwiftData

@Model
final class Runner: Codable {
    // Identity
    var name: String
    var age: Int
    var gender: String
    var nationality: String
    var archetypeKey: String
    var backstory: String

    // Attributes and stats
    var attributes: RunnerAttributes?
    var derived: DerivedStats?

    // Career progression
    var level: Int
    var xp: Double
    var prestige: Double
    var money: Double
    var careerEarnings: Double
    var season: Int
    var week: Int

    // Current state
    var injured: Bool
    var injuryName: String
    var injuryWeeksLeft: Int
    var postRaceBlues: Bool
    var postRaceBluesWeeksLeft: Int
    var postRaceBluesSeverity: String
    var overtraining: Bool
    var currentTrainingBlock: String

    // Social
    var socialMediaFollowers: Int
    var contentQuality: Double
    var communityStanding: Double

    // Passive abilities
    var secondWindUsed: Bool

    // Gear (IDs reference gear items)
    var equippedShoeID: String?
    var equippedVestID: String?
    var equippedPolesID: String?

    // Nutrition plan (ID)
    var dailyNutritionPlanID: String

    // Relationships (stored as IDs, resolved at runtime)
    var sponsorshipIDs: [String]
    var gearClosetIDs: [String]
    var crewMemberIDs: [String]
    var pacerIDs: [String]
    var achievementIDs: [String]

    // Coach
    var coachID: String?
    var runClubID: String?

    init(name: String, archetype: Archetype, gender: String = "male", nationality: String = "USA") {
        self.name = name
        self.age = archetype.startingAge
        self.gender = gender
        self.nationality = nationality
        self.archetypeKey = archetype.id.rawValue
        self.backstory = archetype.backstory

        // Initialize attributes from archetype
        self.attributes = RunnerAttributes()
        for (key, value) in archetype.stats {
            self.attributes?.setValue(for: key, value: value)
        }

        // Initialize derived stats
        self.derived = DerivedStats()

        // Apply archetype-specific derived stat modifications
        if archetype.id == .fatAdaptedOutlier {
            self.derived?.fatAdaptation = 70
            self.derived?.gutTrainingLevel = 30
        }

        // Career
        self.level = 1
        self.xp = 0
        self.prestige = 0
        self.money = 5000 // Starting money
        self.careerEarnings = 0
        self.season = 1
        self.week = 1

        // State
        self.injured = false
        self.injuryName = ""
        self.injuryWeeksLeft = 0
        self.postRaceBlues = false
        self.postRaceBluesWeeksLeft = 0
        self.postRaceBluesSeverity = ""
        self.overtraining = false
        self.currentTrainingBlock = "base"

        // Social
        self.socialMediaFollowers = 100
        self.contentQuality = 5.0
        self.communityStanding = 10

        // Passive
        self.secondWindUsed = false

        // Gear
        self.equippedShoeID = "starter_trail_shoe"
        self.equippedVestID = "basic_vest"
        self.equippedPolesID = nil

        // Nutrition
        self.dailyNutritionPlanID = "standard"

        // Relationships
        self.sponsorshipIDs = []
        self.gearClosetIDs = ["starter_trail_shoe", "basic_vest"]
        self.crewMemberIDs = []
        self.pacerIDs = []
        self.achievementIDs = []

        self.coachID = nil
        self.runClubID = nil
    }

    enum CodingKeys: String, CodingKey {
        case name, age, gender, nationality, archetypeKey, backstory
        case attributes, derived
        case level, xp, prestige, money, careerEarnings, season, week
        case injured, injuryName, injuryWeeksLeft
        case postRaceBlues, postRaceBluesWeeksLeft, postRaceBluesSeverity
        case overtraining, currentTrainingBlock
        case socialMediaFollowers, contentQuality, communityStanding
        case secondWindUsed
        case equippedShoeID, equippedVestID, equippedPolesID
        case dailyNutritionPlanID
        case sponsorshipIDs, gearClosetIDs, crewMemberIDs, pacerIDs, achievementIDs
        case coachID, runClubID
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        gender = try container.decode(String.self, forKey: .gender)
        nationality = try container.decode(String.self, forKey: .nationality)
        archetypeKey = try container.decode(String.self, forKey: .archetypeKey)
        backstory = try container.decode(String.self, forKey: .backstory)
        attributes = try container.decodeIfPresent(RunnerAttributes.self, forKey: .attributes)
        derived = try container.decodeIfPresent(DerivedStats.self, forKey: .derived)
        level = try container.decode(Int.self, forKey: .level)
        xp = try container.decode(Double.self, forKey: .xp)
        prestige = try container.decode(Double.self, forKey: .prestige)
        money = try container.decode(Double.self, forKey: .money)
        careerEarnings = try container.decode(Double.self, forKey: .careerEarnings)
        season = try container.decode(Int.self, forKey: .season)
        week = try container.decode(Int.self, forKey: .week)
        injured = try container.decode(Bool.self, forKey: .injured)
        injuryName = try container.decode(String.self, forKey: .injuryName)
        injuryWeeksLeft = try container.decode(Int.self, forKey: .injuryWeeksLeft)
        postRaceBlues = try container.decode(Bool.self, forKey: .postRaceBlues)
        postRaceBluesWeeksLeft = try container.decode(Int.self, forKey: .postRaceBluesWeeksLeft)
        postRaceBluesSeverity = try container.decode(String.self, forKey: .postRaceBluesSeverity)
        overtraining = try container.decode(Bool.self, forKey: .overtraining)
        currentTrainingBlock = try container.decode(String.self, forKey: .currentTrainingBlock)
        socialMediaFollowers = try container.decode(Int.self, forKey: .socialMediaFollowers)
        contentQuality = try container.decode(Double.self, forKey: .contentQuality)
        communityStanding = try container.decode(Double.self, forKey: .communityStanding)
        secondWindUsed = try container.decode(Bool.self, forKey: .secondWindUsed)
        equippedShoeID = try container.decodeIfPresent(String.self, forKey: .equippedShoeID)
        equippedVestID = try container.decodeIfPresent(String.self, forKey: .equippedVestID)
        equippedPolesID = try container.decodeIfPresent(String.self, forKey: .equippedPolesID)
        dailyNutritionPlanID = try container.decode(String.self, forKey: .dailyNutritionPlanID)
        sponsorshipIDs = try container.decode([String].self, forKey: .sponsorshipIDs)
        gearClosetIDs = try container.decode([String].self, forKey: .gearClosetIDs)
        crewMemberIDs = try container.decode([String].self, forKey: .crewMemberIDs)
        pacerIDs = try container.decode([String].self, forKey: .pacerIDs)
        achievementIDs = try container.decode([String].self, forKey: .achievementIDs)
        coachID = try container.decodeIfPresent(String.self, forKey: .coachID)
        runClubID = try container.decodeIfPresent(String.self, forKey: .runClubID)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)
        try container.encode(gender, forKey: .gender)
        try container.encode(nationality, forKey: .nationality)
        try container.encode(archetypeKey, forKey: .archetypeKey)
        try container.encode(backstory, forKey: .backstory)
        try container.encodeIfPresent(attributes, forKey: .attributes)
        try container.encodeIfPresent(derived, forKey: .derived)
        try container.encode(level, forKey: .level)
        try container.encode(xp, forKey: .xp)
        try container.encode(prestige, forKey: .prestige)
        try container.encode(money, forKey: .money)
        try container.encode(careerEarnings, forKey: .careerEarnings)
        try container.encode(season, forKey: .season)
        try container.encode(week, forKey: .week)
        try container.encode(injured, forKey: .injured)
        try container.encode(injuryName, forKey: .injuryName)
        try container.encode(injuryWeeksLeft, forKey: .injuryWeeksLeft)
        try container.encode(postRaceBlues, forKey: .postRaceBlues)
        try container.encode(postRaceBluesWeeksLeft, forKey: .postRaceBluesWeeksLeft)
        try container.encode(postRaceBluesSeverity, forKey: .postRaceBluesSeverity)
        try container.encode(overtraining, forKey: .overtraining)
        try container.encode(currentTrainingBlock, forKey: .currentTrainingBlock)
        try container.encode(socialMediaFollowers, forKey: .socialMediaFollowers)
        try container.encode(contentQuality, forKey: .contentQuality)
        try container.encode(communityStanding, forKey: .communityStanding)
        try container.encode(secondWindUsed, forKey: .secondWindUsed)
        try container.encodeIfPresent(equippedShoeID, forKey: .equippedShoeID)
        try container.encodeIfPresent(equippedVestID, forKey: .equippedVestID)
        try container.encodeIfPresent(equippedPolesID, forKey: .equippedPolesID)
        try container.encode(dailyNutritionPlanID, forKey: .dailyNutritionPlanID)
        try container.encode(sponsorshipIDs, forKey: .sponsorshipIDs)
        try container.encode(gearClosetIDs, forKey: .gearClosetIDs)
        try container.encode(crewMemberIDs, forKey: .crewMemberIDs)
        try container.encode(pacerIDs, forKey: .pacerIDs)
        try container.encode(achievementIDs, forKey: .achievementIDs)
        try container.encodeIfPresent(coachID, forKey: .coachID)
        try container.encodeIfPresent(runClubID, forKey: .runClubID)
    }

    var archetype: Archetype {
        Archetype.get(ArchetypeKey(rawValue: archetypeKey) ?? .allRounder)
    }

    func addXP(_ amount: Double) {
        var bonus = amount
        if archetype.passive == .wisdomOfAge {
            bonus *= 1.2
        }
        xp += bonus
        checkLevelUp()
    }

    private func checkLevelUp() {
        let requiredXP = xpForNextLevel()
        if xp >= requiredXP {
            level += 1
            xp -= requiredXP
        }
    }

    func xpForNextLevel() -> Double {
        switch level {
        case 1...10: return 50
        case 11...20: return 100
        case 21...30: return 200
        case 31...40: return 400
        default: return 800
        }
    }
}
