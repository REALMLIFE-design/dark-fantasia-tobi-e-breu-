from pathlib import Path
import json
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PluginAssetBridgeContracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.project = (ROOT / "project.godot").read_text(encoding="utf-8")
        cls.plugin = (ROOT / "addons/dark_fantasy_asset_bridge/plugin.gd").read_text(encoding="utf-8")
        cls.catalog = (ROOT / "scripts/plugin_asset_catalog.gd").read_text(encoding="utf-8")
        cls.loader = (ROOT / "scripts/plugin_asset_loader.gd").read_text(encoding="utf-8")
        cls.shader = (ROOT / "scripts/aqueduct_stone.gdshader").read_text(encoding="utf-8")
        cls.world = (ROOT / "scripts/world.gd").read_text(encoding="utf-8")
        cls.enemy = (ROOT / "scripts/enemy.gd").read_text(encoding="utf-8")
        cls.import_workflow = (ROOT / ".github/workflows/import-submitted-assets.yml").read_text(encoding="utf-8")
        cls.android_workflow = (ROOT / ".github/workflows/android-apk.yml").read_text(encoding="utf-8")
        cls.aqueduct_graph = (ROOT / "assets/plugin_imports/aqueduct/stone_moss_material.toml").read_text(encoding="utf-8")
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
        for asset in ['thrixel_ancient_tree', 'thrixel_stag_guardian', 'thrixel_river_crab',
                      'thrixel_drowned_wraith', 'thrixel_rune_obelisk', 'thrixel_way_shrine',
                      'thrixel_river_coffer']:
            self.assertIn(asset, self.catalog)

    def test_catalog_points_to_grouped_mobile_thrixel_models(self):
        self.assertIn("354f8a8c-3812-43a4-b187-3df95354eb48", self.catalog)
        self.assertIn("2fbc201f-5a50-4511-9aa9-07736603d9ff", self.catalog)
        self.assertIn("c90ac6cc-200e-4892-a7a5-0cc263e64d1c", self.catalog)
        self.assertIn("texture_size=512", self.catalog)

    def test_catalog_preserves_all_24_pinoc_motion_paths(self):
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

    def test_runtime_loader_preserves_pbr_maps_and_adds_moss_filter(self):
        self.assertIn('func apply_biome_moss_filter(', self.loader)
        self.assertIn('func _make_aqueduct_material(', self.loader)
        self.assertIn('BaseMaterial3D.TRANSPARENCY_DISABLED', self.loader)
        self.assertIn('source_material.normal_texture', self.loader)
        self.assertIn('source_material.roughness_texture', self.loader)
        self.assertIn('source_material.metallic_texture', self.loader)
        self.assertIn('source_material.emission_texture', self.loader)
        self.assertIn('plugin_asset_loaded', self.loader)

    def test_aqueduct_shader_has_procedural_moss_and_optional_real_pbr_maps(self):
        for token in ['has_base_color_texture', 'has_normal_texture', 'has_roughness_texture',
                      'has_ao_texture', 'value_noise', 'moss_mask', 'moss_color', 'METALLIC = metallic_value']:
            self.assertIn(token, self.shader)
        for token in ['[nodes."moss_noise"]', '[nodes."moss_mask"]', '[nodes."stone_moss_blend"]',
                      '"base_color" = "stone_moss_blend"']:
            self.assertIn(token, self.aqueduct_graph)

    def test_world_places_and_filters_all_thrixel_landmarks_and_treasure_chests(self):
        for asset in ['thrixel_ancient_tree', 'thrixel_rune_obelisk', 'thrixel_way_shrine']:
            self.assertIn(f'load_or_create_asset(self, "{asset}"', self.world)
        self.assertIn('load_optional_scene("thrixel_river_coffer")', self.world)
        self.assertIn('apply_biome_moss_filter(', self.world)
        self.assertIn('THRIXEL_WORLD_MODELS_LOADED: %d/3', self.world)
        self.assertIn('THRIXEL_SILVER_RIVER_COFFER_PLACED', self.world)
        self.assertIn('THRIXEL_OBELISK_RINGS_ANIMATED: %d/3', self.world)

    def test_optional_enemy_models_are_attached_to_real_enemy_instances(self):
        for key in ['thrixel_drowned_wraith', 'thrixel_river_crab', 'thrixel_stag_guardian']:
            self.assertIn(f'asset_key = "{key}"', self.enemy)
        self.assertIn('THRIXEL_ENEMY_MODEL_ATTACHED', self.enemy)
        for kind in ['"enemy_kind", 7', '"enemy_kind", 8', '"enemy_kind", 9']:
            self.assertIn(kind, self.world)

    def test_import_workflow_persists_plugin_models_without_blocking_drive_import(self):
        self.assertIn('Importar modelos prontos do Thrixel para o repositório', self.import_workflow)
        self.assertIn('THRIXEL-ASSET-MANIFEST.json', self.import_workflow)
        self.assertIn('assets/plugin_imports/thrixel', self.import_workflow)
        self.assertIn('assets/plugin_imports/thrixel', self.import_workflow.split('git add', 1)[1])

    def test_android_ci_requires_all_plugin_models_and_smokes_the_actual_world(self):
        self.assertIn('THRIXEL_MODELS_READY: $ready/7', self.android_workflow)
        self.assertIn('THRIXEL_WORLD_MODELS_LOADED: 3/3', self.android_workflow)
        self.assertIn('THRIXEL_SILVER_RIVER_COFFER_PLACED: 3', self.android_workflow)
        self.assertIn('THRIXEL_OBELISK_RINGS_ANIMATED: 3/3', self.android_workflow)
        self.assertIn('THRIXEL_ENEMY_MODEL_ATTACHED: $model_key', self.android_workflow)

    def test_runtime_loader_does_not_apply_partial_pbr_sets(self):
        self.assertIn('has_aqueduct_maps', self.loader)
        self.assertIn('if has_aqueduct_maps:', self.loader)
        self.assertIn('return true', self.loader)


if __name__ == "__main__":
    unittest.main()
