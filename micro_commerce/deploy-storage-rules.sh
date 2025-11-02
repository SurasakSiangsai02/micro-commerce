#!/bin/bash

# 🔥 Firebase Storage Rules Deployment Script
# Quick deploy updated storage rules to fix authorization issues

echo "🔥 Deploying Firebase Storage Rules..."
echo "📅 Date: $(date)"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found!"
    echo "📥 Please install: npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "🔐 Please login to Firebase first:"
    echo "firebase login"
    exit 1
fi

# Deploy storage rules
echo "📤 Deploying storage rules..."
firebase deploy --only storage

if [ $? -eq 0 ]; then
    echo "✅ Firebase Storage Rules deployed successfully!"
    echo "🔧 New rules should be active within 1-2 minutes"
    echo ""
    echo "🧪 Next steps:"
    echo "1. Run the app: flutter run"
    echo "2. Try uploading an image in chat"
    echo "3. Check logs for Firebase test results"
else
    echo "❌ Deployment failed!"
    echo "💡 Please check:"
    echo "1. Firebase project is selected: firebase use <project-id>"
    echo "2. You have Storage admin permissions"
    echo "3. storage-rules.rules file exists"
fi

echo ""
echo "📋 Manual deployment alternative:"
echo "1. Go to https://console.firebase.google.com"
echo "2. Select your project → Storage → Rules"
echo "3. Copy rules from storage-rules.rules"
echo "4. Click Publish"