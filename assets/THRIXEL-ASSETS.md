# Assets 3D externos — Thrixel

## Árvore Anciã
- Submission ID: `51f95b5b-9fc4-419f-96ca-c45b68dc4697`
- Arquivo pretendido: `ancient_tree.glb`
- Tamanho alvo: 16 m
- Geometria: 14.132 triângulos, 1 malha
- Textura: 1024 px
- Projeto Thrixel: `Tobi e Breu — Dark World 3D`
- Download GLB: https://api.thrixel.com/api/v1/51f95b5b-9fc4-419f-96ca-c45b68dc4697/download?format=glb&quality=full&texture_size=1024
- Estado: gerado e disponível no projeto Thrixel; exportação para a pasta Godot pendente porque o endpoint de download não ficou acessível ao ambiente de arquivos desta sessão.

Ao transferir o GLB, colocar neste diretório e instanciar como `GLTFDocument`/`PackedScene` na região da Árvore Anciã. Conferir escala e colisão no Godot antes de marcar como integrado.

## Espectro Afogado — 2026-11-20
- Submission: `d57d171c-5047-43fb-ba11-f1e1f33c448c`
- Estilo: referência visual da Árvore Anciã do mesmo projeto Thrixel.
- Geometria: 9.000 triângulos, 1 mesh, eixo Y para cima.
- Dimensões reportadas: 1,4266 × 2,6 × 0,9892 m.
- Textura: 1024 px.
- Download GLB disponível pelo Thrixel; não incorporado ao diretório Godot nesta versão porque a transferência do arquivo não ficou acessível neste ambiente.


## Variantes PBR painterly — 2026-11-20

### Árvore Anciã — textura original
- Submission: `584d17cf-92ff-4fde-ba50-19037a88d832` (derivada da árvore original).
- 14.132 triângulos, geometria preservada; download GLB 1024 px estimado em 2,8 MB.
- Download: https://api.thrixel.com/api/v1/584d17cf-92ff-4fde-ba50-19037a88d832/download?format=glb&quality=full&texture_size=1024
- Textura painterly de casca umber, musgo e veios carmesim discretos. Ainda não integrada ao diretório Godot.

### Espectro Afogado — textura original
- Submission: `f4d8f433-7cd2-45b1-80dd-a157ba5ce26e` (derivada do espectro original).
- 9.000 triângulos, geometria preservada; download GLB 1024 px estimado em 2,1 MB.
- Download: https://api.thrixel.com/api/v1/f4d8f433-7cd2-45b1-80dd-a157ba5ce26e/download?format=glb&quality=full&texture_size=1024
- Textura painterly de pele azul-prateada, tecido carvão e luz turquesa. Ainda não integrada ao diretório Godot.

## Astrolábio da Corrente Prateada — mecanismo interativo
- Blockout multi-peças: `cc8391a0-5058-4279-b452-36749452ab08`, 22.276 triângulos, 15 partes, com tampa articulada e alavanca.
- Textura painterly PBR: `3ec3e3e0-e234-4ee1-942a-13391b648107`.
- Download GLB 1024 px estimado em 4,0 MB: https://api.thrixel.com/api/v1/3ec3e3e0-e234-4ee1-942a-13391b648107/download?format=glb&quality=full&texture_size=1024
- A cena Godot atual usa um protótipo procedural interativo com três anéis, alavanca e gaveta; o GLB Thrixel ainda aguarda transferência/importação.

## Modelos adicionais — 2026-11-20

### Cofre do Rio Prateado
- Submission: `3e100dbb-35b7-4cc5-a1aa-4c61d00efdf3`.
- 11.180 triângulos, 6 partes; tampa `hinged_lid` com pivô próprio.
- GLB 1024 px estimado em 1,3 MB.
- Download: https://api.thrixel.com/api/v1/3e100dbb-35b7-4cc5-a1aa-4c61d00efdf3/download?format=glb&quality=full&texture_size=1024
- Aguardando transferência/importação no Godot. A tampa pode ser animada na abertura do baú.

### Espectro Afogado — rig
- Submission: `c4c1cfa0-54af-4cb5-be3e-8dd8f094daa1`.
- Rig humanoide Mixamo; GLB 1024 px estimado em 2,3 MB.
- Download: https://api.thrixel.com/api/v1/c4c1cfa0-54af-4cb5-be3e-8dd8f094daa1/download?format=glb&quality=full&texture_size=1024
- Aguardando transferência/importação e retarget/animação no Godot.

### Caranguejo de Prata — criatura e rig
- Escultura: `ad3fafd4-145f-455e-943a-2d1e6ee5093b`; 9.442 triângulos, 1 mesh, 1,8 m.
- Rig: `4592675e-0e7e-491d-9d1e-a4a15eee7304`.
- GLB rigged disponível no Thrixel; transferência/importação no Godot pendente.
- O projeto já tem um protótipo procedural de combate com 6 pernas, duas pinças, núcleo mineral, telegráfico de ataque, desbloqueio no Capítulo II e recompensas. O modelo externo ainda não substitui esse protótipo.
- Download: https://api.thrixel.com/api/v1/4592675e-0e7e-491d-9d1e-a4a15eee7304/download?format=glb


## Integração automática dos modelos existentes no APK

O workflow Android tenta baixar, validar a assinatura GLB e importar seis modelos já gerados no projeto Thrixel, sem consumir novos créditos de geração:

- Guardião Cervo: `10f1f722-53d8-4ca0-b99b-e0e687bc8fec`
- Caranguejo do Rio Prateado: `4592675e-0e7e-491d-9d1e-a4a15eee7304`
- Espectro Afogado rigado: `c4c1cfa0-54af-4cb5-be3e-8dd8f094daa1`
- Árvore Anciã texturizada: `584d17cf-92ff-4fde-ba50-19037a88d832`
- Obelisco Rúnico: `07af580b-8b0e-4511-b2bd-c0164d113fc9`
- Santuário do Rio texturizado: `3ec3e3e0-e234-4ee1-942a-13391b648107`

Os arquivos são colocados em `assets/plugin_imports/thrixel/` antes da importação do Godot. Se um download falhar ou não for um GLB válido, a execução continua com os modelos procedurais já existentes; nenhum mapa, missão ou personagem é removido.
