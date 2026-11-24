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
INTERACTION_WAIT="${TOBI_TEST_POST_TAP_SECONDS:-3}"
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
install_ok=false
for attempt in 1 2 3 4 5; do
  if timeout 240 adb install -r --streaming "$APK_PATH"; then install_ok=true; break; fi
  echo "Instalação ADB falhou na tentativa $attempt; aguardando serviços Android."
  sleep 4
done
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
adb shell input tap 640 490 || true
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
echo "TOBI_BREU_ANDROID_INTERACTION_OK pid=$APP_PID"
