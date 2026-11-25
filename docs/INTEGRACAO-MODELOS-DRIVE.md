# Integração dos modelos enviados pelo Drive

## Conteúdo importado

- 17 modelos 3D convertidos e validados em GLB.
- 11 modelos/peças são instanciados no Bairro dos Artesãos: casas medievais, casas de fantasia, torres, plataforma e ponte.
- As variantes LOD continuam no pacote para uso futuro, mas não são colocadas como cópias lado a lado no mapa.
- 9 billboards transparentes de castanheira ficam no pacote de runtime e formam o bosque ao redor do bairro.
- 142 texturas de referência ficam preservadas em `assets/textures/user_submitted_source/` e são excluídas do APK Android para evitar carregar imagens que não são usadas diretamente pelo jogo.

## Integração visual

- `_apply_dream_biome_tint()` duplica os materiais importados, preserva os mapas albedo e aplica um leve ajuste frio/esmeralda, além de elevar discretamente a rugosidade.
- As castanheiras usam billboards com máscara alpha suave derivada do fundo branco dos TIFFs, alpha scissor e sem sombras dinâmicas, para reduzir custo no Android.
- O bairro é aditivo e fica separado das vilas originais; a integração não substitui mapas, missões, HUD, personagens ou saves.

## Formatos e limitações

O importador converte FBX, OBJ, 3DS, DAE, X3D, BLEND e USDZ para GLB. Os arquivos proprietários `.max`, `.ma`, `.mb`, `.vob` e `.xfr` não são convertidos por este pipeline. Para integrá-los como modelos 3D, é necessário exportá-los no aplicativo de origem para FBX, GLB ou OBJ.

## Verificações

O workflow Android importa os recursos do Godot, abre `res://scenes/main.tscn` em modo headless e verifica o carregamento dos 11 modelos e dos 9 billboards. A verificação headless confirma carregamento e instanciação; escala, orientação, colisões e aparência final ainda precisam de inspeção visual no jogo/dispositivo.
