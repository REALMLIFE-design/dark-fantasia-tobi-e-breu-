# Integração dos modelos enviados pelo Drive

Data da importação: 2026-11-25

## Resultado

- 17 arquivos GLB válidos no pacote `assets/external_packs/user_submitted/`.
- Os modelos são carregados pelo bairro `BairroDosArtesaosImportado` em `scripts/world.gd`.
- A integração é aditiva: as vilas, cidades, mapas, personagens, missões, HUD e saves existentes são preservados.
- Os materiais dos modelos recebem um ajuste discreto de tonalidade fria e aumento leve de rugosidade em `_apply_dream_biome_tint`, para aproximar madeira e pedra da paleta esmeralda/lavanda do mundo.
- 142 texturas otimizadas permanecem preservadas como referências em `assets/textures/user_submitted_source/`; não são incluídas no APK enquanto não forem identificadas e associadas com segurança aos materiais correspondentes.
- As imagens opacas de billboard não são usadas como árvores 2D. O cenário recebe nove castanheiras low-poly para evitar placas retangulares artificiais.

## Compatibilidade de formatos

O importador tenta formatos alternativos por modelo (FBX, OBJ e 3DS quando disponíveis), remove exports GLB vazios e valida o cabeçalho GLB.

O LOD0 da casa fantástica não pôde ser exportado com os arquivos de origem disponíveis. Para manter o ponto de carregamento no mapa sem deixar uma construção ausente, foi criado `lod0_fantasy_house_fallback_from_lod1.glb` a partir do LOD1 válido. O LOD1 original permanece preservado.

## Validação

- Importação do Drive, conversão, otimização e validação do pacote concluídas com sucesso.
- 17 de 17 GLBs válidos no relatório da importação.
- O teste de mundo 3D do Godot e o teste de instalação/abertura Android são executados separadamente no workflow de APK.
- Escala, orientação, colisões e aparência final ainda exigem inspeção visual no jogo em dispositivo físico.
