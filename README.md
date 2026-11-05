# watch-faces

Personal Wear OS watch faces in Watch Face Format (WFF), aimed at a Galaxy Watch 7 (Wear OS 5+, API 34).

## Layout

```text
settings.gradle.kts          # one Gradle module per watch face
simple-digital/
  build.gradle.kts           # applicationId, minSdk 34
  src/main/AndroidManifest.xml   # hasCode=false + WFF version property
  src/main/res/raw/watchface.xml # the face itself
  src/main/res/xml/watch_face_info.xml
  src/main/res/drawable-nodpi/preview.png
terminal-themes/             # Terminal Themes: Catppuccin/Rosé Pine/Night Owl, classic + terminal styles (default for install.ps1)
install.ps1                  # build + adb install (-Module <name> to pick a face)
```

To add a face, copy `simple-digital/`, change `namespace`/`applicationId`, and add it to `settings.gradle.kts`.

## One-time setup (macOS)

```bash
brew install --cask android-studio      # SDK + adb + bundled JDK (run it once, "Standard" setup)
brew install gradle                     # only needed once, to create the wrapper
export ANDROID_HOME="$HOME/Library/Android/sdk"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
gradle wrapper --gradle-version 8.11.1
chmod +x install.sh
./install.sh terminal-themes 192.168.x.x:PORT
```

The scripts in `scripts/` (star and preview generators) are Windows-only (PowerShell + System.Drawing). The generated PNGs are already committed, so you only need them to regenerate art.

## One-time setup (Windows)

1. **Android SDK**: install Android Studio, or only the command-line tools plus `platform-tools`, `platforms;android-35` and `build-tools;35.0.0`.
   Set `ANDROID_HOME` (usually `%LOCALAPPDATA%\Android\Sdk`) and put `%ANDROID_HOME%\platform-tools` on `PATH` so `adb` works.
2. **JDK 17 or 21**: the system Java here is 27, which is too new for Gradle 8.x / AGP 8.7. Point `JAVA_HOME` at a JDK 21. Android Studio's bundled `jbr` folder works.
3. **Gradle wrapper**: install Gradle once, then run `gradle wrapper --gradle-version 8.11.1` in this folder. After that, `install.ps1` uses `gradlew.bat`.

## Watch setup

Settings → About watch → Software → tap *Software version* 5× → Developer options:
enable **ADB debugging** and **Wireless debugging**. Wireless debugging shows the IP:port to pair and connect to:

```powershell
adb pair 192.168.x.x:PAIRPORT      # once, enter the code shown on the watch
.\install.ps1 -Connect 192.168.x.x:PORT
```

On the watch, long-press the current face, tap **+**, and choose *Simple Digital*. Long-press it, then tap **Customize** to change the accent color or the complication.

## Validation

Google's validator and memory-footprint tool are at <https://github.com/google/watchface> (see its releases). Play requires both to pass. For side-loading they're optional, but they catch XML mistakes the watch otherwise silently ignores.

Spec: <https://developer.android.com/training/wearables/wff>
