#!/usr/bin/env bash
set -e

# ==============================================================================
# Script to generate App Launcher Icons & Native Splash Screens for all flavors
# (Staging & Production) on Android and iOS.
#
# Usage:
#   ./scripts/generate_icons_and_splash.sh
# ==============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(dirname "$DIR")"
cd "$ROOT_DIR"

# Choose flutter / dart runner (fvm if available)
if command -v fvm &> /dev/null; then
  DART_CMD="fvm dart"
  FLUTTER_CMD="fvm flutter"
else
  DART_CMD="dart"
  FLUTTER_CMD="flutter"
fi

echo "============================================================"
echo "🚀 Generating App Launcher Icons & Native Splash Screens..."
echo "============================================================"

# Step 1: Generate Launcher Icons for PRD and STG
echo ""
echo "📱 [1/2] Generating Launcher Icons (flutter_launcher_icons)..."
echo "  -> Processing Production (PRD)..."
$DART_CMD run flutter_launcher_icons -f flutter_launcher_icons-prd.yaml

echo "  -> Processing Staging (STG)..."
$DART_CMD run flutter_launcher_icons -f flutter_launcher_icons-stg.yaml

# Step 2: Generate Native Splash Screens for PRD and STG
echo ""
echo "🎨 [2/2] Generating Native Splash Screen (flutter_native_splash)..."
echo "  -> Processing Production (PRD)..."
$DART_CMD run flutter_native_splash:create --path=flutter_native_splash-prd.yaml

echo "  -> Processing Staging (STG)..."
$DART_CMD run flutter_native_splash:create --path=flutter_native_splash-stg.yaml

echo ""
echo "============================================================"
echo "✅ Done! All launcher icons and splash screens generated!"
echo "============================================================"
