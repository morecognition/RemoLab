# Android App Bundle Signing Setup

This guide will help you set up app signing for Android App Bundles (AAB) in your Flutter project.

## Quick Setup (Recommended)

1. **Run the automated setup script:**
   ```bash
   ./setup_android_signing.sh
   ```

   This script will:
   - Guide you through creating a keystore
   - Generate the necessary configuration files
   - Set up proper security practices

## Manual Setup

If you prefer to set things up manually:

### Step 1: Create a Keystore

```bash
cd android
mkdir -p keystores
keytool -genkey -v -keystore keystores/remorder-key.jks -alias remorder-key -keyalg RSA -keysize 2048 -validity 10000
```

### Step 2: Create key.properties

Create `android/key.properties` with:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=keystores/your-keystore.jks
```

### Step 3: Update .gitignore

Add to your `.gitignore`:

```
android/key.properties
android/keystores/*.jks
```

## Building App Bundles

Once configured, you can build signed App Bundles:

```bash
# Build release App Bundle
flutter build appbundle --release

# Build with specific build number and version
flutter build appbundle --release --build-number=2 --build-name=1.0.1
```

The signed AAB will be located at:
`build/app/outputs/bundle/release/app-release.aab`

## Configuration Details

### build.gradle Changes

The following changes have been made to `android/app/build.gradle`:

1. **Added keystore properties loading:**
   ```groovy
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }
   ```

2. **Added signing configuration:**
   ```groovy
   signingConfigs {
       release {
           keyAlias keystoreProperties['keyAlias']
           keyPassword keystoreProperties['keyPassword']
           storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
           storePassword keystoreProperties['storePassword']
       }
   }
   ```

3. **Updated buildTypes:**
   ```groovy
   buildTypes {
       release {
           signingConfig signingConfigs.release
           minifyEnabled true
           proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
       }
   }
   ```

### ProGuard Configuration

A `proguard-rules.pro` file has been created with Flutter-specific rules to ensure your app works correctly after code shrinking.

## Security Best Practices

1. **Never commit sensitive files:**
   - `key.properties`
   - `*.jks` keystore files
   - Any files containing passwords

2. **Backup your keystore:**
   - Store your keystore in a secure location
   - Consider using a password manager
   - Keep multiple backups in different locations

3. **Use strong passwords:**
   - At least 12 characters
   - Mix of letters, numbers, and symbols

## Uploading to Google Play Console

1. Build your signed AAB:
   ```bash
   flutter build appbundle --release
   ```

2. Upload the AAB file from:
   `build/app/outputs/bundle/release/app-release.aab`

3. Google Play Console will generate optimized APKs for different device configurations

## Troubleshooting

### Common Issues:

1. **"Keystore was tampered with" error:**
   - Check your keystore password
   - Verify the keystore file path in `key.properties`

2. **"Key not found" error:**
   - Verify the key alias in `key.properties`
   - Check that the alias exists in your keystore

3. **Build fails with ProGuard:**
   - Check `proguard-rules.pro` for missing rules
   - Add `-keep` rules for any classes that are being incorrectly removed

### Verification Commands:

```bash
# List keys in keystore
keytool -list -v -keystore android/keystores/your-keystore.jks

# Verify AAB signing
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

## Environment Variables (Alternative)

For CI/CD pipelines, you can use environment variables instead of `key.properties`:

```groovy
signingConfigs {
    release {
        keyAlias System.getenv("KEY_ALIAS") ?: keystoreProperties['keyAlias']
        keyPassword System.getenv("KEY_PASSWORD") ?: keystoreProperties['keyPassword']
        storeFile System.getenv("STORE_FILE") ? file(System.getenv("STORE_FILE")) : (keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null)
        storePassword System.getenv("STORE_PASSWORD") ?: keystoreProperties['storePassword']
    }
}
```
