# GitHub Build Guide for iOS

## ⚠️ **IMPORTANT: The Core Problem**

**GitHub Actions CAN build iOS apps, BUT you still need:**

1. ✅ **Apple Developer Account** ($99/year)
2. ✅ **Proper Xcode project file** (needs a Mac to create)
3. ✅ **Code signing certificates** (needs a Mac to generate)
4. ✅ **Provisioning profiles** (needs a Mac to create)

**Bottom line: You need 30 minutes on a Mac for initial setup, then GitHub can handle future builds.**

---

## 🎯 **Three Realistic Options**

### Option 1: Use Expo / React Native (No Mac Needed!)

**Switch to cross-platform framework:**
- ❌ **Con**: Would need to rewrite the entire game in JavaScript/TypeScript
- ❌ **Con**: Lose SwiftUI's native iOS feel
- ✅ **Pro**: Can build iOS apps from Windows via Expo's cloud build service
- ⏱️ **Time**: 2-3 weeks to port the game

**Not recommended** - you already have a complete Swift app!

---

### Option 2: Codemagic CI/CD (Easiest!)

**Codemagic is like GitHub Actions but handles iOS complexity:**

#### Setup (From Windows):
```bash
# 1. Sign up at codemagic.io
# - Free tier: 500 build minutes/month
# - Supports TestFlight deployment

# 2. Connect your GitHub repo
# - Authorize Codemagic to access github.com/rirr-droid/ultramanager

# 3. Configure build (in Codemagic dashboard)
# - Platform: iOS
# - Framework: SwiftUI
# - Xcode version: 15.0

# 4. Add Apple credentials
# - App Store Connect API Key (generate in App Store Connect)
# - Code signing identity (Codemagic can generate!)
# - Provisioning profile (Codemagic can generate!)

# 5. Trigger build
# - Push to GitHub → Codemagic builds automatically
# - Uploads to TestFlight
# - Install on iPhone via TestFlight app
```

**⚠️ Still requires:**
- Apple Developer account ($99/year)
- Proper Xcode project (needs Mac for 30 min setup)

---

### Option 3: GitHub Actions (After Mac Setup)

Once you've used a Mac to create the proper project:

#### What GitHub Actions Can Do:
✅ Build the app on every commit
✅ Run automated tests
✅ Create IPA file (iOS app package)
✅ Upload to TestFlight
✅ Notify you when build completes

#### What You Must Do on a Mac First:
```bash
# 1. Create proper Xcode project
- Open Xcode
- File → New → Project
- Import all Swift files
- Configure signing

# 2. Generate certificates
- Xcode → Preferences → Accounts
- Manage Certificates
- Create iOS Distribution Certificate

# 3. Create provisioning profile
- developer.apple.com
- Certificates, IDs & Profiles
- Create App ID: com.rirrdroid.ultramanager
- Create Provisioning Profile (App Store Distribution)

# 4. Export and add to GitHub Secrets
- Export p12 certificate
- Upload to GitHub: Settings → Secrets → Actions
- Add: CERTIFICATE_P12, CERTIFICATE_PASSWORD, PROVISIONING_PROFILE

# 5. Commit real .xcodeproj to GitHub
git add UltraManager.xcodeproj/
git commit -m "Add proper Xcode project"
git push
```

---

## 🚀 **The Realistic Path Forward**

### Phase 1: One-Time Mac Setup (30 minutes)
**Find a Mac** (Apple Store, friend, library):

```bash
# 1. Clone your repo
git clone https://github.com/rirr-droid/ultramanager.git
cd ultramanager

# 2. Create Xcode project
open Xcode
# File → New → Project → iOS App
# Name: UltraManager
# Team: Your Apple Developer team
# Bundle ID: com.rirrdroid.ultramanager

# 3. Import Swift files
# Drag UltraManager/ folder into project
# Check "Copy items if needed"

# 4. Build locally
# Product → Run
# Test on your iPhone

# 5. Commit project to GitHub
git add .
git commit -m "Add proper Xcode project with signing"
git push
```

### Phase 2: Enable GitHub Actions
**After Phase 1, from Windows:**

```bash
# 1. Add certificates to GitHub Secrets
# (exported from Mac in Phase 1)

# 2. Enable workflow
# GitHub repo → Actions → Enable

# 3. Push code changes
git push

# 4. GitHub builds automatically
# Uploads to TestFlight

# 5. Install on iPhone
# Open TestFlight app on iPhone
# Install "UltraManager"
```

---

## 💡 **Alternative: Skip GitHub Builds Entirely**

### Simplest approach:
1. **One Mac visit** (30 min)
2. **Build directly to your iPhone**
3. **App stays on phone for 7 days** (free) or **1 year** ($99 account)
4. **Rebuild when needed** (another Mac visit)

**For a single-player game you're building for yourself, this is often enough!**

