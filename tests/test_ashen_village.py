from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

class AshenVillageContracts(unittest.TestCase):
    def test_world_boot_builds_ashen_village(self):
        world = (ROOT / "scripts/world.gd").read_text(encoding="utf-8")
        self.assertIn("ASHEN_VILLAGE.build(self, ashen_relic_ids)", world)
        self.assertIn("func _nearest_ashen_relic() -> int:", world)
        self.assertIn("TESOURO DA CRIPTA REIVINDICADO", world)
        self.assertIn('"ashen_relic_ids", ashen_relic_ids', world)
        self.assertIn('"ashen_reward_claimed", ashen_reward_claimed', world)

    def test_ashen_village_has_distinct_landmarks(self):
        script = (ROOT / "scripts/ashen_village.gd").read_text(encoding="utf-8")
        for landmark in ("AldeiaDasCinzas", "AshenChapel", "AshenCrypt", "RavenGraveyard", "DeadTree", "AshenRoad", "AshenRelic_", "AshenRewardAltar", "AshenVillageVillager", "AshenChapelGuard"):
            self.assertIn(landmark, script)

    def test_ashen_village_is_mobile_bounded(self):
        script = (ROOT / "scripts/ashen_village.gd").read_text(encoding="utf-8")
        self.assertIn("MAX_GRAVESTONES := 12", script)
        self.assertIn("MAX_DEAD_TREES := 5", script)
        self.assertIn("add_child(village)", script)
        self.assertIn("road.rotation.y = 0.85", script)
        self.assertIn("Vector3(-21.0, 0.0, 3.0)", script)
        self.assertIn("Vector3(20.0, 0.0, 1.0)", script)

if __name__ == "__main__":
    unittest.main()
