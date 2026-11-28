import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "test_android_emulator.sh"


class AndroidEmulatorScriptTests(unittest.TestCase):
    def run_script(self, exit_after_tap=False):
        with tempfile.TemporaryDirectory() as temp:
            temp_path = Path(temp)
            fake_bin = temp_path / "bin"
            fake_bin.mkdir()
            state = temp_path / "app-running"
            state.write_text("yes")
            adb = fake_bin / "adb"
            adb.write_text("""#!/usr/bin/env python3
import os, pathlib, sys
args = sys.argv[1:]
state = pathlib.Path(os.environ['FAKE_ADB_STATE'])
hint_state = pathlib.Path(os.environ['FAKE_ADB_HINT_STATE'])
if args[:3] == ['shell', 'getprop', 'sys.boot_completed']:
    print('1')
    raise SystemExit(0)
if args[:3] == ['shell', 'uiautomator', 'dump']:
    print('UI hierchary dumped to: /sdcard/darkworld-window.xml')
    raise SystemExit(0)
if args[:1] == ['pull']:
    target = pathlib.Path(args[2])
    target.write_text('' if hint_state.exists() else '<node text="GOT IT" />')
    raise SystemExit(0)
if args[:2] == ['exec-out', 'screencap']:
    sys.stdout.buffer.write(b'\\x89PNG\\r\\n\\x1a\\nFAKEPNG')
    raise SystemExit(0)
if args[:2] == ['shell', 'pidof']:
    if state.exists() and state.read_text() == 'yes':
        print('4321')
    raise SystemExit(0)
if args[:3] == ['shell', 'input', 'tap'] and args[3:] == ['920', '528']:
    hint_state.write_text('dismissed')
if args[:3] == ['shell', 'input', 'tap'] and args[3:] in (['640', '260'], ['640', '505']) and os.environ.get('FAKE_ADB_EXIT_AFTER_TAP') == '1':
    state.write_text('no')
if args[:2] == ['shell', 'dumpsys'] and args[2:4] == ['activity', 'activities']:
    print('mResumedActivity: ActivityRecord{abc com.tobiebreu.darkworld3d/.MainActivity}')
if args[:2] == ['logcat', '-d']:
    print('TOBI_BREU_GAME_STARTED')
    print('TOBI_BREU_WORLD_READY low_memory_android=True quest_stage=0')
    print('Atualização aplicada automaticamente! Seu progresso foi preservado.')
""")
            adb.chmod(0o755)
            project = temp_path / "project"
            build = project / "build"
            build.mkdir(parents=True)
            (build / "TobiEBreu.apk").write_bytes(b"fake apk")
            runner_temp = temp_path / "runner"
            runner_temp.mkdir()
            env = os.environ.copy()
            env.update({
                "PATH": f"{fake_bin}:{env['PATH']}",
                "PROJECT_PATH": str(project),
                "RUNNER_TEMP": str(runner_temp),
                "FAKE_ADB_STATE": str(state),
                "FAKE_ADB_HINT_STATE": str(temp_path / "hint-dismissed"),
                "TOBI_TEST_SLEEP_SECONDS": "0",
                "TOBI_TEST_POST_TAP_SECONDS": "0",
            })
            if exit_after_tap:
                env["FAKE_ADB_EXIT_AFTER_TAP"] = "1"
            return subprocess.run(["bash", str(SCRIPT)], env=env, text=True, capture_output=True)

    def test_keeps_game_running_after_launch_and_first_interaction(self):
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("TOBI_BREU_ANDROID_INTERACTION_OK", result.stdout)
        self.assertIn("TOBI_BREU_ANDROID_SCREENSHOT=", result.stdout)

    def test_enters_the_adventure_from_the_main_menu(self):
        script = SCRIPT.read_text(encoding="utf-8")
        self.assertIn('uiautomator dump /sdcard/darkworld-window.xml', script)
        self.assertIn('grep -qi "GOT IT"', script)
        self.assertIn('adb shell input tap 920 528', script)
        self.assertIn('adb shell input tap 640 260', script)
        self.assertIn('for page in 1 2 3 4; do', script)
        self.assertIn('adb shell input tap 640 505', script)
        self.assertLess(script.index('adb shell input tap 640 260'), script.index('for page in 1 2 3 4; do'))
        self.assertNotIn('adb shell input tap 640 570', script)
        self.assertNotIn('adb shell input tap 640 490', script)

    def test_requires_the_3d_world_ready_marker_before_passing(self):
        script = SCRIPT.read_text(encoding="utf-8")
        self.assertIn('grep -Fq "TOBI_BREU_WORLD_READY"', script)
        self.assertIn('o mundo 3D não terminou de carregar em 90 segundos', script)

    def test_capture_occurs_after_entering_the_adventure(self):
        script = SCRIPT.read_text(encoding="utf-8")
        self.assertLess(script.index("for page in 1 2 3 4; do"), script.index("adb exec-out screencap -p"))

    def test_verifies_game_remains_the_resumed_android_activity(self):
        script = SCRIPT.read_text(encoding="utf-8")
        self.assertIn("dumpsys activity activities", script)
        self.assertIn("topResumedActivity", script)
        self.assertNotIn('grep -q "TOBI_BREU_GAME_STARTED"', script)

    def test_fails_with_clear_diagnostics_if_game_exits_after_interaction(self):
        result = self.run_script(exit_after_tap=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("o jogo fechou depois da interação inicial", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
