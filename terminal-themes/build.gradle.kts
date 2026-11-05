plugins {
    id("com.android.application")
}

android {
    namespace = "de.brizuela.watchface.terminalthemes"
    compileSdk = 35

    defaultConfig {
        applicationId = "de.brizuela.watchface.terminalthemes"
        // API 34 = Wear OS 5 -> WFF v2 (needed for weather data).
        minSdk = 34
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
