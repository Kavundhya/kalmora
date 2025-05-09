plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.kalmora.kalmora"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Updated NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Updated from 11 to 17
        targetCompatibility = JavaVersion.VERSION_17 // Updated from 11 to 17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString() // Updated from 11 to 17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kalmora.kalmora"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:32.7.2"))

    // Add the dependency for Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Add any other Firebase products you want to use
    // For example, Firebase Auth:
    implementation("com.google.firebase:firebase-auth")
    // Firebase Firestore
    implementation("com.google.firebase:firebase-firestore")

}

flutter {
    source = "../.."
}