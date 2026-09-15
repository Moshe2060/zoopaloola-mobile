#!/usr/bin/env bash
# Overlay the live landscape game files onto the extracted Godot project.
# Used by both the Web and Android GitHub Actions workflows.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/zoopaloola_godot_mobile"
ANDROID_FULLSCREEN=0

for arg in "$@"; do
  if [[ "$arg" == "--android" ]]; then
    ANDROID_FULLSCREEN=1
  fi
done

if [[ ! -d "$PROJECT" ]]; then
  echo "Expected extracted Godot project at $PROJECT" >&2
  exit 1
fi

cp "$ROOT/mobile-v02.gd" "$PROJECT/scripts/main.gd"
cp "$ROOT/board-clean-modular.webp" "$PROJECT/assets/board-clean-modular.webp"
mkdir -p "$PROJECT/assets/boards"
cp "$ROOT/assets/boards/board-purple-v1.webp" "$PROJECT/assets/boards/board-purple-v1.webp"
cp "$ROOT/assets/boards/board-vortex-v1.webp" "$PROJECT/assets/boards/board-vortex-v1.webp"
cp "$ROOT/assets/boards/board-vortex-v2.webp" "$PROJECT/assets/boards/board-vortex-v2.webp"
cp "$ROOT/assets/boards/board-ice.webp" "$PROJECT/assets/boards/board-ice.webp"
cp "$ROOT/assets/boards/board-jungle.webp" "$PROJECT/assets/boards/board-jungle.webp"
cp "$ROOT/assets/boards/board-lava.webp" "$PROJECT/assets/boards/board-lava.webp"
cp "$ROOT/assets/boards/board-candy.webp" "$PROJECT/assets/boards/board-candy.webp"

mkdir -p "$PROJECT/assets/remastered_effects"
cp "$ROOT"/effect-*.png "$PROJECT/assets/remastered_effects/"

mkdir -p "$PROJECT/assets/animal_pieces"
cp "$ROOT"/animal_pieces/*.png "$PROJECT/assets/animal_pieces/"

mkdir -p "$PROJECT/assets/rubber_trap/hands"
mkdir -p "$PROJECT/assets/rubber_launcher"
cp "$ROOT/rubber_launcher/launcher.svg" "$PROJECT/assets/rubber_launcher/launcher.svg"
cp "$ROOT/rubber_launcher/wrap-sequence.svg" "$PROJECT/assets/rubber_launcher/wrap-sequence.svg"
cp "$ROOT/rubber_trap/rubber-ball.png" "$PROJECT/assets/rubber_trap/"
cp "$ROOT"/rubber_trap/hands/pose-*.png "$PROJECT/assets/rubber_trap/hands/"

mkdir -p "$PROJECT/assets/abyss_bloom"
cp "$ROOT/assets/abyss_bloom/abyss-bloom.png" "$PROJECT/assets/abyss_bloom/abyss-bloom.png"
cp "$ROOT/assets/abyss_bloom/abyss-bloom-clean-v3.webp" "$PROJECT/assets/abyss_bloom/abyss-bloom-clean-v3.webp"

mkdir -p "$PROJECT/assets/gravity_trap"
cp "$ROOT/assets/gravity_trap/gravity-base-v1.webp" "$PROJECT/assets/gravity_trap/gravity-base-v1.webp"
cp "$ROOT/assets/gravity_trap/gravity-head-v1.webp" "$PROJECT/assets/gravity_trap/gravity-head-v1.webp"

mkdir -p "$PROJECT/assets/press_trap"
cp "$ROOT/assets/press_trap/industrial-press.svg" "$PROJECT/assets/press_trap/industrial-press.svg"

mkdir -p "$PROJECT/assets/fire_trap"
cp "$ROOT/assets/fire_trap/flamethrower-v2.svg" "$PROJECT/assets/fire_trap/flamethrower-v2.svg"

mkdir -p "$PROJECT/assets/hammer_trap/remastered"
cp "$ROOT/assets/hammer_trap/mechanical-hammer-v2.svg" "$PROJECT/assets/hammer_trap/mechanical-hammer-v2.svg"
cp "$ROOT"/assets/hammer_trap/remastered/*.png "$PROJECT/assets/hammer_trap/remastered/"

mkdir -p "$PROJECT/assets/ui/fonts"
mkdir -p "$PROJECT/assets/ui/full_body/lifebuoy"
mkdir -p "$PROJECT/assets/ui/screens"
mkdir -p "$PROJECT/assets/ui/character_portraits"
mkdir -p "$PROJECT/assets/ui/character_ships"
mkdir -p "$PROJECT/assets/ui/character_ships/light_masks"
mkdir -p "$PROJECT/assets/ui/battle_pieces"
mkdir -p "$PROJECT/assets/ui/ships"
cp "$ROOT"/assets/ui/fonts/*.ttf "$PROJECT/assets/ui/fonts/"
cp "$ROOT/assets/ui/zoopaloola-splash.svg" "$PROJECT/assets/ui/zoopaloola-splash.svg"
cp "$ROOT/assets/ui/zoopaloola-home-bg-v3.webp" "$PROJECT/assets/ui/zoopaloola-home-bg-v3.webp"
cp "$ROOT/assets/ui/battle-sky-bg-v1.webp" "$PROJECT/assets/ui/battle-sky-bg-v1.webp"
cp "$ROOT/assets/ui/battle-gates-home-v1.webp" "$PROJECT/assets/ui/battle-gates-home-v1.webp"
cp "$ROOT/assets/ui/battle-gates-home-clean-v2.webp" "$PROJECT/assets/ui/battle-gates-home-clean-v2.webp"
cp "$ROOT/assets/ui/zoovortex-loading-v2.webp" "$PROJECT/assets/ui/zoovortex-loading-v2.webp"
cp "$ROOT/assets/ui/zoovortex-logo-v1.webp" "$PROJECT/assets/ui/zoovortex-logo-v1.webp"
cp "$ROOT/assets/ui/zoovortex-boot-splash-v3.png" "$PROJECT/assets/ui/zoovortex-boot-splash-v3.png"
cp "$ROOT/assets/ui/zoovortex-app-icon-v1.jpg" "$PROJECT/assets/ui/zoovortex-app-icon-v1.jpg"
cp "$ROOT"/assets/ui/screens/*.webp "$PROJECT/assets/ui/screens/"
cp "$ROOT"/assets/ui/character_portraits/*.png "$PROJECT/assets/ui/character_portraits/"
cp "$ROOT"/assets/ui/character_ships/*.png "$PROJECT/assets/ui/character_ships/"
cp "$ROOT"/assets/ui/character_ships/light_masks/*.png "$PROJECT/assets/ui/character_ships/light_masks/"
cp "$ROOT"/assets/ui/battle_pieces/*.png "$PROJECT/assets/ui/battle_pieces/"
cp "$ROOT"/assets/ui/ships/*.png "$PROJECT/assets/ui/ships/"
cp "$ROOT"/assets/ui/full_body/*.webp "$PROJECT/assets/ui/full_body/"
cp "$ROOT"/assets/ui/full_body/lifebuoy/*.png "$PROJECT/assets/ui/full_body/lifebuoy/"

sed -i -E 's/^config\/name=.*/config\/name="ZOOVORTEX"/' "$PROJECT/project.godot"
if grep -q '^boot_splash/image=' "$PROJECT/project.godot"; then
  sed -i -E 's#^boot_splash/image=.*#boot_splash/image="res://assets/ui/zoovortex-boot-splash-v3.png"#' "$PROJECT/project.godot"
