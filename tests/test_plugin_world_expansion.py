from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PluginWorldExpansionContracts(unittest.TestCase):
    def test_expansion_is_built_during_world_boot(self):
        world = (ROOT / "scripts/world.gd").read_text(encoding="utf-8")
        self.assertIn("_build_plugin_world_expansion()", world)
        self.assertIn("func _build_plugin_world_expansion() -> void:", world)

    def test_new_landmarks_are_present(self):
        world = (ROOT / "scripts/world.gd").read_text(encoding="utf-8")
        for landmark in ["MoonwellSanctuary", "FallenWatchOutpost", "AncientTrailMarker_", "AncientTrailTorch_", "CinderHollow", "WardenStoneBridge", "EchoingBellTower"]:
            self.assertIn(landmark, world)

    def test_expansion_keeps_mobile_friendly_instancing(self):
        world = (ROOT / "scripts/world.gd").read_text(encoding="utf-8")
        self.assertIn("moon_light.omni_range = 10.0", world)
        self.assertIn("torch_light.omni_range = 6.0", world)
        self.assertIn("crystal_light.omni_range = 4.5", world)
        self.assertIn("bell_light.omni_range = 7.0", world)


if __name__ == "__main__":
    unittest.main()
