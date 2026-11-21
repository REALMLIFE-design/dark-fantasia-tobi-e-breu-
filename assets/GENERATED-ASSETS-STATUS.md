# Estado dos ativos 3D externos — 21/11/2026

Este documento separa ativos gerados de ativos realmente incorporados ao projeto Godot.

## Bosque da Cicatriz Rubra — PINOC

- Asset ID: `eb40a681-9845-57bd-9e3e-52a740a82fc9`
- Árvore colossal game-ready gerada no Thrixel: 14.132 triângulos; GLB leve com texturas até 1024 px — [baixar modelo](https://api.thrixel.com/api/v1/51f95b5b-9fc4-419f-96ca-c45b68dc4697/download?format=glb&quality=lite&texture_size=1024).
- Tipo: cena de ambiente em Gaussian Splat (`.spz`)
- Estado: geração concluída; três expansões manuais de geometria/visibilidade concluídas (14 créditos PINOC no total: 5 da cena + 3 × 3).
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
- Estado: grafo existente inspecionado; a prévia de material falhou por erro do executor, mas a exportação de pacote foi concluída com sucesso.
- Mapas exportados: base color, normal, roughness, height (16-bit) e AO, PNG 1024×1024, em pacote ZIP.
- Integração no jogo: pendente de transferência dos PNGs para `assets/` e validação do material no Godot.

## Santuário Esquecido — Godot

- A versão procedural existente foi aprimorada com três fragmentos rubros flutuantes e pulsação suave da runa e da luz.
- A interação, o checkpoint e a persistência do save foram preservados.
- O efeito usa malhas simples e tweens nativos para manter custo baixo em dispositivos móveis.

### Atualização de validação — 21/11/2026

- PINOC confirmou a conclusão da expansão `14f94909-4915-4a56-9457-32f9c963acb8`; o ambiente está disponível como `splat-raw` (`.spz`), eixo vertical informado `-y`.
- O link assinado de download é temporário e não deve ser embutido em arquivos permanentes do jogo.
- Thrixel confirmou que a árvore possui 14.132 triângulos em uma única malha. O saldo atual da conta é zero; operações gratuitas de redução de triângulos/transformação continuam disponíveis, mas não há créditos para gerar novas texturas ou modelos.
- Nenhum desses dois arquivos externos foi incorporado ao projeto Godot nesta rodada; o ambiente SPZ exige runtime compatível e a árvore ainda depende de transferência do GLB para o repositório.


## Integração de arquivos auxiliares dos plugins — 21/11/2026

- Criado `scripts/plugin_asset_loader.gd`: carregador opcional para o GLB do Meshy e aplicação segura do material Aqueduct. Ele verifica a existência dos arquivos antes de usá-los.
- Criado `scripts/aqueduct_stone.gdshader`: shader PBR leve com base color, normal OpenGL, roughness e AO; não usa deslocamento por height no renderer Compatibility móvel.
- Criado `assets/plugin_imports/README.md`: mapa de destino e instruções para os arquivos originais dos plugins.
- O portão procedural agora tenta aplicar o material Aqueduct nos detalhes de pedra quando os quatro mapas forem colocados no caminho esperado.
- O GLB Meshy permanece opcional e não é instanciado automaticamente porque escala, pivô e colisões ainda precisam de conferência.
- Os nove clipes PINOC continuam como fontes para retarget; não foram ligados ao Tobi porque o rig X Bot é diferente do rig procedural atual.
- Limitação de transferência nesta sessão: os links dos binários foram renovados, mas o ambiente de execução não conseguiu baixar os arquivos dos hosts externos (falha de rede/DNS). Portanto, os binários GLB, SPZ e PNG ainda não estão fisicamente no repositório nem no APK. Não declarar essa etapa como concluída.
