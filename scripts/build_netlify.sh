#!/usr/bin/env bash
set -e

echo "🚀 Starting Netlify Automated Build for Guardian Plus..."

# Fast download of pre-compiled Flutter Linux SDK
if [ ! -d "flutter" ]; then
  echo "📥 Downloading Flutter Linux SDK..."
  curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.0-stable.tar.xz -o flutter.tar.xz
  tar -xf flutter.tar.xz
  rm flutter.tar.xz
fi

export PATH="$PATH:`pwd`/flutter/bin"
export PUB_CACHE="`pwd`/.pub_cache"

echo "🔍 Flutter Version:"
flutter --version
flutter config --no-analytics

echo "📦 Fetching Dependencies..."
flutter pub get

echo "🛠️ Compiling Web Release Bundle..."
flutter build web --release --no-pub

echo "✅ Netlify Build Complete! Ready to serve build/web."

