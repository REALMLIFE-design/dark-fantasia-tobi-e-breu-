# Meshy — modelos 3D gerados para Tobi e Breu

## Recursos preservados

| Recurso | Task de geometria | Task de textura | Estado |
|---|---|---|---|
| Obelisco rúnico | `01a20014-96e3-743e-ae07-354d22b8557e` | `01a20014-fcbc-770c-b0e4-a7c027e9d5e6` | Texturizado; exportação GLB bloqueada pelo plano |
| Altar/santuário de pedra | `01a1ffc0-a9b2-7084-8575-2ac3e71c28bd` | `01a1ffc1-4452-7384-9c4c-4a81ece4fc4a` | Texturizado; exportação GLB bloqueada pelo plano |
| Portão gótico amaldiçoado | `01a1ff11-8f0a-76a1-a977-29e97e2f1e44` | `01a1ff12-3dd2-707a-8c0e-016625d9d9d5` | Texturizado; exportação GLB bloqueada pelo plano |
| Novo Tobi | `01a20055-e96f-7732-8d09-8fd8e962bc5c` | `01a20058-ae2b-72a1-b2e6-52a6120cc2cf` | Geometria e textura concluídas; exportação GLB bloqueada pelo plano |

O novo Tobi usa geometria `meshy-t2.5`, 15.000 faces-alvo e textura `meshy-6-lite`. O gasto autorizado para essa criação foi de 15 créditos no total (5 geometria + 10 textura).

## Caminhos de importação esperados

- `gothic_gate.glb`
- `rune_obelisk.glb`
- `stone_way_shrine.glb`
- `tobi_hero.glb`

O carregador opcional está em `res://scripts/plugin_asset_loader.gd`. Os modelos precisam ser exportados e conferidos em escala, pivô, materiais, rig e colisões antes de substituir qualquer construção procedural. A ferramenta Meshy respondeu `Please upgrade plan to download models`; nenhum GLB foi copiado nesta etapa. Os modelos continuam preservados na conta Meshy.
