from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

class GameplayContracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.player = (ROOT / 'scripts/player.gd').read_text(encoding='utf-8')
        cls.world = (ROOT / 'scripts/world.gd').read_text(encoding='utf-8')
        cls.project = (ROOT / 'project.godot').read_text(encoding='utf-8')
        cls.enemy = (ROOT / 'scripts/enemy.gd').read_text(encoding='utf-8')

    def test_keyboard_dodge_is_wired(self):
        self.assertIn('Input.is_action_just_pressed("dodge")', self.player)
        self.assertIn('func do_dodge()', self.player)

    def test_keyboard_potion_is_wired(self):
        self.assertIn('Input.is_action_just_pressed("potion")', self.world)
        self.assertIn('func _use_potion()', self.world)

    def test_first_quest_counts_only_corrupted_goblins(self):
        self.assertIn('if quest_stage == 1 and kind == 0:', self.world)
        self.assertIn('defeated_count += 1', self.world)

    def test_save_is_versioned_and_old_saves_supported(self):
        self.assertIn('"save_version", 15', self.world)
        self.assertIn('save_version > 15', self.world)
        self.assertIn('get_value("meta", "save_version", 1)', self.world)

    def test_swamp_quest_has_three_persistent_totems(self):
        self.assertIn('func _build_swamp_region()', self.world)
        self.assertIn('swamp_totem_ids.append(i)', self.world)
        self.assertIn('"swamp_totem_ids", swamp_totem_ids', self.world)

    def test_swamp_boss_is_locked_until_totems_are_purified(self):
        enemy = (ROOT / 'scripts/enemy.gd').read_text(encoding='utf-8')
        self.assertIn('enemy_kind == 4 and int(get_parent().get("quest_stage")) < 6', enemy)
        self.assertIn('if quest_stage == 6:', self.world)


    def test_tobi_has_hit_landing_and_defeat_animation_states(self):
        self.assertIn('hit_reaction = 0.22', self.player)
        self.assertIn('landing_time = 0.16', self.player)
        self.assertIn('visual.rotation.z = lerpf(visual.rotation.z, 1.25', self.player)

    def test_breu_has_four_animated_paws_and_segmented_tail(self):
        self.assertIn('for z in [-0.16, 0.18]', self.player)
        self.assertIn('TailSegment%d', self.player)
        self.assertIn('var paws: Array = cat.get_meta("paws")', self.player)

    def test_enemy_animation_and_character_specific_details(self):
        self.assertIn('weapon_pivot_ref.rotation.z', self.enemy)
        self.assertIn('var robe := CylinderMesh.new()', self.enemy)
        self.assertIn('attack_weight', self.enemy)


    def test_weapon_forging_has_three_persistent_upgrade_tiers(self):
        self.assertIn('const WEAPON_UPGRADE_COSTS := [3, 6, 10]', self.world)
        self.assertIn('func _upgrade_weapon()', self.world)
        self.assertIn('"weapon_level", weapon_level', self.world)
        self.assertIn('weapon_level = clampi', self.world)
        self.assertIn('enemy.take_damage(combo_damage)', self.player)
        self.assertIn('upgrade={"deadzone":0.5', self.project)

    def test_inventory_panel_and_keyboard_toggle_exist(self):
        self.assertIn('func _toggle_inventory()', self.world)
        self.assertIn('event.keycode == KEY_I', self.world)
        self.assertIn('MOCHILA DE TOBI', self.world)

    def test_inventory_materials_are_persisted(self):
        for item in ['goblin_ears', 'swamp_herbs', 'dark_essence']:
            self.assertIn('cfg.set_value("inventory", "%s"' % item, self.world)
            self.assertIn('cfg.get_value("inventory", "%s"' % item, self.world)

    def test_enemy_loot_tables_add_materials(self):
        self.assertIn('goblin_ears += 1', self.world)
        self.assertIn('swamp_herbs += 1', self.world)
        self.assertIn('dark_essence += 3', self.world)


    def test_shrine_sets_and_persists_checkpoint(self):
        self.assertIn('checkpoint_position = shrine.global_position + Vector3(0, 0, 4)', self.world)
        self.assertIn('cfg.set_value("progress", "checkpoint_x", checkpoint_position.x)', self.world)
        self.assertIn('cfg.set_value("progress", "checkpoint_z", checkpoint_position.z)', self.world)
        self.assertIn('player.global_position = checkpoint_position', self.world)

    def test_checkpoint_coordinates_are_validated_on_load(self):
        self.assertIn('absf(checkpoint_x) <= 140.0', self.world)
        self.assertIn('absf(checkpoint_z) <= 140.0', self.world)

    def test_river_treasure_chests_are_interactive_and_persistent(self):
        self.assertIn('func _build_river_treasure_chests()', self.world)
        self.assertIn('func _nearest_river_chest()', self.world)
        self.assertIn('func _open_river_chest(chest_id: int)', self.world)
        self.assertIn('river_chest_ids.append(chest_id)', self.world)
        self.assertIn('cfg.set_value("progress", "river_chest_ids", river_chest_ids)', self.world)
        self.assertIn('cfg.get_value("progress", "river_chest_ids", [])', self.world)
        self.assertIn('ChestLidPivot', self.world)
        self.assertIn('BAÚ ABERTO!', self.world)

    def test_whisper_grove_is_a_connected_persistent_optional_map_area(self):
        self.assertIn('func _build_whisper_grove()', self.world)
        self.assertIn('_build_whisper_grove()', self.world)
        self.assertIn('WhisperGroveIsland', self.world)
        self.assertIn('GroveSteppingStone', self.world)
        self.assertIn('func _nearest_whisper_lantern()', self.world)
        self.assertIn('func _activate_whisper_lantern(lantern_id: int)', self.world)
        self.assertIn('whisper_lantern_ids.append(lantern_id)', self.world)
        self.assertIn('cfg.set_value("progress", "whisper_lantern_ids", whisper_lantern_ids)', self.world)
        self.assertIn('cfg.get_value("progress", "whisper_lantern_ids", [])', self.world)
        self.assertIn('BOSQUE DESPERTOU!', self.world)
        self.assertIn('whisper_grove_label.visible = grove_distance < 24.0', self.world)
        self.assertIn('BOSQUE DOS SUSSURROS  •  %d/3 LANTERNAS', self.world)
        self.assertIn('func _spawn_whisper_stag_guardian()', self.world)
        self.assertIn('whisper_guardian_reward_claimed', self.world)
        self.assertIn('Bênção do Cervo Ancião', self.world)

    def test_whisper_guardian_uses_procedural_geometry_until_asset_vendoring_is_available(self):
        self.assertIn('func _spawn_whisper_stag_guardian()', self.world)
        self.assertIn('WhisperStagGuardian', self.world)
        self.assertIn('StagAntlerLeftMain', self.world)
        self.assertIn('func _add_stag_antler_segment', self.world)
        self.assertNotIn('ancient_stag_guardian.glb', self.world)
        workflow = (ROOT / ".github/workflows/android-apk.yml").read_text(encoding="utf-8")
        self.assertNotIn("api.thrixel.com", workflow)


    def test_main_menu_copy_and_close_target_are_mobile_friendly(self):
        self.assertIn('title.text = "A lenda desperta"', self.world)
        self.assertIn('_menu_add_button(content, "Jogar", _start_game, true)', self.world)
        self.assertIn('close_btn.custom_minimum_size = Vector2(44, 44)', self.world)

    def test_quest_journal_tracks_whisper_grove_side_quest(self):
        self.assertIn('"Lanternas do Bosque"', self.world)
        self.assertIn('"RECOMPENSA DO BOSQUE"', self.world)
        self.assertIn('whisper_lantern_ids.size()', self.world)
        self.assertIn('"Converse com o Cervo Guardião após acender as lanternas"', self.world)

    def test_inventory_uses_item_slots_for_persisted_resources(self):
        for item in ('Poção de vida', 'Fragmentos Rubros', 'Orelhas de Goblin', 'Ervas do Pântano', 'Essência Sombria'):
            self.assertIn(item, self.world)
        self.assertIn('func _menu_add_item_grid(', self.world)
        self.assertIn('grid.columns = 2', self.world)
        self.assertIn('"EQUIPAMENTO"', self.world)
        self.assertIn('"MOCHILA"', self.world)

    def test_project_display_name_matches_archive_version(self):
        self.assertIn('Dark World 3D 0.12.0', self.project)


    def test_three_step_combo_scales_damage_and_expires(self):
        self.assertIn('var combo_step := 0', self.player)
        self.assertIn('combo_timer = 1.05', self.player)
        self.assertIn('var multipliers := [1.0, 1.25, 1.65]', self.player)
        self.assertIn('world.combat_combo_changed(combo_step)', self.player)

    def test_breu_shadow_pulse_has_cost_radius_and_cooldown(self):
        self.assertIn('func do_shadow_pulse()', self.player)
        self.assertIn('shadow_pulse_cooldown = 8.0', self.player)
        self.assertIn('stamina < 35.0', self.player)
        self.assertIn('flat.length() <= 4.2', self.player)
        self.assertIn('player.do_shadow_pulse()', self.world)

    def test_shadow_pulse_has_expanding_translucent_visual_feedback(self):
        self.assertIn('func _create_shadow_pulse_visual()', self.player)
        self.assertIn('TorusMesh.new()', self.player)
        self.assertIn('BaseMaterial3D.TRANSPARENCY_ALPHA', self.player)
        self.assertIn('pulse_ring.scale = Vector3.ONE * lerpf(0.35, 4.2, progress)', self.player)
        self.assertIn('pulse_visual_timer = 0.72', self.player)

    def test_shadow_pulse_touch_and_keyboard_controls_exist(self):
        self.assertIn('KEY_K', self.player)
        self.assertIn('{"t":"✦","a":"shadow","p":Vector2(0.86,0.70)}', self.world)
        self.assertIn('elif data.a == "shadow":', self.world)
        self.assertIn('action_btn.pressed.connect(_touch_action.bind(data.a))', self.world)
        self.assertIn('elif action == "shadow": player.do_shadow_pulse()', self.world)
        self.assertIn('Pulso Sombrio pronto', self.world)


    def test_enemy_attacks_have_readable_windup_and_ground_telegraph(self):
        self.assertIn('var attack_windup_timer := 0.0', self.enemy)
        self.assertIn('func _create_attack_telegraph()', self.enemy)
        self.assertIn('attack_telegraph.visible = true', self.enemy)
        self.assertIn('attack_telegraph_material.emission_enabled = true', self.enemy)

    def test_enemy_damage_is_resolved_after_windup_not_on_contact(self):
        self.assertIn('func _begin_attack()', self.enemy)
        self.assertIn('func _resolve_attack()', self.enemy)
        self.assertIn('if flat.length() <= reach:', self.enemy)
        self.assertNotIn('target.take_damage(attack_damage)\n\t\telse:', self.enemy)

    def test_bosses_have_longer_attack_warnings_than_regular_enemies(self):
        self.assertIn('0.78 if enemy_kind >= 3', self.enemy)
        self.assertIn('attack_timer += 0.45', self.enemy)

    def test_enemy_attack_warning_is_cancelled_on_death(self):
        self.assertIn('attack_telegraph.visible = false', self.enemy)
        self.assertIn('attack_windup_timer = 0.0', self.enemy)

    def test_old_saves_with_activated_shrine_migrate_checkpoint(self):
        self.assertIn('saved_shrine_used and not cfg.has_section_key("progress", "checkpoint_x")', self.world)
        self.assertIn('checkpoint_z = 29.0', self.world)


    def test_experience_levels_increase_real_combat_and_health_stats(self):
        self.assertIn('func _get_player_level() -> int:', self.world)
        self.assertIn('func _grant_xp(amount: int) -> void:', self.world)
        self.assertIn('player.max_hp = 100 + (level - 1) * 12', self.world)
        self.assertIn('player.attack_damage = 35 + weapon_level * 10 + (level - 1) * 3', self.world)
        self.assertIn('player.hp = mini(player.max_hp, player.hp + 25 * levels_gained)', self.world)
        self.assertIn('var levels_gained := current_level - previous_level', self.world)

    def test_xp_rewards_flow_through_level_progression_and_are_persisted(self):
        self.assertEqual(self.world.count('xp +='), 0)
        self.assertIn('func _grant_xp(amount: int) -> void:', self.world)
        self.assertIn('xp = maxi(0, xp + amount)', self.world)
        self.assertIn('xp_bar.value = current_level_xp', self.world)

    def test_hud_experience_bar_shows_progress_within_current_level(self):
        self.assertIn('var xp_bar: ProgressBar', self.world)
        self.assertIn('xp_bar.max_value = xp_needed', self.world)
        self.assertIn('xp_label.text = "NÍVEL %d  •  EXP %d/%d"', self.world)


    def test_chapter_two_unlocks_rio_prateado_after_chapter_one(self):
        self.assertIn('func _build_river_region()', self.world)
        self.assertIn('"Guardião do Rio"', self.world)
        self.assertIn('quest_stage = 9', self.world)
        self.assertIn('Objetivo: encontre o Guardião do Rio Prateado', self.world)

    def test_river_knight_contract_requires_three_specific_enemies(self):
        self.assertIn('river_knights_defeated += 1', self.world)
        self.assertIn('if quest_stage == 10 and kind == 5:', self.world)
        self.assertIn('enemy_kind == 5 and int(get_parent().get("quest_stage")) != 10', self.enemy)

    def test_chapter_two_progress_and_counter_are_persisted(self):
        self.assertIn('"save_version", 15', self.world)
        self.assertIn('save_version > 15', self.world)
        self.assertIn('"river_knights_defeated", river_knights_defeated', self.world)
        self.assertIn('quest_stage = clampi(int(cfg.get_value("progress", "quest_stage", 0)), 0, 20)', self.world)

    def test_river_knights_have_a_distinct_silhouette_and_combat_profile(self):
        self.assertIn('elif enemy_kind == 5:', self.enemy)
        self.assertIn('CAVALEIRO AFOGADO', self.enemy)
        self.assertIn('Color("477b88")', self.enemy)


    def test_river_chapter_has_a_final_boss_after_the_three_knights(self):
        self.assertIn('leviathan.set("enemy_kind", 6)', self.world)
        self.assertIn('if quest_stage == 11:', self.world)
        self.assertIn('quest_stage = 12', self.world)
        self.assertIn('_activate_river_boss()', self.world)
        self.assertIn('if quest_stage == 12 and kind == 6:', self.world)
        self.assertIn('quest_stage = 13', self.world)

    def test_leviathan_has_boss_stats_and_is_locked_to_its_quest_stage(self):
        self.assertIn('elif enemy_kind == 6:', self.enemy)
        self.assertIn('hp = 680', self.enemy)
        self.assertIn('attack_damage = 27', self.enemy)
        self.assertIn('enemy_kind == 6 and int(get_parent().get("quest_stage")) != 12', self.enemy)
        self.assertIn('LEVIATÃ DO LODO', self.enemy)
        self.assertIn('hp <= 340', self.enemy)
        self.assertIn('attack_damage = 31', self.enemy)

    def test_river_chapter_completion_requires_reporting_boss_defeat(self):
        self.assertIn('elif quest_stage == 13:', self.world)
        self.assertIn('quest_stage = 14', self.world)
        self.assertIn('"quest_stage", quest_stage', self.world)
        self.assertIn('0, 14)', self.world)

    def test_leviathan_health_is_restored_from_save_and_saved_on_hit(self):
        self.assertIn('river_boss.set("hp", river_boss_hp)', self.world)
        self.assertIn('cfg.set_value("progress", "river_boss_hp", river_boss_hp)', self.world)
        self.assertIn('cfg.get_value("progress", "river_boss_hp", 680)', self.world)
        self.assertIn('_save_game()', self.world[self.world.index('func boss_health_changed'):self.world.index('func player_health_changed')])


    def test_river_wraiths_unlock_with_chapter_two_and_are_optional(self):
        self.assertIn('wraith.set("enemy_kind", 7)', self.world)
        self.assertIn('if quest_stage < 9:', self.world)
        self.assertIn('_reveal_river_wraiths()', self.world)
        self.assertIn('if enemy_kind == 7 and int(get_parent().get("quest_stage")) < 9: return', self.enemy)
        self.assertIn('if kind == 7:', self.world)
        self.assertIn('dark_essence += 1', self.world)


    def test_silver_river_crabs_are_optional_combat_encounters_with_rewards(self):
        self.assertIn('crab.set("enemy_kind", 8)', self.world)
        self.assertIn('if quest_stage < 9:', self.world)
        self.assertIn('if enemy_kind == 8 and int(get_parent().get("quest_stage")) < 9: return', self.enemy)
        self.assertIn('CARANGUEJO DE PRATA', self.enemy)
        self.assertIn('if kind == 8:', self.world)
        self.assertIn('dark_essence += 1', self.world)

    def test_silver_crab_has_a_distinct_telegraphed_claw_lunge(self):
        self.assertIn('attack_windup_duration = 0.92 if enemy_kind == 8', self.enemy)
        self.assertIn('(2.75 if enemy_kind == 8 else attack_range)', self.enemy)
        self.assertIn('crab_lunge_velocity = flat.normalized() * 7.2', self.enemy)
        self.assertIn('crab_lunge_timer = 0.22', self.enemy)
        self.assertIn('for i in range(crab_claws.size())', self.enemy)
        self.assertIn('claw_node.rotation.x = claw_swing - attack_swing', self.enemy)

    def test_leviathan_save_writes_are_throttled_to_health_bands(self):
        section = self.world[self.world.index('func boss_health_changed'):self.world.index('func player_health_changed')]
        self.assertIn('river_boss_saved_band', section)
        self.assertIn('health_band != river_boss_saved_band', section)
        self.assertIn('river_boss_hp <= 0', section)

    def test_boss_fight_has_a_centered_mobile_health_bar(self):
        self.assertIn('set_anchors_preset(Control.PRESET_CENTER_TOP)', self.world)
        self.assertIn('boss_health_bar.max_value = 680', self.world)
        self.assertIn('boss_hud_panel.visible = quest_stage == 12', self.world)
        self.assertIn('boss_health_changed(maxi(0, hp), 680)', self.enemy)
        self.assertIn('river_boss_hp = clampi(current, 0, maximum)', self.world)
        self.assertIn('river_boss_hp', self.world)

    def test_mobile_compatibility_renderer_and_landscape(self):
        self.assertIn('renderer/rendering_method.mobile="gl_compatibility"', self.project)
        self.assertIn('window/handheld/orientation=0', self.project)

    def test_leviathan_alternates_slam_attack_with_larger_telegraph(self):
        self.assertIn('var boss_slam_active := false', self.enemy)
        self.assertIn('var boss_attack_count := 0', self.enemy)
        self.assertIn('boss_slam_radius := 5.4', self.enemy)
        self.assertIn('boss_attack_count += 1', self.enemy)
        self.assertIn('boss_slam_active = boss_attack_count % 2 == 0', self.enemy)
        self.assertIn('var warning_radius := boss_slam_radius if boss_slam_active else (2.75 if enemy_kind == 8 else attack_range)', self.enemy)

    def test_leviathan_slam_has_long_warning_and_area_damage_resolution(self):
        self.assertIn('attack_windup_duration = 1.35 if enraged else 1.05', self.enemy)
        self.assertIn('var reach := (boss_slam_radius + 0.35) if slam_resolved', self.enemy)
        self.assertIn('boss_slam_active = false', self.enemy)

    def test_leviathan_enrage_phase_is_restored_after_loading_a_save(self):
        self.assertIn('func sync_boss_phase() -> void:', self.enemy)
        self.assertIn('leviathan.call("sync_boss_phase")', self.world)
        self.assertIn('river_boss.call("sync_boss_phase")', self.world)
        self.assertIn('if enemy_kind == 6 and hp <= 340:', self.enemy)

    def test_leviathan_enrage_changes_combat_and_visual_feedback(self):
        self.assertIn('func _enter_boss_enrage(', self.enemy)
        self.assertIn('attack_damage = 31', self.enemy)
        self.assertIn('boss_core_material.emission_energy_multiplier = 2.8', self.enemy)
        self.assertIn('Color(1.0, 0.24, 0.035, 0.9)', self.enemy)
        self.assertIn('river_boss_phase_changed()', self.world)
        self.assertIn('FÚRIA', self.world)

    def test_river_memory_relics_are_optional_persistent_discoveries(self):
        self.assertIn('func _build_river_relics()', self.world)
        self.assertIn('RiverMemoryRelic_%d', self.world)
        self.assertIn('river_relic_ids.append(i)', self.world)
        self.assertIn('cfg.set_value(\"progress\", \"river_relic_ids\", river_relic_ids)', self.world)
        self.assertIn('cfg.get_value(\"progress\", \"river_relic_ids\", [])', self.world)
        self.assertIn('save_version > 15', self.world)

    def test_silver_river_has_a_landmark_gate_and_navigation_props(self):
        river = self.world[self.world.index('func _build_river_region'):self.world.index('func _make_person')]
        self.assertIn('DrownedRiverGate', river)
        self.assertIn('RiverKeystone', river)
        self.assertIn('RiverRuinRubble', river)
        self.assertIn('RiverWaystone', river)
        self.assertIn('keystone_light.omni_range = 7.0', river)

    def test_river_astrolabe_has_three_rotating_interactive_rings(self):
        self.assertIn('func _build_river_shrine_puzzle() -> void:', self.world)
        self.assertIn('TorusMesh.new()', self.world)
        self.assertIn('PuzzleRing_%d', self.world)
        self.assertIn('RIVER_PUZZLE_TARGETS := [1, 3, 2]', self.world)
        self.assertIn('river_puzzle_ring_steps[ring_index] = (river_puzzle_ring_steps[ring_index] + 1) % 4', self.world)

    def test_river_astrolabe_clue_is_attached_to_the_correct_puzzle_scene(self):
        puzzle = self.world[self.world.index('func _build_river_shrine_puzzle'):self.world.index('func _build_river_relics')]
        landmarks = self.world[self.world.index('func _build_region_landmarks'):self.world.index('func _build_swamp_region')]
        self.assertIn('clue.text = "MARÉ: I  •  III  •  II"', puzzle)
        self.assertIn('shrine.add_child(clue)', puzzle)
        self.assertNotIn('shrine.add_child(clue)', landmarks)
        self.assertIn('Vector3(0.0, 0.0, -ring_mesh.outer_radius - 0.12)', puzzle)

    def test_river_astrolabe_reward_is_once_only_and_persistent(self):
        self.assertIn('if river_shrine_solved:', self.world)
        self.assertIn('river_shrine_solved = true', self.world)
        self.assertIn('cfg.set_value("progress", "river_shrine_solved", river_shrine_solved)', self.world)
        self.assertIn('cfg.set_value("progress", "river_puzzle_ring_steps", river_puzzle_ring_steps)', self.world)
        self.assertIn('cfg.get_value("progress", "river_puzzle_ring_steps", [0, 0, 0])', self.world)
        self.assertIn('_grant_xp(60)', self.world)
        self.assertIn('dark_essence += 3', self.world)
        self.assertIn('shards += 2', self.world)


