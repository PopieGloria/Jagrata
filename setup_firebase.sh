#!/bin/bash

# Firebase Setup Script for Jagrata App
echo "🔥 Setting up Firebase configuration files..."

# Check if template files exist
if [ ! -f "lib/firebase_options.template.dart" ]; then
    echo "❌ Template files not found. Please ensure you're in the project root directory."
    exit 1
fi

# Create Firebase configuration files from templates
echo "📝 Creating Firebase configuration files from templates..."

# Copy web configuration
if [ ! -f "lib/firebase_options_web.dart" ]; then
    cp lib/firebase_options_web.template.dart lib/firebase_options_web.dart
    echo "✅ Created lib/firebase_options_web.dart"
else
    echo "⚠️  lib/firebase_options_web.dart already exists, skipping..."
fi

# Copy iOS configuration  
if [ ! -f "lib/firebase_options_ios.dart" ]; then
    cp lib/firebase_options_ios.template.dart lib/firebase_options_ios.dart
    echo "✅ Created lib/firebase_options_ios.dart"
else
    echo "⚠️  lib/firebase_options_ios.dart already exists, skipping..."
fi

# Copy main configuration
if [ ! -f "lib/firebase_options.dart" ]; then
    cp lib/firebase_options.template.dart lib/firebase_options.dart
    echo "✅ Created lib/firebase_options.dart"
else
    echo "⚠️  lib/firebase_options.dart already exists, skipping..."
fi

echo ""
echo "🎉 Firebase configuration files created successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Replace placeholder values in the created files with your actual Firebase configuration"
echo "2. Download google-services.json and place it in android/app/"
echo "3. Download GoogleService-Info.plist and place it in ios/Runner/"
echo "4. Run 'flutter clean && flutter pub get'"
echo ""
echo "📖 For detailed instructions, see FIREBASE_SETUP.md" 