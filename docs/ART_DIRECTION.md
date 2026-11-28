# Direção de arte — Tobi e Breu

## Identidade visual
Fantasia sombria pintada à mão: silhuetas legíveis, formas orgânicas, paleta terrosa fria e acentos mágicos quentes. O mundo deve parecer ilustrado, não uma coleção de primitivas de protótipo.

## Regras de produção
- Personagens e criaturas têm silhueta própria; não substituir modelos por formas genéricas.
- Cenários usam camadas: primeiro plano com detalhe, área jogável limpa e fundo com silhuetas atmosféricas.
- Cada bioma tem paleta, material e landmark próprios.
- Luzes emissivas são acentos de foco, não iluminação global excessiva.
- Detalhes decorativos nunca bloqueiam caminhos, colisões ou interação.
- Android: priorizar meshes reutilizáveis, materiais compartilhados e poucos efeitos simultâneos.
- Não apagar conteúdo antigo, missões, checkpoints, saves ou cenas funcionais durante uma revisão visual.

## Estrutura de arte planejada
assets/art/characters — modelos, texturas e referências de Tobi, Breu e NPCs
assets/art/creatures — inimigos, chefes e variações
assets/art/environments — conjuntos por bioma
assets/art/props — ruínas, lanternas, baús, altares e itens
assets/art/materials — materiais compartilhados e mapas PBR
assets/art/vfx — runas, impactos, magia e ambiente
assets/art/ui — ícones, molduras e interface
assets/art/source — fontes originais intocadas
scenes/characters, scenes/creatures, scenes/environments, scenes/props
scripts/art — geradores e utilitários visuais, separados da lógica

## Estado desta revisão
A primeira correção visual recupera árvores com tronco afunilado, raízes expostas, galhos e copas em camadas. É uma melhoria de silhueta de baixo custo; não substitui os modelos e texturas originais que ainda precisam ser incorporados. A lógica de gameplay continua no script de mundo existente e não foi removida.
