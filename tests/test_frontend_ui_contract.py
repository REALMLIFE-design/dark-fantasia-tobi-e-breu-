from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class FrontendUIContractTests(unittest.TestCase):
    def test_frontend_is_the_start_scene(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('run/main_scene="res://scenes/frontend.tscn"', project)

    def test_frontend_scene_uses_the_ui_script(self):
        scene = (ROOT / "scenes/frontend.tscn").read_text(encoding="utf-8")
        self.assertIn('res://scripts/frontend_ui.gd', scene)
        self.assertTrue((ROOT / "scripts/ui_illustration.gd").is_file())
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('OnlineService="*res://scripts/online_service.gd"', project)

    def test_login_and_menu_routes_exist(self):
        script = (ROOT / "scripts/frontend_ui.gd").read_text(encoding="utf-8")
        for required in (
            "func _show_login()",
            "func _on_google_login()",
            "func _start_guest_game()",
            "func _show_main_menu()",
            "func _start_game(new_game: bool)",
        ):
            with self.subTest(required=required):
                self.assertIn(required, script)

    def test_lobby_and_settings_are_present(self):
        script = (ROOT / "scripts/frontend_ui.gd").read_text(encoding="utf-8")
        self.assertIn("func _show_lobby()", script)
        self.assertIn("func _show_settings()", script)
        self.assertIn("func _add_illustration(", script)
        self.assertIn("func _quit_game()", script)
        self.assertIn("func _join_room_placeholder()", script)
        self.assertIn("func _online_not_ready()", script)
        self.assertIn("func _create_room_online()", script)
        self.assertIn("func _join_room_online()", script)
        self.assertIn("func _send_friend_request_online()", script)
        online = (ROOT / "scripts/online_service.gd").read_text(encoding="utf-8")
        self.assertIn("/auth/v1/signup", online)
        self.assertIn("/rest/v1/rpc/dark_world_create_room", online)
        self.assertIn("/rest/v1/rpc/dark_world_join_room", online)

    def test_game_scene_remains_the_gameplay_target(self):
        script = (ROOT / "scripts/frontend_ui.gd").read_text(encoding="utf-8")
        self.assertIn('const GAME_SCENE := "res://scenes/main.tscn"', script)
        self.assertTrue((ROOT / "scenes/main.tscn").is_file())


if __name__ == "__main__":
    unittest.main()
