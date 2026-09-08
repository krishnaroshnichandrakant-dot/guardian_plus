#!/usr/bin/env bash
set -e

echo "🚀 Starting Netlify Automated Build for Guardian Plus..."

# Install Flutter SDK if not pre-installed on build machine
if [ ! -d "flutter" ]; then
  echo "📥 Cloning Flutter Stable SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:`pwd`/flutter/bin"

echo "🔍 Flutter Version:"
flutter --version

echo "📦 Fetching Dependencies..."
flutter pub get

echo "🛠️ Compiling Web Release Bundle..."
flutter build web --release --no-pub

echo "✅ Netlify Build Complete! Ready to serve build/web."
