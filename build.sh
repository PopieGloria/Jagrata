#!/bin/bash

echo "Cloning Flutter stable branch..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

echo "Adding Flutter to PATH..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "Checking Flutter version..."
flutter --version

echo "Configuring Flutter for web..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Building Flutter web app..."
flutter build web --release

echo "Build complete."
