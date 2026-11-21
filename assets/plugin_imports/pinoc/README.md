# PINOC — animações e cenário

Nomes de arquivo esperados:
- `walking.glb`
- `running.glb`
- `dodge_roll.glb`
- `cast_spell.glb`
- `hit_reaction.glb`
- `forest_scarlet.spz`

As animações Mixamo precisam ser retargetadas ao esqueleto do Tobi antes de entrar no AnimationPlayer. O SPZ requer um renderer Gaussian Splat compatível; o projeto usa Godot 4.3 com GL Compatibility, então não deve ser instanciado como malha comum.
