#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_PATH:?PROJECT_PATH precisa apontar para o projeto Godot}"
: "${RUNNER_TEMP:?RUNNER_TEMP precisa estar definido pelo GitHub Actions}"
PACKAGE_ID="com.tobiebreu.darkworld3d"
APK_PATH="$PROJECT_PATH/build/TobiEBreu.apk"
LOG_PATH="$RUNNER_TEMP/android-launch.log"
CRASH_LOG_PATH="$RUNNER_TEMP/android-crash-buffer.log"
FAILURE_LOG_PATH="$RUNNER_TEMP/android-launch-failure.log"
STARTUP_WAIT="${TOBI_TEST_SLEEP_SECONDS:-60}"
INTERACTION_WAIT="${TOBI_TEST_POST_TAP_SECONDS:-20}"
[[ -s "$APK_PATH" ]] || { echo "ERRO: APK não encontrado em $APK_PATH"; exit 1; }
adb wait-for-device
for attempt in $(seq 1 60); do
  BOOT_STATE="$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
  [[ "$BOOT_STATE" == "1" ]] && break
  sleep 2
done
[[ "${BOOT_STATE:-}" == "1" ]] || { echo "ERRO: Android não terminou o boot"; exit 1; }
adb logcat -c || true
adb shell wm size 1280x720 >/dev/null 2>&1 || true
INSTALL_TIMEOUT_SECONDS="${TOBI_TEST_INSTALL_TIMEOUT_SECONDS:-420}"
install_ok=false
if timeout "$INSTALL_TIMEOUT_SECONDS" adb install -r --streaming "$APK_PATH"; then
  install_ok=true
else
  echo "Instalação ADB por streaming falhou; tentando modo tradicional."
  if timeout "$INSTALL_TIMEOUT_SECONDS" adb install -r --no-streaming "$APK_PATH"; then
    install_ok=true
  fi
fi
[[ "$install_ok" == "true" ]] || { echo "ERRO: não foi possível instalar o APK"; exit 1; }
adb shell am force-stop "$PACKAGE_ID" || true
adb shell monkey -p "$PACKAGE_ID" -c android.intent.category.LAUNCHER 1
sleep "$STARTUP_WAIT"
APP_PID="$(adb shell pidof "$PACKAGE_ID" 2>/dev/null | tr -d '\r' || true)"
if [[ -z "$APP_PID" ]]; then
  adb logcat -d -t 3000 > "$FAILURE_LOG_PATH" || true
  cat "$FAILURE_LOG_PATH"
  echo "ERRO: o jogo fechou antes de permanecer aberto"
  exit 1
fi
# A validação do APK não depende de um patch PCK opcional ou de rede externa.
adb logcat -d -v threadtime -t 8000 > "$LOG_PATH" || true
# The Android immersive-mode confirmation is a native system overlay.
# Detect it through the accessibility tree before tapping its "GOT IT" button;
# never tap the Friends/Google menu item when the overlay is absent.
WINDOW_XML_PATH="$RUNNER_TEMP/android-window.xml"
if timeout 20 adb shell uiautomator dump /sdcard/darkworld-window.xml >/dev/null 2>&1   && timeout 10 adb pull /sdcard/darkworld-window.xml "$WINDOW_XML_PATH" >/dev/null 2>&1; then
  if grep -qi "GOT IT" "$WINDOW_XML_PATH"; then
    echo "Android immersive-mode hint detected; dismissing it."
    adb shell input tap 920 528
    sleep 1
    if timeout 20 adb shell uiautomator dump /sdcard/darkworld-window.xml >/dev/null 2>&1       && timeout 10 adb pull /sdcard/darkworld-window.xml "$WINDOW_XML_PATH" >/dev/null 2>&1       && grep -qi "GOT IT" "$WINDOW_XML_PATH"; then
      echo "ERRO: o aviso nativo de tela cheia continuou aberto"
      exit 1
    fi
  fi
else
  echo "ERRO: não foi possível verificar a árvore de acessibilidade Android"
  exit 1
fi
# Open Play from the main menu, then advance every prologue page.
# The Continue button is centered at y=505 on the 1280x720 test display.
adb shell input tap 640 260
sleep 2
for page in 1 2 3 4; do
  adb shell input tap 640 505
  sleep 1
done
sleep "$INTERACTION_WAIT"
APP_PID="$(adb shell pidof "$PACKAGE_ID" 2>/dev/null | tr -d '\r' || true)"
if [[ -z "$APP_PID" ]]; then
  adb logcat -d -t 3000 > "$FAILURE_LOG_PATH" || true
  cat "$FAILURE_LOG_PATH"
  echo "ERRO: o jogo fechou depois da interação inicial"
  exit 1
fi
adb logcat -d -v threadtime -t 8000 > "$LOG_PATH" || true
adb logcat -b crash -d -v threadtime > "$CRASH_LOG_PATH" 2>/dev/null || true
RESUMED_ACTIVITY="$(adb shell dumpsys activity activities 2>/dev/null | tr -d '\r' || true)"
if [[ -n "$RESUMED_ACTIVITY" ]] && ! grep -E "mResumedActivity.*$PACKAGE_ID|topResumedActivity.*$PACKAGE_ID" <<< "$RESUMED_ACTIVITY"; then
  echo "$RESUMED_ACTIVITY"
  echo "ERRO: o jogo não permaneceu em primeiro plano"
  tail -n 160 "$LOG_PATH" || true
  exit 1
fi
# O buffer crash pode conter falhas de serviços do próprio emulador (ex.: Bluetooth).
# Só reprovar quando o PID ou o nome do processo do jogo aparecer literalmente.
if grep -Fq "pid $APP_PID (" "$CRASH_LOG_PATH" \
  || grep -Fq "pid: $APP_PID," "$CRASH_LOG_PATH" \
  || grep -Fq ">>> $PACKAGE_ID <<<" "$CRASH_LOG_PATH" \
  || grep -Fq "Process: $PACKAGE_ID" "$CRASH_LOG_PATH" \
  || grep -Fq "Process $PACKAGE_ID has died" "$LOG_PATH" "$CRASH_LOG_PATH"; then
  echo "ERRO: falha fatal no processo Android do jogo (PID $APP_PID)"
  cat "$CRASH_LOG_PATH" || true
  exit 1
fi
adb exec-out screencap -p > "$RUNNER_TEMP/android-world.png"
[[ -s "$RUNNER_TEMP/android-world.png" ]] || { echo "ERRO: captura do jogo vazia"; exit 1; }
echo "TOBI_BREU_ANDROID_SCREENSHOT=$RUNNER_TEMP/android-world.png"
echo "TOBI_BREU_ANDROID_INTERACTION_OK pid=$APP_PID"
