# ULTRA MANAGER - Quick Start Guide

## Step-by-Step Setup (5 minutes)

### 1. Open Xcode and Create New Project

```bash
# Launch Xcode 15+
```

1. **File → New → Project**
2. Choose **iOS → App**
3. Click **Next**

### 2. Configure Project Settings

- **Product Name**: `UltraManager`
- **Team**: Select your Apple Developer team
- **Organization Identifier**: `com.yourname` (or your identifier)
- **Interface**: **SwiftUI** ✅
- **Storage**: **SwiftData** ✅
- **Language**: **Swift** ✅
- **Include Tests**: Optional

Click **Next**, choose save location (e.g., Desktop), click **Create**

### 3. Import Source Files

Xcode created a default project structure. Now replace it with ULTRA MANAGER:

1. **Delete default files** from the project navigator:
   - Right-click `ContentView.swift` → Delete → Move to Trash
   - Right-click `UltraManagerApp.swift` → Delete → Move to Trash
   - Right-click `Item.swift` (if exists) → Delete → Move to Trash

2. **Add ULTRA MANAGER source files**:
   - Locate the `UltraManager` folder you have (with all the .swift files)
   - Drag the **entire UltraManager folder** into Xcode's project navigator
   - In the dialog:
     - ✅ **Copy items if needed**
     - ✅ **Create groups** (not folder references)
     - ✅ **Add to targets: UltraManager**
   - Click **Finish**

### 4. Configure Build Settings

1. Select **UltraManager** target in project navigator
2. Go to **Signing & Capabilities** tab
3. Ensure **Team** is selected
4. **Bundle Identifier** should auto-populate: `com.yourname.UltraManager`

### 5. Set Deployment Target

1. Still in project settings, **General** tab
2. **Minimum Deployments**: Set to **iOS 17.0**

### 6. Build & Run

1. Select simulator: **iPhone 15 Pro** (or any iOS 17+ device)
2. Press **⌘R** (or Product → Run)
3. Wait for build... (~30 seconds first time)
4. **Game launches!** 🎮

---

## Expected First Run

1. **Welcome Screen** appears with "START CAREER" button
2. Tap **START CAREER**
3. **Runner Creation** screen:
   - Enter your name
   - Select gender
   - Choose archetype (read the backstories!)
4. Tap **BEGIN JOURNEY**
5. **Main Hub** loads with 4 tabs:
   - Dashboard: View stats
   - Training: Select weekly training
   - Races: Browse race calendar
   - Career: View attributes

---

## First Play Session (10 minutes)

### Week 1: Train
1. Go to **Training** tab
2. Select **3 training sessions**:
   - Try "Long Run" (endurance builder)
   - Try "Strength & Gym" (durability)
   - Try "Easy / Recovery Run" (low fatigue)
3. Tap **ADVANCE WEEK**
4. Confirm
5. Check **Dashboard** → Recent Events to see stat gains

### Week 2-3: More Training
- Try different training types
- Watch **Fatigue** accumulate (Dashboard)
- Watch **Fitness** increase
- See **Form** stay balanced (should be around 0-5)

### Week 4: Enter First Race
1. Go to **Races** tab
2. Tap **Pine Ridge 50K** (the only race you qualify for initially)
3. Race screen loads with:
   - Energy, Hydration, Morale, Muscle Damage meters
   - Mile progress
   - Current placement
4. Read the **narrative** (e.g., "Finally, some runnable trail...")
5. Choose a **tactical decision**:
   - Green star = optimal choice for your stats
   - Orange = challenging
6. Watch the **outcome** narrative
7. Continue through 8-10 segments
8. **Finish!** (or DNF if you make risky choices)
9. View **results**: placement, prestige gained, XP, prize money

### Week 5+: Build Your Career
- **Train** to improve stats
- **Enter more races** as you unlock them (need higher Prestige)
- **Manage fatigue** - if it gets too high, rest!
- **Avoid injuries** - train smart, don't overtrain
- **Watch your attributes grow**

---

## Troubleshooting

### Build Errors

**"Cannot find type 'Runner' in scope"**
- Solution: Make sure all files in `Models/Core/` were imported
- Check project navigator: Models folder should have subfolders

**"Type 'Runner' does not conform to protocol 'Codable'"**
- Solution: This is a SwiftData issue. Try:
  1. Clean build folder: Product → Clean Build Folder (⌘⇧K)
  2. Rebuild: ⌘B

**"No such module 'SwiftData'"**
- Solution: Deployment target too low
  - Project settings → General → Minimum Deployments → iOS 17.0

### Runtime Errors

**App crashes on launch**
- Check Console output in Xcode
- Most likely: SwiftData persistence issue
- Solution: Delete app from simulator, rebuild

**Race doesn't start / No segments appear**
- RaceSegmentGenerator might have failed
- Check Console for errors

**Stats not updating after training**
- GameEngine might not be wired correctly
- Verify `GameEngine` is initialized in `MainHubView`

---

## File Structure Quick Reference

```
UltraManager/
├── Models/
│   ├── Core/              # Runner, Attributes, Stats, Injury, Nutrition
│   ├── Race/              # Race catalog, segments, state machine
│   ├── Training/          # Training types
│   ├── Gear/              # Shoes, vests, poles
│   └── Sponsorship/       # Brands, contracts
├── Services/
│   └── GameEngine.swift   # Week advancement logic
├── Views/
│   ├── Home/              # Dashboard, Training, Runner Creation
│   ├── Race/              # Calendar, Execution
│   └── Career/            # Stats view
├── ContentView.swift      # Root
└── UltraManagerApp.swift  # Entry point
```

---

## Key Gameplay Tips

1. **Start with Long Runs** - Endurance is king in ultras
2. **Don't overtrain** - Keep fatigue under 70
3. **Rest weeks matter** - Schedule rest every 3-4 weeks
4. **Train for your race** - Vert training before mountain races
5. **In races, play to your strengths** - If climbing is 8+, choose power hike
6. **Injuries happen** - It's part of the game. Recover fully.
7. **Form (TSB) is critical** - Race when form is +10 to +15
8. **Age matters** - Train hard in your 20s, stats decline after 35

---

## Next Steps

After playing the MVP:
- Read the **full README.md** for game system details
- Explore all 8 archetypes
- Try to finish Sierra Crest 100 (the Western States analog)
- Experiment with nutrition plans
- Get injured and experience the recovery system
- Try to trigger post-race blues (DNF a big race)

---

## Known Limitations (MVP)

This is a full MVP but missing some planned features:
- ❌ AI rival runners (no competition)
- ❌ Global rankings (just prestige tracking)
- ❌ Sponsorship offers (models exist, no UI)
- ❌ Crew & pacers (models exist, not used in races)
- ❌ Achievements (system designed, not implemented)
- ❌ Team camps / group runs (models exist, no events)

These are all designed and ready to implement - just not in the initial build.

---

## Performance Notes

- **First race might lag** during segment generation (procedural)
- **Subsequent races smooth** (caching works)
- **Simulator performance** is fine, device is smoother
- **Memory usage** low (~50MB) - efficient design

---

## Support

Questions? Issues?
- Check the **full README.md** for detailed game system explanations
- Review the **original design spec** (included) for intended behavior
- File issues or questions with the AI that built this

---

**You're ready to run! Good luck building your ultrarunning career.**

**From first 50K to UTMB. From couch to Western States. Your journey begins now.**

🏃💨