if __name__ == '__main__':
    unittest.main(verbosity=2)

class AndroidBuildContracts(unittest.TestCase):
    def test_android_export_preset_targets_arm64_and_debug_apk(self):
        preset = (ROOT / 'export_presets.cfg').read_text(encoding='utf-8')
        self.assertIn('name="Android"', preset)
        self.assertIn('export_path="build/TobiEBreu.apk"', preset)
        self.assertIn('architectures/arm64-v8a=true', preset)
        self.assertIn('package/unique_name="com.tobiebreu.darkworld3d"', preset)
        self.assertIn('gradle_build/use_gradle_build=false', preset)
        self.assertNotIn('gradle_build/min_sdk=', preset)
        self.assertNotIn('gradle_build/target_sdk=', preset)

    def test_github_actions_build_can_be_started_manually_and_uploads_apk(self):
        workflow = (ROOT / '.github/workflows/android-apk.yml').read_text(encoding='utf-8')
        self.assertIn('workflow_dispatch:', workflow)
        self.assertIn('actions/upload-artifact@v4', workflow)
        self.assertIn('build/TobiEBreu.apk', workflow)
        self.assertIn('python3 -m pip install --disable-pip-version-check Pillow', workflow)
        self.assertIn('--export-debug "Android"', workflow)
        self.assertIn('Configurar exportação Android sem Gradle', workflow)
        self.assertIn("gradle_build/min_sdk", workflow)
        self.assertIn("gradle_build/target_sdk", workflow)

    def test_github_actions_detects_project_at_root_or_in_subfolder(self):
        workflow = (ROOT / '.github/workflows/android-apk.yml').read_text(encoding='utf-8')
        self.assertIn('Locate Godot project (repository root or subfolder)', workflow)
        self.assertIn('if [ -f "$GITHUB_WORKSPACE/project.godot" ]', workflow)
        self.assertIn('find extracted -name project.godot', workflow)
        self.assertIn('PROJECT_PATH=', workflow)
        self.assertIn('python3 -m unittest discover', workflow)
        self.assertIn('tools/validate_project.py', workflow)

    def test_world_has_expanded_exploration_space_and_branch_trails(self):
        world = (ROOT / 'scripts/world.gd').read_text(encoding='utf-8')
        self.assertIn('plane.size = Vector2(700, 700)', world)
        self.assertIn('shape.size = Vector3(700, 1, 700)', world)
        self.assertIn('func _build_open_world_expansion() -> void:', world)
        self.assertIn('WildernessTrail_%02d', world)
        self.assertIn('OuterMountain_%02d', world)



