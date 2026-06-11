# Hexa Match - Premium Hexagonal 3-in-a-Row Puzzle

A gorgeous, highly polished vertical puzzle game built with Flutter. Tap, swap, and match glassy, volumetric spheres in a 3D-esque neon hexagonal coordinate space.

[![Deploy to GitHub Pages](https://github.com/Dmitriy-ateo/VCG_ThreeInARow/actions/workflows/deploy.yml/badge.svg)](https://github.com/Dmitriy-ateo/VCG_ThreeInARow/actions/workflows/deploy.yml)

## 🎮 Play Online
Play the web release instantly on GitHub Pages:
👉 **[Play Hexa Match Live](https://Dmitriy-ateo.github.io/VCG_ThreeInARow/)**

---

## ✨ Features

- **Hexagonal Geometry**: Full pointy-topped cube coordinates `(q, r, s)` handling matches along three diagonal axes.
- **Vibrant Neon Aesthetics**: Glassmorphism, deep shadows, glow-layered cell grids, and volumetric 3D-specular neon balls.
- **Multiple Board Layouts**: Custom level-based geometry shapes:
  - Hexagon, Donut, Triangle, Parallelogram, Star, Hourglass, Butterfly, Heart, and a custom **"V" Shape** for VibeGaming.
- **Tactical Queue Swapping**: Tap secondary upcoming balls in the interactive queue to swap them with your active item.
- **Daily Event Challenge**: Seeded RNG based on the calendar date (Year-Month-Day), giving players worldwide the same layout each day.
- **Local Progress Persistence**: Stores level progression, high score, and daily challenge stats using `SharedPreferences`.
- **High Performance Rendering**: Optimized with background repaint boundaries and rebuild-decoupled widget architectures.

---

## 🛠️ GitHub Pages Deployment

This project automates web builds and deployments using GitHub Actions.

Every push to the `main` branch triggers the deploy workflow:
1. Compiles the Flutter web application with `--base-href "/VCG_ThreeInARow/"`.
2. Deploys the static web assets to the `gh-pages` branch.
3. Automatically updates your live game page.

### Activation Instructions (One-time Setup):
1. Go to your GitHub repository: **Settings** -> **Pages**.
2. Under **Build and deployment** -> **Source**, select **Deploy from a branch**.
3. Set **Branch** to `gh-pages` and folder to `/ (root)`.
4. Click **Save**.

---

## 🚀 Getting Started Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
- Dart SDK

### Running the App
```bash
# Get dependencies
flutter pub get

# Run on web or target device
flutter run -d chrome
```

### Building the Release
```bash
flutter build web --base-href "/VCG_ThreeInARow/"
```
