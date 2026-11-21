from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PluginAssetBridgeContracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.project = (ROOT / "project.godot").read_text(encoding="utf-8")
        cls.plugin = (ROOT / "addons/dark_fantasy_asset_bridge/plugin.gd").read_text(encoding="utf-8")
        cls.catalog = (ROOT / "scripts/plugin_asset_catalog.gd").read_text(encoding="utf-8")
        cls.loader = (ROOT / "scripts/plugin_asset_loader.gd").read_text(encoding="utf-8")
        cls.motion_catalog = (ROOT / "assets/plugin_imports/pinoc/motion_catalog.json").read_text(encoding="utf-8")

    def test_editor_plugin_is_enabled_in_project(self):
        self.assertIn('res://addons/dark_fantasy_asset_bridge/plugin.cfg', self.project)

    def test_editor_plugin_has_a_manual_asset_diagnostic(self):
        self.assertIn('add_control_to_dock', self.plugin)
        self.assertIn('Verificar arquivos', self.plugin)
        self.assertIn('FileAccess.file_exists', self.plugin)

    def test_catalog_lists_external_plugin_assets(self):
        for asset in ['aqueduct_base_color', 'aqueduct_height', 'meshy_gate', 'meshy_way_shrine', 'meshy_tobi_hero', 'pinoc_walking', 'pinoc_forest_splat']:
            self.assertIn(asset, self.catalog)
        self.assertIn('func get_missing_assets()', self.catalog)

    def test_catalog_preserves_all_24_pinoc_motion_paths(self):
        import json
        catalog = json.loads(self.motion_catalog)
        self.assertEqual(len(catalog["motions"]), 24)
        for motion in catalog["motions"]:
            self.assertIn(f'"pinoc_{motion["key"]}"', self.catalog)
            self.assertIn(motion["path"], self.catalog)

    def test_runtime_loader_guards_optional_meshy_model(self):
        self.assertIn('func load_optional_scene(asset_key: String) -> PackedScene:', self.loader)
        self.assertIn('func load_meshy_asset(', self.loader)
        self.assertIn('func load_meshy_gate', self.loader)
        self.assertIn('func load_pinoc_motion', self.loader)

    def test_runtime_loader_does_not_apply_partial_pbr_sets(self):
        self.assertIn('if not FileAccess.file_exists(texture_path):', self.loader)
        self.assertIn('return false', self.loader)


if __name__ == "__main__":
    unittest.main()
