# Estado dos ativos 3D externos — 21/11/2026

Este documento separa ativos gerados de ativos realmente incorporados ao projeto Godot.

## Bosque da Cicatriz Rubra — PINOC

- Asset ID: `eb40a681-9845-57bd-9e3e-52a740a82fc9`
- Tipo: cena de ambiente em Gaussian Splat (`.spz`)
- Estado: geração concluída; primeira expansão de geometria/visibilidade concluída.
- Limitação: o arquivo SPZ não é uma malha GLB/FBX e não pode ser importado diretamente pelo pipeline Godot atual. Requer um renderizador compatível com Viggle Splat Engine ou uma etapa de conversão suportada.
- Integração no jogo: pendente. Não referenciar o arquivo SPZ em cenas Godot até existir suporte de runtime validado.

## Santuário de Pedra Rúnica — Meshy

- Preview task: `01a1ffc0-a9b2-7084-8575-2ac3e71c28bd`
- Textura task: `01a1ffc1-4452-7384-9c4c-4a81ece4fc4a`
- Geometria: smart topology, aproximadamente 4.000 faces solicitadas.
- Estado: geração e texturização concluídas.
- Limitação: o download GLB foi bloqueado pelo plano Meshy atual.
- Integração no jogo: pendente. O santuário procedural existente continua como fallback funcional; não alegar que o modelo Meshy está dentro do APK.

## Material PBR de pedra — Aqueduct

- Projeto: `0931f547-7cd7-40af-a785-d6ddf642c7ce`
- Nome: Tobi e Breu — Materiais PBR Dark Fantasy
- Mapas definidos: base color, normal, roughness, height e AO.
- Estado: grafo existente inspecionado; a prévia de material falhou por erro do executor de renderização.
- Integração no jogo: pendente até exportação e validação dos mapas.

## Santuário Esquecido — Godot

- A versão procedural existente foi aprimorada com três fragmentos rubros flutuantes e pulsação suave da runa e da luz.
- A interação, o checkpoint e a persistência do save foram preservados.
- O efeito usa malhas simples e tweens nativos para manter custo baixo em dispositivos móveis.
