# PINOC — animações e cenário

## Catálogo completo

O catálogo preserva os **24 clipes** obtidos da biblioteca PINOC. Os nomes, IDs de origem, papéis e caminhos permanentes estão em `motion_catalog.json`. Cada arquivo GLB esperado fica em `animations/`:

- `walking.glb` — Walking (locomotion)
- `running.glb` — Running (locomotion)
- `dodge_roll.glb` — Dodge Roll Forward (evasion)
- `cast_spell.glb` — Cast Spell Forward (skill)
- `hit_reaction.glb` — Hit Reaction Front (reaction)
- `sword_idle.glb` — Sword Idle (combat_idle)
- `jump.glb` — Jump (movement)
- `block.glb` — Block (defense)
- `bow_draw.glb` — Bow Draw And Release (ranged)
- `pick_up.glb` — Pick Up Object From Ground (interaction)
- `climb.glb` — Climb Over Ledge (traversal)
- `vault.glb` — Vault Over Obstacle (traversal)
- `stand_up.glb` — Standing Up From Back (recovery)
- `death.glb` — Death Backwards (death)
- `drawing_sword.glb` — Drawing Sword (combat)
- `fighting_stance.glb` — Fighting Stance Idle (combat_idle)
- `carry_walk.glb` — Carry Object Walk Forward (interaction)
- `crawl.glb` — Crawl Forward (stealth)
- `crouch_walk.glb` — Crouch Walk Forward (stealth)
- `injured_walk.glb` — Injured Walk (damage)
- `run_jump.glb` — Run Jump (locomotion)
- `sprint.glb` — Sprinting Forward (locomotion)
- `walk_backwards.glb` — Walk Backwards (locomotion)
- `strafe_left.glb` — Walk Strafe Left (combat)

Os GLBs Mixamo incluem o X Bot e um esqueleto com nomes Mixamo. Eles podem ser mantidos como cenas-fonte, mas precisam de retarget para o rig final do Tobi e validação de escala, orientação, root motion e transições antes de serem ligados ao gameplay. O catálogo registra os 24 sem duplicar gerações.

## Bosque da Cicatriz Rubra

- Asset PINOC: `eb40a681-9845-57bd-9e3e-52a740a82fc9`
- Arquivo esperado: `forest_scarlet.spz`
- Eixo vertical informado pelo provedor: `-y`

O ambiente é Gaussian Splat SPZ, não uma malha GLB. O projeto atual usa Godot 4.3 + GL Compatibility; portanto o SPZ deve ser preservado como fonte e não instanciado como malha comum. Só deve entrar no runtime depois de validar um renderer/conversor compatível com Android.

## Estado de transferência

Os IDs e caminhos estão catalogados. Os links PINOC são temporários e o ambiente de execução desta sessão não conseguiu copiar os binários para o repositório. Nenhum link assinado expirável foi gravado nos arquivos do jogo.
