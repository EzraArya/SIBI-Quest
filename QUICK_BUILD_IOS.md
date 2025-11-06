# 🚀 Quick Build Guide - iOS IPA with TFLite Fix

## Problem Fixed
✅ TensorFlow Lite model now works in iOS release builds (was failing due to Bitcode)

## 🎬 Build Commands (Copy & Paste)

```bash
# 1. Clean everything
cd /Users/ezra/Developer/Skripoy/sibi_quest
flutter clean
flutter pub get

# 2. Build iOS release
flutter build ios --release
```

## 🏗️ Create IPA in Xcode

```
1. Open: ios/Runner.xcworkspace (in Xcode)
2. Select: Any iOS Device (arm64)
3. Product > Archive
4. Distribute App > Development/Ad Hoc
5. Export IPA
```

## 📱 Install on iPhone

**Quick Install:**
```bash
# Drag IPA to device in: 
# Xcode > Window > Devices and Simulators
```

## ✅ Verify It Works

**Open Xcode Console:**
```
Window > Devices and Simulators > [Your iPhone] > Console
Filter: "Classifier"
```

**Look for:**
```
🔧 Starting classifier initialization...
✅ GPU delegate created successfully
✅ Interpreter created with GPU
✅ Isolate interpreter created successfully
```

**Test gesture detection:**
- Launch app → Play screen
- Point camera at SIBI gesture
- Should detect with confidence score

## 🎯 Success = Green Checkmarks
- ✅ Initialization logs appear
- ✅ Gestures detected
- ✅ Confidence > 0.3
- ✅ No crashes

## ⚠️ Troubleshooting

**Model not working?**
→ Check `docs/ios_tflite_deployment_fix.md`

**Build errors?**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter build ios --release
```

---
**Status**: Ready to build! 🎉