---

## 🎯 **What I Recommend**

### For Right Now:
1. **Find a Mac this week** (Apple Store, friend, library)
2. **30 minutes setup** following Phase 1 above
3. **Build to your iPhone directly**
4. **Play the game!**

### For Later (If You Love It):
1. **Buy a Mac Mini M2** ($599)
2. **Set up GitHub Actions** for automated builds
3. **Publish to TestFlight** for beta testing
4. **Eventually publish to App Store** ($99/year)

---

## ❌ **What Doesn't Work**

### Things people suggest that won't work for iOS:
- ❌ **Build on Windows** - Xcode only runs on macOS
- ❌ **Hackintosh** - Requires specific hardware, unreliable
- ❌ **Online Swift Playgrounds** - Can't build full iOS apps
- ❌ **Swift for Windows** - Only for command-line tools, not iOS apps
- ❌ **Xamarin/Flutter ports** - Would need to rewrite entire game

---

## 📱 **TestFlight Installation (After Build)**

Once the app is built and uploaded to TestFlight:

### On Your iPhone:
```
1. Download TestFlight app from App Store
2. Open email invitation from Apple
3. Tap "View in TestFlight"
4. Tap "Install"
5. Launch ULTRA MANAGER
6. Play!
```

### TestFlight Benefits:
- ✅ Install on up to 10,000 test devices
- ✅ Apps last 90 days (auto-expire)
- ✅ New builds push automatically
- ✅ Crash reports and analytics
- ✅ Beta feedback collection

---

## 🎮 **Codemagic Setup (Step-by-Step)**

If you want to try Codemagic (easiest CI/CD for iOS):

### 1. Sign Up
```
Go to: https://codemagic.io
Sign up with GitHub account
Free tier: 500 build minutes/month
```

### 2. Add Your App
```
Dashboard → Add Application
Select: github.com/rirr-droid/ultramanager
```

### 3. Configure Workflow
```yaml
# codemagic.yaml (create in repo root)
workflows:
  ios-workflow:
    name: iOS Build
    max_build_duration: 60
    environment:
      xcode: 15.0
      groups:
        - app_store_credentials
    scripts:
      - name: Install dependencies
        script: |
          echo "No dependencies needed"
      - name: Build iOS app
        script: |
          xcodebuild -workspace UltraManager.xcworkspace \
            -scheme UltraManager \
            -configuration Release \
            -archivePath build/UltraManager.xcarchive \
            archive
      - name: Export IPA
        script: |
          xcodebuild -exportArchive \
            -archivePath build/UltraManager.xcarchive \
            -exportPath build \
            -exportOptionsPlist ExportOptions.plist
    artifacts:
      - build/*.ipa
    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_API_KEY
        submit_to_testflight: true
```

### 4. Add Credentials
```
Codemagic Dashboard → Team Settings → App Store Connect
- Add API Key from App Store Connect
- Add Code Signing Certificate
- Add Provisioning Profile
```

### 5. Trigger Build
```bash
git push  # Builds automatically
```

**⚠️ Still needs proper Xcode project from Mac!**

---

## 📋 **Quick Decision Matrix**

| Approach | Mac Needed? | Cost | Time to Play |
|----------|-------------|------|--------------|
| **Mac Visit** | ✅ Once (30 min) | Free* | 30 minutes |
| **Mac Visit + GitHub Actions** | ✅ Once (30 min) | $99/year | 30 min + setup |
| **Codemagic** | ✅ Once (30 min) | $99/year + $20/mo** | 30 min + setup |
| **Buy Mac Mini** | ❌ Never again | $599 one-time | As soon as it arrives |

\* Free for 7 days per build, $99/year for longer
\** Codemagic free tier may be enough (500 min/mo)

---

## 🎯 **My Recommendation**

**This weekend**:
1. Go to Apple Store
2. 30 minutes at display Mac
3. Build to your iPhone
4. Play for 7 days

**If you love the game**:
1. Pay $99 for Apple Developer account
2. Rebuild (app lasts 1 year)

**If you want to keep developing**:
1. Buy Mac Mini M2 ($599)
2. Develop freely
3. Set up CI/CD later if needed

---

## ❓ **Still Have Questions?**

- **"Can I really not build iOS apps on Windows?"** - Correct, not possible without a Mac somewhere in the chain
- **"What about cloud Macs?"** - Yes! MacStadium, MacinCloud ($20-30/mo)
- **"Can I test in browser?"** - No, iOS simulator only on macOS
- **"How long does Mac setup take?"** - 30 minutes for someone experienced helping you

---

**Bottom line: You need a Mac for 30 minutes. After that, you can optionally use GitHub/Codemagic for automated builds, but the simplest path is just building directly on that Mac to your iPhone.**

Ready to find a Mac? I can create a detailed printable checklist for your visit!
