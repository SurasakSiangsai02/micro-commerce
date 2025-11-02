@echo off
REM 🔥 Firebase Storage Rules Deployment Script (Windows)
REM Quick deploy updated storage rules to fix authorization issues

echo 🔥 Deploying Firebase Storage Rules...
echo 📅 Date: %date% %time%

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Firebase CLI not found!
    echo 📥 Please install: npm install -g firebase-tools
    pause
    exit /b 1
)

REM Check if user is logged in
firebase projects:list >nul 2>&1
if errorlevel 1 (
    echo 🔐 Please login to Firebase first:
    echo firebase login
    pause
    exit /b 1
)

REM Deploy storage rules
echo 📤 Deploying storage rules...
firebase deploy --only storage

if errorlevel 0 (
    echo ✅ Firebase Storage Rules deployed successfully!
    echo 🔧 New rules should be active within 1-2 minutes
    echo.
    echo 🧪 Next steps:
    echo 1. Run the app: flutter run
    echo 2. Try uploading an image in chat
    echo 3. Check logs for Firebase test results
) else (
    echo ❌ Deployment failed!
    echo 💡 Please check:
    echo 1. Firebase project is selected: firebase use ^<project-id^>
    echo 2. You have Storage admin permissions
    echo 3. storage-rules.rules file exists
)

echo.
echo 📋 Manual deployment alternative:
echo 1. Go to https://console.firebase.google.com
echo 2. Select your project → Storage → Rules
echo 3. Copy rules from storage-rules.rules
echo 4. Click Publish

pause