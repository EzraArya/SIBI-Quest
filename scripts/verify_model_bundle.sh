#!/bin/bash

# TFLite Model Bundle Verification Script
# Checks if model is properly bundled in APK/IPA builds

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔍 TFLite Model Bundle Verification"
echo "===================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check Android APK
check_android() {
    echo "📱 Checking Android APK..."
    
    APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
    
    if [ ! -f "$APK_PATH" ]; then
        echo -e "${RED}❌ APK not found at: $APK_PATH${NC}"
        echo -e "${YELLOW}   Run: flutter build apk --release${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ APK found${NC}"
    echo ""
    
    # Check model file
    echo "🔍 Checking for model file..."
    if unzip -l "$APK_PATH" | grep -q "assets/flutter_assets/assets/models/sibi.tflite"; then
        echo -e "${GREEN}✅ Model file found in APK${NC}"
        
        # Check compression
        COMPRESSION=$(zipinfo "$APK_PATH" | grep "sibi.tflite" | awk '{print $4}')
        if [ "$COMPRESSION" = "stor" ]; then
            echo -e "${GREEN}✅ Model is stored uncompressed (noCompress working)${NC}"
        else
            echo -e "${YELLOW}⚠️  Model is compressed ($COMPRESSION)${NC}"
            echo -e "${YELLOW}   This may cause loading issues${NC}"
        fi
    else
        echo -e "${RED}❌ Model file NOT found in APK${NC}"
        return 1
    fi
    
    # Check labels file
    echo ""
    echo "🔍 Checking for labels file..."
    if unzip -l "$APK_PATH" | grep -q "assets/flutter_assets/assets/models/labels.txt"; then
        echo -e "${GREEN}✅ Labels file found in APK${NC}"
    else
        echo -e "${RED}❌ Labels file NOT found in APK${NC}"
        return 1
    fi
    
    # Check TFLite native libraries
    echo ""
    echo "🔍 Checking for TFLite native libraries..."
    if unzip -l "$APK_PATH" | grep -q "lib/.*/libtensorflowlite"; then
        echo -e "${GREEN}✅ TFLite native libraries found${NC}"
        unzip -l "$APK_PATH" | grep "libtensorflowlite" | head -3
    else
        echo -e "${YELLOW}⚠️  TFLite native libraries not found (may use system libs)${NC}"
    fi
    
    # APK size
    echo ""
    APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
    echo "📦 APK Size: $APK_SIZE"
    
    return 0
}

# Function to check iOS IPA
check_ios() {
    echo ""
    echo "🍎 Checking iOS IPA..."
    
    # Try common IPA paths
    IPA_PATH=""
    POSSIBLE_PATHS=(
        "$PROJECT_ROOT/build/ios/ipa/sibi_quest.ipa"
        "$PROJECT_ROOT/build/ios/ipa/Runner.ipa"
        "$PROJECT_ROOT/Runner.ipa"
    )
    
    for path in "${POSSIBLE_PATHS[@]}"; do
        if [ -f "$path" ]; then
            IPA_PATH="$path"
            break
        fi
    done
    
    if [ -z "$IPA_PATH" ]; then
        echo -e "${YELLOW}⚠️  IPA not found. Tried:${NC}"
        for path in "${POSSIBLE_PATHS[@]}"; do
            echo "   - $path"
        done
        echo ""
        echo -e "${YELLOW}   To build IPA:${NC}"
        echo "   1. flutter build ios --release"
        echo "   2. Open ios/Runner.xcworkspace in Xcode"
        echo "   3. Product > Archive"
        echo "   4. Export IPA"
        return 1
    fi
    
    echo -e "${GREEN}✅ IPA found at: $IPA_PATH${NC}"
    echo ""
    
    # Check model file
    echo "🔍 Checking for model file in IPA..."
    if unzip -l "$IPA_PATH" | grep -q "flutter_assets/assets/models/sibi.tflite"; then
        echo -e "${GREEN}✅ Model file found in IPA${NC}"
        
        # Show the exact path
        echo ""
        echo "📍 Model location:"
        unzip -l "$IPA_PATH" | grep "sibi.tflite"
    else
        echo -e "${RED}❌ Model file NOT found in IPA${NC}"
        echo ""
        echo "Searching for any .tflite files..."
        unzip -l "$IPA_PATH" | grep ".tflite" || echo "   No .tflite files found"
        return 1
    fi
    
    # Check labels file
    echo ""
    echo "🔍 Checking for labels file..."
    if unzip -l "$IPA_PATH" | grep -q "flutter_assets/assets/models/labels.txt"; then
        echo -e "${GREEN}✅ Labels file found in IPA${NC}"
    else
        echo -e "${RED}❌ Labels file NOT found in IPA${NC}"
        return 1
    fi
    
    # IPA size
    echo ""
    IPA_SIZE=$(ls -lh "$IPA_PATH" | awk '{print $5}')
    echo "📦 IPA Size: $IPA_SIZE"
    
    return 0
}

# Main execution
ANDROID_OK=0
IOS_OK=0

check_android || ANDROID_OK=$?
check_ios || IOS_OK=$?

echo ""
echo "===================================="
echo "📊 Summary"
echo "===================================="

if [ $ANDROID_OK -eq 0 ]; then
    echo -e "${GREEN}✅ Android APK: PASS${NC}"
else
    echo -e "${RED}❌ Android APK: FAIL${NC}"
fi

if [ $IOS_OK -eq 0 ]; then
    echo -e "${GREEN}✅ iOS IPA: PASS${NC}"
else
    echo -e "${YELLOW}⚠️  iOS IPA: Not checked (build required)${NC}"
fi

echo ""

if [ $ANDROID_OK -eq 0 ] && [ $IOS_OK -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed!${NC}"
    exit 0
elif [ $ANDROID_OK -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Android OK, iOS needs verification${NC}"
    exit 0
else
    echo -e "${RED}❌ Issues found. Review output above.${NC}"
    exit 1
fi
