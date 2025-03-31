plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.nlp_flutter"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion
    // ndkVersion = "27.0.12077973"

    compileOptions {
        // sourceCompatibility = JavaVersion.VERSION_11
        // targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // jvmTarget = JavaVersion.VERSION_11.toString()
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.nlp_flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk = flutter.minSdkVersion
        minSdk = 30
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        //
        resValue(
        type = "string",
        name = "default_web_client_id",
        value = "234674436503-nqtmob8t14lboo0c96e763grkjgedpmb.apps.googleusercontent.com"
        )
        //
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    // Enable core library desugaring (required by Amplify Gen2)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")

    // Include AWS Amplify dependencies
    implementation("com.amplifyframework:aws-auth-cognito:2.21.1")
    implementation("com.amplifyframework:aws-api:2.21.1")
    implementation("com.amplifyframework:aws-datastore:2.21.1")
    implementation("com.amplifyframework:aws-storage-s3:2.21.1")

    //
    implementation("androidx.browser:browser:1.5.0")
    //
}

flutter {
    source = "../.."
}
