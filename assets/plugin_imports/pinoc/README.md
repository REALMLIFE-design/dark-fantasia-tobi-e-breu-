# PINOC — animações e cenário

## Catálogo de animações

O inventário atual contém 24 clipes selecionados na biblioteca PINOC. A lista de IDs e funções está em `motion_catalog.json`.

Os arquivos GLB devem ser colocados em `animations/` com os nomes registrados em `scripts/plugin_asset_catalog.gd`:
- `walking.glb`, `running.glb`, `dodge_roll.glb`, `cast_spell.glb`
- `hit_reaction.glb`, `sword_idle.glb`, `jump.glb`, `block.glb`
- `carry_walk.glb`, `crawl.glb`, `crouch_walk.glb`, `injured_walk.glb`
- `run_jump.glb`, `sprint.glb`, `walk_backwards.glb`, `strafe_left.glb`

## Integração

Os GLBs Mixamo incluem o X Bot e um esqueleto com nomes Mixamo. É necessário retarget para o rig procedural do Tobi e validar escala, root motion e orientação antes de substituir qualquer animação atual. O catálogo e os caminhos estão preparados; os binários ainda precisam ser baixados e importados.

## Cenário

O ambiente `forest_scarlet.spz` requer um renderer Gaussian Splat compatível. O projeto usa Godot 4.3 com GL Compatibility, então o SPZ não deve ser instanciado como malha comum.
