# Biblioteca 3D Dark Fantasy — Tobi e Breu

Integração preparada na branch `integration/definitive-all-versions`.

## Seleção inicial

| Pack | Conteúdo | Formatos | Licença / condição |
|---|---:|---|---|
| Ashen Marches | 100 modelos; 20 animados; 124 clipes | GLB, FBX, BLEND; projeto Godot | Gratuito para uso pessoal e comercial, conforme licença incluída |
| Dungeon Remastered (KayKit) | 203 peças de masmorra | GLB, OBJ, PNG | CC0 1.0; download exige conta gratuita |
| Ultimate Dungeon Pack (Sotudios) | 34 props dark-fantasy, mapas PBR 2K | GLB, FBX | CC BY 4.0; 1,1 GiB; atribuição obrigatória |

## Plano de uso no jogo

- Ashen Marches: aldeia, NPCs, animais, criaturas e animações.
- Dungeon Remastered: paredes, pisos, escadas, pilares, baús, tochas, mobiliário e decoração de masmorra.
- Ultimate Dungeon: altares, obeliscos, círculos rúnicos, relíquias e decoração de dungeon dark-fantasy.

## Estado real da integração

- [x] Catálogo dos packs e licenças documentado.
- [x] Loader Godot criado para procurar e instanciar GLB/GLTF colocados em `assets/external_packs/`.
- [ ] Arquivos binários originais baixados e adicionados ao projeto.
- [ ] Modelos posicionados no mundo e testados no Android.

**Importante:** os arquivos originais não foram adicionados nesta alteração. O Ultimate Dungeon Pack pesa 1,1 GiB e os outros packs exigem download no site de origem. Não afirmar que os modelos já estão dentro do APK até concluir a etapa de download/importação.
