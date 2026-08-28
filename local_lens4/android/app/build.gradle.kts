plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase Services Plugin
}

android {
    namespace = "com.example.local_lens4"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.local_lens4" // Unique app ID
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Signing config for release build
        }
    }
}

flutter {
    source = "../.."  // Ensure Flutter source is correctly linked
}

dependencies {
    // Flutter dependencies (ensure Flutter dependencies are defined correctly)
    implementation 'com.google.firebase:firebase-auth:21.0.1' // Firebase Authentication
    implementation 'com.google.firebase:firebase-firestore:24.0.1' // Firebase Firestore
    implementation 'com.google.firebase:firebase-storage:20.0.1' // Firebase Storage

    // Optional: Firebase Analytics
    implementation 'com.google.firebase:firebase-analytics:20.0.3'

    // Google Maps dependencies (if using Google Maps for your project)
    implementation 'com.google.android.gms:play-services-maps:17.0.1'

    // Other dependencies
    implementation "org.jetbrains.kotlin:kotlin-stdlib:1.7.0" // Kotlin Standard Library

    // Add any other dependencies your app needs
}

apply plugin: 'com.google.gms.google-services' // Apply Google Services Plugin
