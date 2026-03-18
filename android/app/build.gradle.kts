plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // id("com.google.gms.google-services") // Comentado correctamente
}

android {
    namespace = "com.example.traductor_creole"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Corrección para evitar el error de depreciación
        jvmTarget = "17" 
    }

    defaultConfig {
        applicationId = "com.example.traductor_creole"
        
        // CORRECCIÓN PARA .KTS (Kotlin Script)
        manifestPlaceholders.putAll(
            mapOf(
                "auth0Domain" to "criolloapp.us.auth0.com",
                "auth0Scheme" to "com.example.traductorcreole"
            )
        )

        minSdk = flutter.minSdkVersion
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