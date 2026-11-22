# Packs 3D externos — Tobi e Breu

Esta pasta recebe modelos 3D baixados de bibliotecas externas. O jogo usa Godot 4 e aceita principalmente **GLB/GLTF**.

## Pastas

Extraia os modelos para pastas separadas, preservando os arquivos de textura que acompanham cada modelo:

- `assets/external_packs/ashen_marches/`
- `assets/external_packs/dungeon_remastered/`
- `assets/external_packs/ultimate_dungeon/`

Não coloque arquivos ZIP dentro dessas pastas. Extraia primeiro e mantenha as licenças/atribuições junto dos modelos.

## Packs selecionados

### Ashen Marches — 100 modelos

Página oficial: https://chilllands.itch.io/ashen-marches-free

A edição gratuita anuncia 100 modelos, 20 personagens/animais/criaturas animados e 124 clipes. Inclui uma edição Godot e arquivos GLB/FBX. A página informa uso pessoal e comercial gratuito. É o melhor candidato para começar porque combina fantasia sombria estilizada e já oferece projeto Godot.

### Dungeon Remastered (KayKit) — 203 modelos

Página de download: https://www.tyrbo.ai/free-game-assets/kaykit-dungeon-remastered

203 modelos de masmorra em GLB/OBJ, incluindo paredes, pisos, escadas, pilares, bandeiras, barris, baús, mesas, velas, tochas, moedas e chaves. A página informa CC0 1.0 e download de 6,4 MB; exige conta gratuita no Tyrbo.

### Ultimate Dungeon Pack — 34 modelos

Página oficial: https://sotudios.com/Assets/Ultimate-DungeonPack/

34 props dark-fantasy, GLB + FBX, mapas PBR 2K e licença CC BY 4.0 (dar crédito). O arquivo completo tem **1,1 GiB**; por isso não é enviado automaticamente para o GitHub nem baixado durante a configuração.

## Importação para o jogo

1. Baixe o pack no site oficial e confira o arquivo de licença.
2. Extraia os arquivos para a pasta correspondente acima.
3. Abra o projeto no Godot e aguarde a importação dos modelos.
4. Use `ExternalAssetPackLoader.list_models("ashen_marches")` para listar os GLB/GLTF disponíveis.
5. Use `ExternalAssetPackLoader.instantiate_by_name(...)` ou `instantiate_model(...)` para colocar um modelo numa cena.

O loader não baixa arquivos sozinho e não contorna logins/licenças. Os modelos só aparecem no jogo depois de baixados e colocados nas pastas do projeto.

## Créditos e licenças

- Ashen Marches: seguir a licença incluída no pacote e manter os créditos solicitados pelo autor.
- Dungeon Remastered: CC0 1.0 conforme a página de distribuição.
- Ultimate Dungeon Pack: CC BY 4.0; manter atribuição.

Os arquivos originais permanecem sob as licenças dos respectivos autores. Não redistribua os ZIPs fora dos termos de cada licença.
