#!/usr/bin/env bash
set -euo pipefail

: "${PROJECT_PATH:?PROJECT_PATH precisa apontar para o projeto Godot}"
: "${RUNNER_TEMP:?RUNNER_TEMP precisa estar definido pelo GitHub Actions}"

PACKAGE_ID="com.tobiebreu.darkworld3d"
APK_PATH="$PROJECT_PATH/build/TobiEBreu.apk"
LOG_PATH="$RUNNER_TEMP/android-launch.log"
FAILURE_LOG_PATH="$RUNNER_TEMP/android-launch-failure.log"
STARTUP_WAIT="${TOBI_TEST_SLEEP_SECONDS:-18}"
INTERACTION_WAIT="${TOBI_TEST_POST_TAP_SECONDS:-3}"

if [[ ! -s "$APK_PATH" ]]; then
  echo "ERRO: APK não encontrado em $APK_PATH"
  exit 1
fi

adb wait-for-device
adb shell wm size 1280x720
adb install -r "$APK_PATH"
adb shell am force-stop "$PACKAGE_ID"
adb shell monkey -p "$PACKAGE_ID" -c android.intent.category.LAUNCHER 1
sleep "$STARTUP_WAIT"

APP_PID="$(adb shell pidof "$PACKAGE_ID" | tr -d '\r')"
if [[ -z "$APP_PID" ]]; then
  adb logcat -d -t 3000 > "$FAILURE_LOG_PATH"
  cat "$FAILURE_LOG_PATH"
  echo "ERRO: o jogo fechou antes de permanecer aberto no Android"
  exit 1
fi

adb shell input tap 640 300
sleep "$INTERACTION_WAIT"
APP_PID="$(adb shell pidof "$PACKAGE_ID" | tr -d '\r')"
if [[ -z "$APP_PID" ]]; then
  adb logcat -d -t 3000 > "$FAILURE_LOG_PATH"
  cat "$FAILURE_LOG_PATH"
  echo "ERRO: o jogo fechou depois da interação inicial"
  exit 1
fi

adb logcat -d -t 4000 > "$LOG_PATH"
if ! grep -q "TOBI_BREU_GAME_STARTED" "$LOG_PATH"; then
  cat "$LOG_PATH"
  echo "ERRO: o botão Entrar no Mundo não concluiu a transição"
  exit 1
fi
if grep -E "FATAL EXCEPTION|Fatal signal|SIGSEGV|Process $PACKAGE_ID has died" "$LOG_PATH"; then
  echo "ERRO: falha fatal no processo Android do jogo"
  exit 1
fi

echo "TOBI_BREU_ANDROID_INTERACTION_OK pid=$APP_PID"
