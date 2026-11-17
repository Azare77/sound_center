import com.android.build.api.dsl.ApplicationExtension
import com.android.build.api.variant.FilterConfiguration
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

extensions.configure<ApplicationExtension> {
    namespace = "app.soundcenter.player"
    compileSdk = 37
    buildToolsVersion = "34.0.0"
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    defaultConfig {
        applicationId = "app.soundcenter.player"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }

    packaging {
        dex.useLegacyPackaging = true
        jniLibs.useLegacyPackaging = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }

        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

tasks.whenTaskAdded {
    if (name.contains("ArtProfile")) {
        enabled = false
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_11
    }
    dependencies {
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.11.0")
    }
}

flutter {
    source = "../.."
}

// ABI split: Create separate APKs for each CPU architecture (required for F-Droid)
// Each ABI gets a unique version code suffix to ensure proper update handling
val abiCodes = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 3)
androidComponents {
    onVariants(selector().withBuildType("release")) { variant ->
        variant.outputs.forEach { output ->
            val abi =
                output.filters.find { it.filterType == FilterConfiguration.FilterType.ABI }?.identifier
            val abiCode = abiCodes[abi]
            if (abiCode != null) {
                output.versionCode.set(flutter.versionCode * 10 + abiCode)
            }
        }
    }
}