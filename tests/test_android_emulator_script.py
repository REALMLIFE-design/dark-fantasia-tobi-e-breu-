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
if args[:2] == ['shell', 'pidof']:
    if state.exists() and state.read_text() == 'yes':
        print('4321')
    raise SystemExit(0)
if args[:3] == ['shell', 'input', 'tap'] and os.environ.get('FAKE_ADB_EXIT_AFTER_TAP') == '1':
    state.write_text('no')
if args[:2] == ['logcat', '-d']:
    print('TOBI_BREU_GAME_STARTED')
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

    def test_fails_with_clear_diagnostics_if_game_exits_after_interaction(self):
        result = self.run_script(exit_after_tap=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("o jogo fechou depois da interação inicial", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