else
  sed -i '/^config\/name=/a boot_splash/image="res://assets/ui/zoovortex-boot-splash-v3.png"' "$PROJECT/project.godot"
fi
if grep -q '^boot_splash/fullsize=' "$PROJECT/project.godot"; then
  sed -i -E 's/^boot_splash\/fullsize=.*/boot_splash\/fullsize=true/' "$PROJECT/project.godot"
else
  sed -i '/^boot_splash\/image=/a boot_splash/fullsize=true' "$PROJECT/project.godot"
fi
if grep -q '^boot_splash/show_image=' "$PROJECT/project.godot"; then
  sed -i -E 's/^boot_splash\/show_image=.*/boot_splash\/show_image=true/' "$PROJECT/project.godot"
else
  sed -i '/^boot_splash\/fullsize=/a boot_splash/show_image=true' "$PROJECT/project.godot"
fi
if grep -q '^config/icon=' "$PROJECT/project.godot"; then
  sed -i -E 's#^config/icon=.*#config/icon="res://assets/ui/zoovortex-app-icon-v1.jpg"#' "$PROJECT/project.godot"
else
  sed -i '/^boot_splash\/show_image=/a config/icon="res://assets/ui/zoovortex-app-icon-v1.jpg"' "$PROJECT/project.godot"
fi
sed -i -E 's/^package\/name=.*/package\/name="ZOOVORTEX"/' "$PROJECT/export_presets.cfg"

if [[ "$ANDROID_FULLSCREEN" == "1" ]]; then
  # Start Android fullscreen before Godot draws the boot splash, not only
  # after the main scene or the game table has received a touch.
  sed -i '/^window\/size\/viewport_height=720$/a window/size/mode=3' "$PROJECT/project.godot"

  # HTTPRequest and Firebase authentication need Android's INTERNET manifest
  # permission. The original prototype preset omitted it, so native builds
  # reported "Cloud offline" even while the phone itself was online.
  if grep -q '^permissions/internet=' "$PROJECT/export_presets.cfg"; then
    sed -i 's/^permissions\/internet=.*/permissions\/internet=true/' "$PROJECT/export_presets.cfg"
  else
    sed -i '/^permissions\/custom_permissions=/i permissions/internet=true' "$PROJECT/export_presets.cfg"
  fi
fi
