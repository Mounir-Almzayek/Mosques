plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Must be last — merges Firebase config from google-services.json into the build
    id("com.google.gms.google-services")
}

android {
    namespace = "com.mouniralmzayek.mosques"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mouniralmzayek.mosques"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk من Flutter؛ يجب أن يبقى ≥ 21 لدعم Android TV (Leanback).
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // عند التفعيل: أضف قواعد في proguard-rules.pro لكل الإضافات (Firebase، Hive، إلخ).
            // isMinifyEnabled = true
            // isShrinkResources = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }
}

flutter {
    source = "../.."
}

configurations.configureEach {
    exclude(group = "com.google.android.play", module = "core-common")
}

dependencies {
    // Required by flutter_local_notifications (Java 8+ APIs on older minSdk)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Needed by Flutter Play Store split/deferred-components classes referenced at release shrink time.
    implementation("com.google.android.play:core:1.10.3")
}
