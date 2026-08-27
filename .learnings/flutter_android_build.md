# Flutter & Android CI Build Learnings

## 1. PowerShell BOM Traps
- Windows PowerShell `Out-File -Encoding utf8` outputs UTF-8 with BOM (`\xEF\xBB\xBF`).
- Gradle/Groovy does not tolerate BOM in `.gradle` files and throws `Unexpected character: '' @ line 1, column 1`.
- Solution: Always write `.gradle` files using clean binary UTF-8 without BOM.

## 2. Flutter Layout Alignment Enum
- Flutter `MainAxisAlignment` uses camelCase `MainAxisAlignment.spaceBetween`, NOT `.between`.

## 3. Kotlin AppWidget Package R Import
- Explicitly import `com.<package>.R` in AppWidget Providers to ensure seamless symbol resolution.
