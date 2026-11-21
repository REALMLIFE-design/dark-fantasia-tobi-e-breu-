# Arquivos de integração dos plugins — Tobi e Breu

Esta pasta é o destino permanente dos recursos baixados dos plugins. Os nomes abaixo são os nomes esperados pelo carregador do jogo.

## Aqueduct — material de pedra

Copiar os PNGs exportados para `assets/plugin_imports/aqueduct/` com estes nomes:

- `base_color.png`
- `normal.png` (formato OpenGL)
- `roughness.png`
- `ao.png`
- `height.png` (guardado para futura etapa; não usado no shader móvel atual)

O shader `scripts/aqueduct_stone.gdshader` aplica base color, normal, roughness e AO. O mapa height fica de fora para evitar deslocamento caro/incompatível no renderer Compatibility do Android. Quando os quatro mapas principais existirem, os detalhes de pedra do portão gótico recebem o material automaticamente.

## Meshy — portão gótico

Colocar o GLB em `assets/plugin_imports/meshy/gothic_gate.glb`. O carregador oferece `load_meshy_gate(parent, position, scale)`, mas o modelo não é instanciado automaticamente: escala, pivô e colisões precisam ser conferidos antes de substituir a entrada procedural.

## PINOC — animações

As nove animações Mixamo (X Bot) ficam em `assets/plugin_imports/pinoc/animations/` depois do retarget. Elas não são ligadas diretamente ao Tobi porque o personagem atual usa um rig procedural diferente. Arquivos originais preservados como fonte para retarget:

- Cast Spell Forward
- Dodge Roll Forward
- Sword Idle
- Hit Reaction Front
- Walking
- Running
- Jump
- Fighting Stance Idle
- Drawing Sword

## PINOC — Bosque da Cicatriz Rubra

O ambiente é Gaussian Splat SPZ, com eixo vertical `-y`. Não é uma malha GLB. O projeto atual usa Godot 4.3 + GL Compatibility; não o adicionamos à cena principal até validar um importador/runtime SPZ compatível com Android e o renderer atual.

Nenhum link temporário assinado é armazenado neste repositório. Isso evita que o jogo dependa de URLs que expiram.
