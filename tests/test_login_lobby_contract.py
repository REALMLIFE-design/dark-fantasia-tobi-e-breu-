from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class LoginAndLobbyContractTests(unittest.TestCase):
    def test_bootstrap_opens_login_before_main_menu(self):
        source = (ROOT / "scripts/update_bootstrap.gd").read_text(encoding="utf-8")
        self.assertIn('change_scene_to_file("res://scenes/login.tscn")', source)

    def test_login_has_guest_path_and_google_setup_is_honest(self):
        source = (ROOT / "scripts/login_screen.gd").read_text(encoding="utf-8")
        self.assertIn("CONTINUAR COM GOOGLE", source)
        self.assertIn("JOGAR COMO CONVIDADO", source)
        self.assertIn("GOOGLE_REDIRECT_URI", source)
        self.assertIn("Client Secret", source)
        self.assertNotIn("service_role", source.lower())

    def test_lobby_is_connected_from_menu_and_has_friend_room_sections(self):
        menu = (ROOT / "scripts/main_menu.gd").read_text(encoding="utf-8")
        lobby = (ROOT / "scripts/friends_lobby.gd").read_text(encoding="utf-8")
        self.assertIn('res://scenes/friends_lobby.tscn', menu)
        self.assertIn("change_scene_to_packed(lobby)", menu)
        self.assertIn("SEUS AMIGOS", lobby)
        self.assertIn("PEDIDOS DE AMIZADE", lobby)
        self.assertIn("CRIAR SALA PRIVADA", lobby)
        self.assertIn("ENTRAR COM CÓDIGO", lobby)

    def test_loading_and_login_art_are_present(self):
        menu = (ROOT / "scripts/main_menu.gd").read_text(encoding="utf-8")
        login = (ROOT / "scripts/login_screen.gd").read_text(encoding="utf-8")
        self.assertIn("loading_azulan.svg", menu)
        self.assertIn("login_portal.svg", login)
        self.assertTrue((ROOT / "assets/art/friends_lobby.svg").is_file())


if __name__ == "__main__":
    unittest.main()
