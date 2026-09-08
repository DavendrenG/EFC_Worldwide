# DESTINATION: android/build.gradle and android/app/build.gradle

## android/build.gradle — repositories

Huawei artefacts are not on Maven Central; the AGConnect repo must be added.

```groovy
buildscript {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://developer.huawei.com/repo/' }   // Huawei
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.3.0'
        classpath 'com.google.gms:google-services:4.4.2'                 // Firebase
        classpath 'com.huawei.agconnect:agcp:1.9.1.301'                  // Huawei
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://developer.huawei.com/repo/' }   // Huawei
    }
}
```

## android/app/build.gradle

```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

apply plugin: 'com.google.gms.google-services'      // needs google-services.json
apply plugin: 'com.huawei.agconnect'                // needs agconnect-services.json

android {
    namespace = "com.geoservetechnologies.efcworldwide"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.geoservetechnologies.efcworldwide"
        minSdk = 23          // firebase_messaging floor
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled true
    }

    // Two flavours so the AppGallery build can drop Google services entirely
    flavorDimensions "store"
    productFlavors {
        gms { dimension "store" }
        hms { dimension "store"; applicationIdSuffix "" }
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
}
```

## proguard-rules.pro

```
-keep class com.huawei.hms.** { *; }
-keep class com.huawei.agconnect.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.huawei.**
```
