plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.teman_asa"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Versi NDK yang diminta error sebelumnya

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.teman_asa"
        
        // --- BAGIAN PENTING: INI SOLUSINYA ---
        minSdk = 23  // JANGAN UBAH INI JADI flutter.minSdkVersion
        // -------------------------------------
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}