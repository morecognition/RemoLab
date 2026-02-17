#!/bin/bash

# Android App Bundle Signing Setup Script
# This script will help you set up app signing for your Flutter Android project

echo "🔐 Android App Bundle Signing Setup"
echo "=================================="
echo ""

ANDROID_DIR="android"
KEY_PROPERTIES_FILE="$ANDROID_DIR/key.properties"
KEYSTORE_DIR="$ANDROID_DIR/keystores"

# Create keystores directory if it doesn't exist
mkdir -p "$KEYSTORE_DIR"

echo "📋 We'll need some information to create your signing key:"
echo ""

# Get user input
read -p "Enter your app's key alias (e.g., remorder-key): " KEY_ALIAS
read -p "Enter your name or company: " OWNER_NAME
read -p "Enter your organization unit (e.g., Development): " ORG_UNIT
read -p "Enter your organization (e.g., MoreCognition): " ORGANIZATION
read -p "Enter your city: " CITY
read -p "Enter your state/province: " STATE
read -p "Enter your country code (e.g., IT): " COUNTRY

# Generate keystore filename
KEYSTORE_FILE="$KEYSTORE_DIR/$KEY_ALIAS.jks"

echo ""
echo "🔑 Generating keystore..."
echo "Keystore will be saved to: $KEYSTORE_FILE"
echo ""

# Generate the keystore
keytool -genkey -v -keystore "$KEYSTORE_FILE" -alias "$KEY_ALIAS" -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=$OWNER_NAME, OU=$ORG_UNIT, O=$ORGANIZATION, L=$CITY, ST=$STATE, C=$COUNTRY"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore generated successfully!"
    echo ""
    
    # Get passwords from user
    read -s -p "Enter the keystore password you just set: " STORE_PASSWORD
    echo ""
    read -s -p "Enter the key password (press Enter if same as keystore password): " KEY_PASSWORD
    echo ""
    
    # Use keystore password for key password if empty
    if [ -z "$KEY_PASSWORD" ]; then
        KEY_PASSWORD="$STORE_PASSWORD"
    fi
    
    # Create key.properties file
    echo "📝 Creating key.properties file..."
    cat > "$KEY_PROPERTIES_FILE" << EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=keystores/$KEY_ALIAS.jks
EOF
    
    echo ""
    echo "✅ Setup completed successfully!"
    echo ""
    echo "📁 Files created:"
    echo "   - $KEYSTORE_FILE (your signing keystore)"
    echo "   - $KEY_PROPERTIES_FILE (signing configuration)"
    echo ""
    echo "⚠️  IMPORTANT SECURITY NOTES:"
    echo "   - Keep your keystore file safe and backed up"
    echo "   - Never commit key.properties to version control"
    echo "   - Store your passwords securely"
    echo ""
    echo "🚀 You can now build signed App Bundles with:"
    echo "   flutter build appbundle --release"
    echo ""
    
    # Add key.properties to .gitignore if it exists
    if [ -f ".gitignore" ]; then
        if ! grep -q "android/key.properties" .gitignore; then
            echo "android/key.properties" >> .gitignore
            echo "✅ Added key.properties to .gitignore"
        fi
    fi
    
else
    echo ""
    echo "❌ Keystore generation failed. Please check the error above."
    exit 1
fi
