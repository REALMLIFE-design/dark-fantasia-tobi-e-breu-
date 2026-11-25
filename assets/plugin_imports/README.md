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

## Thrixel — modelos 3D do jogo

O workflow importa e versiona sete GLBs do projeto Thrixel em `assets/plugin_imports/thrixel/`: árvore colossal, guardião-cervo, caranguejo do rio, espectro afogado, obelisco otimizado, altar otimizado e baú otimizado. O manifesto `THRIXEL-ASSET-MANIFEST.json` registra submissão, triângulos, resolução de textura e função no jogo.

Os modelos estáticos multipartes foram agrupados para reduzir draw calls, mantendo os anéis do obelisco, a alavanca/gaveta do altar e a tampa do baú como peças separadas. Os inimigos usam os GLBs rigged nos encontros opcionais do mundo. O baú aparece nas três recompensas exploratórias do Rio Prateado.

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

## Filtro de bioma Aqueduct

O shader Aqueduct também aplica uma camada procedural de musgo frio-esmeralda nos modelos estáticos selecionados. Ele preserva mapas PBR e reduz o efeito em metais e materiais emissivos. O grafo-fonte está em `aqueduct/stone_moss_material.toml`.

## Conteúdo novo inspirado nos plugins

O construtor `PluginInspiredWorldExpansion` em `scripts/world.gd` adiciona o Santuário do Poço Lunar, o Posto da Vigia Caída, sete marcos rúnicos e três tochas de trilha. São modelos procedurais leves para Android, inspirados na direção de arte dos assets Meshy, Aqueduct e PINOC. Eles entram no carregamento do mundo enquanto os arquivos binários originais ainda dependem de exportação/importação.
