# Dark Fantasy Asset Bridge

Plugin de editor Godot 4.3 instalado em `addons/dark_fantasy_asset_bridge`.

## O que faz
- Adiciona um painel no dock direito do editor.
- Verifica se os arquivos exportados do Aqueduct, Meshy e PINOC estão nas pastas esperadas.
- Diferencia arquivos presentes de arquivos que ainda precisam ser copiados.
- Não baixa arquivos automaticamente e não altera assets ausentes.

## Pastas esperadas
- Aqueduct: `assets/plugin_imports/aqueduct/`
- Meshy: `assets/plugin_imports/meshy/`
- PINOC: `assets/plugin_imports/pinoc/`

## Segurança de integração
Os GLBs do PINOC precisam ser retargetados para o esqueleto do Tobi antes de substituir as animações procedurais. O SPZ do cenário precisa de um renderer Gaussian Splat compatível com Godot 4.3 e GL Compatibility. O painel apenas verifica presença; não finge que formatos incompatíveis já estão funcionando.

Abra o projeto no Godot e use o dock **Asset Bridge** para conferir os arquivos.
