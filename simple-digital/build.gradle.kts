plugins {
    id("com.android.application")
}

android {
    namespace = "de.brizuela.watchface.simpledigital"
    compileSdk = 35

    defaultConfig {
        // Watch faces are installed by package name; keep it unique per face.
        applicationId = "de.brizuela.watchface.simpledigital"
        // API 34 = Wear OS 5 (Galaxy Watch 7 ships with it) -> WFF v2.
        minSdk = 34
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            // Fine for side-loading to your own watch. Use a real key for Play.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
