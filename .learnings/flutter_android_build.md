# Flutter & Android CI Build Learnings

## 1. PowerShell BOM Traps
- Windows PowerShell `Out-File -Encoding utf8` outputs UTF-8 with BOM (`\xEF\xBB\xBF`).
- Gradle/Groovy does not tolerate BOM in `.gradle` files and throws `Unexpected character: '' @ line 1, column 1`.
- Solution: Always write `.gradle` files using clean binary UTF-8 without BOM.

## 2. Flutter Layout Alignment Enum
- Flutter `MainAxisAlignment` uses camelCase `MainAxisAlignment.spaceBetween`, NOT `.between`.

## 3. Kotlin AppWidget Package R Import
- Explicitly import `com.<package>.R` in AppWidget Providers to ensure seamless symbol resolution.

## 4. `flutter_blue_plus` Version & Gradle Compatibility Trap
- `flutter_blue_plus: ^1.34.0` pulls in federated sub-plugin `flutter_blue_plus_android-7.x`.
- Its `build.gradle` directly evaluates `compileSdkVersion flutter.compileSdkVersion`. In our declarative Gradle setup, this throws `Could not get unknown property 'flutter' for extension 'android'`.
- Solution: **Pin to `flutter_blue_plus: 1.32.11`**. It uses monolithic Android setup without federated Gradle evaluation conflicts.

## 5. Gradle `subprojects.afterEvaluate` Rule
- Do NOT invoke `afterEvaluate` in root `android/build.gradle` after `evaluationDependsOn(":app")`. Gradle will throw `Cannot run Project.afterEvaluate(Closure) when the project is already evaluated`.
