buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Wajib: Plugin Android Gradle & Google Services
        classpath("com.android.tools.build:gradle:8.2.0")
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// (Opsional) Ubah lokasi build output jika perlu, bisa dihapus jika tidak digunakan
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// Wajib: Pastikan subproject app dikonfigurasi duluan
subprojects {
    project.evaluationDependsOn(":app")
}

// Task clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