class OpenWorldBiomeContracts(unittest.TestCase):
    def test_outer_world_builds_all_major_biomes(self):
        world = (Path(__file__).resolve().parents[1] / "scripts" / "world.gd").read_text()
        self.assertIn("_build_outer_regions()", world)
        for region in ("AncientForest", "FrozenMountain", "RedGorge", "ForgottenRuins", "GoldenPlains", "HeartTemplePlateau", "CloudSummit"):
            self.assertIn(region, world)
        self.assertIn("func _build_biome_patch", world)
        self.assertIn("func _add_region_title", world)

    def test_outer_world_has_connected_roads_and_navigation_titles(self):
        world = (Path(__file__).resolve().parents[1] / "scripts" / "world.gd").read_text()
        self.assertIn("OuterWorldRoad_", world)
        for title in ("FLORESTA ANCESTRAL", "MONTANHA GELADA", "DESFILADEIRO RUBRO", "RUÍNAS ANTIGAS", "PLANÍCIE DOURADA", "TEMPLO DO CORAÇÃO", "CUME DAS NUVENS"):
            self.assertIn(title, world)


class WorldContentExpansionContracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.world = (ROOT / 'scripts/world.gd').read_text(encoding='utf-8')

    def test_world_builds_two_settlements_and_guild_hall(self):
        self.assertIn('_build_settlement("VilaDoCarvalho"', self.world)
        self.assertIn('_build_settlement("CidadeDePedra"', self.world)
        self.assertIn('func _build_guild_hall(', self.world)
        self.assertIn('GUILDA DOS VIGIAS', self.world)

    def test_world_contains_cave_dungeon_and_castle_sectors(self):
        for name in ['CAVERNA DO ECO', 'MASMORRA DAS CINZAS', 'CASTELO DO SILÊNCIO']:
            self.assertIn(name, self.world)

    def test_guild_contract_requires_three_persistent_relics(self):
        self.assertIn('guild_relic_ids.size() >= 3', self.world)
        self.assertIn('cfg.set_value("progress", "guild_relic_ids", guild_relic_ids)', self.world)
        self.assertIn('cfg.get_value("progress", "guild_relic_ids", [])', self.world)
        self.assertIn('guild_contract_started', self.world)
        self.assertIn('guild_contract_claimed', self.world)

    def test_civilized_world_sector_is_built_before_npcs_and_player(self):
        self.assertIn('_build_world_civilization()', self.world)
        self.assertLess(self.world.index('_build_world_civilization()'), self.world.index('_build_player()'))

class ProceduralTextureContracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        root = Path(__file__).resolve().parents[1]
        cls.world = (root / 'scripts/world.gd').read_text(encoding='utf-8')
        cls.shader = (root / 'scripts/painter_material.gdshader').read_text(encoding='utf-8')

    def test_shader_has_distinct_surface_patterns(self):
        for mode in ('pattern_mode == 1', 'pattern_mode == 2', 'pattern_mode == 3', 'pattern_mode == 4', 'pattern_mode == 5', 'pattern_mode == 6', 'pattern_mode == 7', 'pattern_mode == 8'):
            self.assertIn(mode, self.shader)
        self.assertIn('float fbm(', self.shader)
        self.assertIn('noise_value(', self.shader)

    def test_world_assigns_surface_materials_by_object_name(self):
        self.assertIn('func _material_for_surface(', self.world)
        for surface in ('grass', 'road', 'swamp', 'wood', 'water', 'snow', 'roof', 'stone'):
            self.assertIn(f'"{surface}" in key', self.world)
        self.assertIn('mi.material_override = _material_for_surface(name, color)', self.world)

    def test_biome_patches_receive_distinct_terrain_patterns(self):
        self.assertIn('if "frozen" in region_key or "cloud" in region_key:', self.world)
        self.assertIn('elif "ruin" in region_key or "temple" in region_key or "castle" in region_key:', self.world)
        self.assertIn('elif "gorge" in region_key:', self.world)
    def test_surface_texture_atlases_are_integrated_into_painter_shader(self):
        shader = (ROOT / 'scripts/painter_material.gdshader').read_text(encoding='utf-8')
        self.assertTrue((ROOT / 'assets/textures/surface_albedo_atlas.png').is_file())
        self.assertTrue((ROOT / 'assets/textures/surface_roughness_atlas.png').is_file())
        self.assertIn('surface_albedo_atlas', shader)
        self.assertIn('surface_roughness_atlas', shader)
        from PIL import Image
        with Image.open(ROOT / 'assets/textures/surface_albedo_atlas.png') as albedo:
            albedo_size = albedo.size
        with Image.open(ROOT / 'assets/textures/surface_roughness_atlas.png') as roughness:
            roughness_size = roughness.size
        self.assertEqual(albedo_size, (2048, 1024))
        self.assertEqual(roughness_size, (2048, 1024))
        self.assertIn('texture(surface_albedo_atlas, uv_y)', shader)
        self.assertIn('texture(surface_roughness_atlas, uv_y)', shader)
        self.assertIn('set_shader_parameter("surface_albedo_atlas", SURFACE_ALBEDO_ATLAS)', self.world)
        self.assertIn('set_shader_parameter("surface_roughness_atlas", SURFACE_ROUGHNESS_ATLAS)', self.world)

    def test_surface_atlas_has_eight_biome_material_variants(self):
        shader = (ROOT / 'scripts/painter_material.gdshader').read_text(encoding='utf-8')
        for mode in range(1, 9):
            self.assertIn('pattern_mode == %d' % mode, shader)
        self.assertIn('atlas_color', shader)
        self.assertIn('atlas_roughness', shader)

    def test_surface_shader_uses_triplanar_mapping_for_vertical_geometry(self):
        self.assertIn('vec2 atlas_uv_for(vec2 world_uv, int tile_index)', self.shader)
        self.assertIn('atlas_uv_for(world_pos.zy, tile_index)', self.shader)
        self.assertIn('atlas_uv_for(world_pos.xz, tile_index)', self.shader)
        self.assertIn('atlas_uv_for(world_pos.xy, tile_index)', self.shader)
        self.assertIn('mat3(INV_VIEW_MATRIX)', self.shader)
        self.assertIn('triplanar_sharpness', self.shader)
        self.assertIn('if (tri_weights.y > 0.92)', self.shader)
        self.assertIn('Reserve full triplanar blending for angled rocks', self.shader)

    def test_surface_shader_derives_mobile_friendly_bump_detail_from_atlas(self):
        self.assertIn('uniform float bump_strength', self.shader)
        self.assertIn('float relief = dot(atlas_color', self.shader)
        self.assertIn('dFdx(VERTEX)', self.shader)
        self.assertIn('dFdy(VERTEX)', self.shader)
        self.assertIn('NORMAL = normalize(abs(determinant) * view_normal - relief_gradient * bump_strength)', self.shader)

    def test_material_factory_tunes_bump_strength_per_surface_type(self):
        world = self.world
        self.assertIn('var bump_strength := 0.16', world)
        self.assertIn('1: bump_strength = 0.10', world)
        self.assertIn('3: bump_strength = 0.20', world)
        self.assertIn('4: bump_strength = 0.24', world)
        self.assertIn('5: bump_strength = 0.035', world)
        self.assertIn('8: bump_strength = 0.22', world)
        self.assertIn('set_shader_parameter("bump_strength", bump_strength)', world)

    def test_surface_textures_are_world_anchored_not_camera_anchored(self):
        shader = (ROOT / 'scripts/painter_material.gdshader').read_text(encoding='utf-8')
        self.assertIn('INV_VIEW_MATRIX * vec4(VERTEX, 1.0)', shader)
        self.assertIn('fract(world_uv * max(brush_scale, 0.5)', shader)
        self.assertIn('atlas_uv_for(world_pos.xz, tile_index)', shader)


    def test_android_export_enables_etc2_astc_texture_import(self):
        project = (ROOT / 'project.godot').read_text(encoding='utf-8')
        self.assertIn('textures/vram_compression/import_etc2_astc=true', project)

    def test_main_menu_is_the_game_entry_point_and_keeps_story_world(self):
        project = (ROOT / 'project.godot').read_text(encoding='utf-8')
        menu = (ROOT / 'scripts/main_menu.gd').read_text(encoding='utf-8')
        menu_scene = (ROOT / 'scenes/menu.tscn').read_text(encoding='utf-8')
        self.assertIn('run/main_scene="res://scenes/login.tscn"', project)
        login = (ROOT / 'scripts/login_screen.gd').read_text(encoding='utf-8')
        lobby = (ROOT / 'scripts/friends_lobby.gd').read_text(encoding='utf-8')
        self.assertIn('MENU_SCENE := "res://scenes/menu.tscn"', login)
        self.assertIn('Entrar com Google', login)
        self.assertIn('JOGAR OFFLINE COMO VISITANTE', login)
        self.assertIn('res://assets/ui/dark_world_key_art.svg', login)
        self.assertIn('SALÃO DOS AVENTUREIROS', lobby)
        self.assertIn('MAX_PLAYERS := 4', lobby)
        self.assertIn('res://assets/ui/lobby_art.svg', lobby)
        self.assertIn('res://assets/ui/loading_art.svg', (ROOT / 'scripts/world.gd').read_text(encoding='utf-8'))
        self.assertIn('const STORY_SCENE := "res://scenes/main.tscn"', menu)
        self.assertIn('func _start_story()', menu)
        self.assertIn('MODO HISTÓRIA', menu)
        self.assertIn('HISTÓRIA COOPERATIVA', menu)
        self.assertIn('MULTIPLAYER', menu)
        self.assertIn('AMIGOS', menu)
        self.assertIn('scripts/main_menu.gd', menu_scene)

    def test_supabase_autoload_uses_valid_godot_ini_section(self):
        project = (ROOT / 'project.godot').read_text(encoding='utf-8')
        self.assertIn('[autoload]\n', project)
        self.assertIn('SupabaseClient="*res://scripts/supabase_client.gd"', project)
        self.assertNotIn(r'[autoload]\nSupabaseClient', project)

    def test_prologue_cutscene_is_shown_once_and_persisted(self):
        world = (ROOT / 'scripts/world.gd').read_text(encoding='utf-8')
        self.assertIn('func _play_prologue_cutscene()', world)
        self.assertIn('await _play_prologue_cutscene()', world)
        self.assertIn('cfg.set_value("story", "prologue_seen", story_intro_seen)', world)
        self.assertIn('Era uma vez, um coração de luz', world)
        self.assertIn('O CORAÇÃO ROUBADO', world)

    def test_chapter_three_memory_quest_and_temple_boss_are_persisted(self):
        self.assertIn('quest_stage = 15', self.world)
        self.assertIn('chapter3_memory_ids.size() >= 3', self.world)
        self.assertIn('cfg.set_value("progress", "chapter3_memory_ids", chapter3_memory_ids)', self.world)
        self.assertIn('ChapterThreeMemory_%d', self.world)
        self.assertIn('func _play_chapter_cutscene(', self.world)
        self.assertIn('Guardiã do Templo', self.world)
        self.assertIn('Guardiao_do_Templo', self.world)
        self.assertIn('quest_stage == 18', self.world)
        self.assertIn('"save_version", 15', self.world)
        self.assertIn('quest_stage = clampi(int(cfg.get_value("progress", "quest_stage", 0)), 0, 20)', self.world)

    def test_supabase_lobby_room_and_friend_flows_are_connected(self):
        client = (ROOT / 'scripts/supabase_client.gd').read_text(encoding='utf-8')
        lobby = (ROOT / 'scripts/friends_lobby.gd').read_text(encoding='utf-8')
        self.assertIn('func create_game_room(', client)
        self.assertIn('func join_room_by_code(', client)
        self.assertIn('func list_room_members(', client)
        self.assertIn('func find_profile_by_username(', client)
        self.assertIn('func send_friend_request(', client)
        self.assertIn('func list_friend_requests(', client)
        self.assertIn('func respond_friend_request(', client)
        self.assertIn('SupabaseClient.create_game_room', lobby)
        self.assertIn('SupabaseClient.join_room_by_code', lobby)
        self.assertIn('SupabaseClient.list_room_members', lobby)
        self.assertIn('_search_and_add_friend', lobby)
        self.assertIn('_respond_to_friend_request', lobby)

    def test_online_menu_is_honest_about_unconfigured_services_and_four_player_cap(self):
        menu = (ROOT / 'scripts/main_menu.gd').read_text(encoding='utf-8')
        self.assertIn('const MAX_ADVENTURE_PLAYERS := 4', menu)
        self.assertIn('login falso', menu)
        self.assertIn('ainda não está ativa', menu)
