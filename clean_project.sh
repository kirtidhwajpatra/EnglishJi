#!/bin/bash

echo "🧹 Cleaning Xcode Derived Data and Build Artifacts..."

# 1. Close Xcode (optional, but recommended)
# echo "Please ensure Xcode is closed for best results."

# 2. Delete Derived Data
rm -rf ~/Library/Developer/Xcode/DerivedData/EnglishJi-*
echo "✅ Deleted Derived Data for EnglishJi"

# 3. Delete Module Cache
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
echo "✅ Deleted Module Cache"

# 4. Clean Build Folder (xcodebuild)
xcodebuild -project EnglishJi.xcodeproj -scheme EnglishJi clean
echo "✅ Cleaned Build Folder"

echo "🚀 Done! Please re-open Xcode and wait for packages to resolve."
