# Aqueduct — pedra esmeralda com musgo

O projeto Aqueduct `Tobi e Breu — Materiais PBR Dark Fantasy` usa um grafo procedural de 1024×1024, guardado em `stone_moss_material.toml`.

- Base color: pedra azul-ardósia escura com mistura de pigmento verde.
- Moss mask: ruído Simplex + threshold; manchas discretas, sem cobrir os relevos.
- Normal: OpenGL.
- Roughness e AO: derivados da altura.
- Export concluído em PNG: base color, normal, roughness, AO e height (height fica fora do shader móvel).

O pacote PBR foi gerado no Aqueduct. Como a transferência binária do ZIP ainda não foi concluída, `scripts/aqueduct_stone.gdshader` reproduz a camada de musgo proceduralmente e continua aceitando os quatro mapas reais quando forem colocados nesta pasta:

- `base_color.png`
- `normal.png`
- `roughness.png`
- `ao.png`

O shader mantém albedo, normal, rugosidade, metalness, AO e emissão originais dos GLBs quando usado como filtro; metais e superfícies emissivas recebem menos musgo.
