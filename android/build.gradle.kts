allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Some Gradle/Flutter setups do not apply allprojects repos to every plugin subproject;
// repeating here fixes "Could not find androidx.annotation" / flutter_embedding_release on release.
subprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Shorebird's Flutter toolchain can fail to resolve androidx.annotation for plugin modules;
// pulling it explicitly fixes "Could not find androidx.annotation:annotation:1.8.1" on shorebird release.
subprojects {
    plugins.withId("com.android.library") {
        dependencies.add("implementation", "androidx.annotation:annotation:1.8.2")
    }
    plugins.withId("com.android.application") {
        dependencies.add("implementation", "androidx.annotation:annotation:1.8.2")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
