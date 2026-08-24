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

mkdir -p "$PROJECT/assets/press_trap"
cp "$ROOT/assets/press_trap/industrial-press.svg" "$PROJECT/assets/press_trap/industrial-press.svg"

mkdir -p "$PROJECT/assets/fire_trap"
cp "$ROOT/assets/fire_trap/flamethrower-v2.svg" "$PROJECT/assets/fire_trap/flamethrower-v2.svg"

mkdir -p "$PROJECT/assets/hammer_trap/remastered"
cp "$ROOT/assets/hammer_trap/mechanical-hammer-v2.svg" "$PROJECT/assets/hammer_trap/mechanical-hammer-v2.svg"
cp "$ROOT"/assets/hammer_trap/remastered/*.png "$PROJECT/assets/hammer_trap/remastered/"

mkdir -p "$PROJECT/assets/ui/fonts"
mkdir -p "$PROJECT/assets/ui/full_body/lifebuoy"
cp "$ROOT"/assets/ui/fonts/*.ttf "$PROJECT/assets/ui/fonts/"
cp "$ROOT/assets/ui/zoopaloola-splash.svg" "$PROJECT/assets/ui/zoopaloola-splash.svg"
cp "$ROOT/assets/ui/zoopaloola-home-bg-v3.webp" "$PROJECT/assets/ui/zoopaloola-home-bg-v3.webp"
cp "$ROOT/assets/ui/zoopaloola-loading-team-v1.webp" "$PROJECT/assets/ui/zoopaloola-loading-team-v1.webp"
cp "$ROOT/assets/ui/zoopaloola-logo-v1.webp" "$PROJECT/assets/ui/zoopaloola-logo-v1.webp"
cp "$ROOT/assets/ui/zoopaloola-boot-splash-v2.png" "$PROJECT/assets/ui/zoopaloola-boot-splash-v2.png"
cp "$ROOT"/assets/ui/full_body/*.webp "$PROJECT/assets/ui/full_body/"
cp "$ROOT"/assets/ui/full_body/lifebuoy/*.png "$PROJECT/assets/ui/full_body/lifebuoy/"

sed -i 's/config\/name="Zoopaloola Mobile Prototype"/config\/name="Zoopaloola"/' "$PROJECT/project.godot"
sed -i '/^config\/name="Zoopaloola"$/a boot_splash/image="res://assets/ui/zoopaloola-boot-splash-v2.png"\nboot_splash/fullsize=true\nboot_splash/bg_color=Color(0.0118, 0.0549, 0.102, 1)\nconfig/icon="res://assets/ui/zoopaloola-splash.svg"' "$PROJECT/project.godot"

if [[ "$ANDROID_FULLSCREEN" == "1" ]]; then
  # Start Android fullscreen before Godot draws the boot splash, not only
  # after the main scene or the game table has received a touch.
  sed -i '/^window\/size\/viewport_height=720$/a window/size/mode=3' "$PROJECT/project.godot"
fi
