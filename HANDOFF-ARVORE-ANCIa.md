# Handoff técnico — Árvore Anciã (Meshy → Godot)

## Objetivo
Concluir a importação do modelo 3D da Árvore Anciã na Floresta Ancestral do jogo **Tobi e Breu — Dark World**, sem substituir o fallback procedural até a validação do GLB.

## Estado real
- A geometria e a textura PBR foram geradas com sucesso na conta Meshy **Higor**.
- Geometria: `meshy-t2`, topologia inteligente triangular, alvo de 4.000 faces.
- Textura: `meshy-6-lite`, 2K, PBR ativado.
- Task de geometria: `01a200e5-fa54-73a9-aa3e-c6c30633a674`.
- Task de textura: `01a200e6-38d1-7255-a9f0-fc1422778b06`.
- A exportação GLB foi tentada na conta Higor e recusada pelo Meshy com: **“Please upgrade plan to download models”**.
- Nenhuma compra ou upgrade foi feito.
- O GLB ainda NÃO está no GitHub. Não afirmar que o modelo 3D já aparece no jogo.

## Integração já preparada
- Arquivo: `scripts/world.gd`
- Função: `_build_ancient_tree_landmark`
- Caminho esperado do modelo: `res://assets/plugin_imports/meshy/ancient_tree.glb`
- A função instancia o GLB se o arquivo existir; caso contrário, cria a árvore procedural de fallback.
- Posição do marco na floresta: `Vector3(-158.0, 0.0, -104.0)`.

## Próximas etapas para o próximo agente
1. Não gerar outra cópia nem gastar mais créditos.
2. Se o usuário fornecer um GLB exportado/licenciado, validar que é um arquivo GLB válido e adicionar em `assets/plugin_imports/meshy/ancient_tree.glb`.
3. Conferir escala, orientação, materiais PBR e tamanho de textura no Godot.
4. Abrir a cena e validar visualmente a árvore no local; manter fallback procedural caso o GLB falhe.
5. Atualizar o manifesto e `DEVELOPMENT-STATUS.md) somente após confirmar a transferência binária e os testes.
6. Não tentar contornar o bloqueio de plano; não comprar nem atualizar plano sem autorização explícita do usuário.

## Prompt visual de referência
Single ancient fantasy tree landmark for a stylized dark fantasy mobile game; broad massive twisted trunk, exposed sprawling roots, sweeping gnarled branches, dark umber bark, muted moss in creases, subtle crimson rune scars embedded in the bark; painterly hand-crafted game art, readable silhouette, clean low-poly geometry, optimized for mobile, isolated single tree, no terrain, no rocks, no extra objects.

## Textura de referência
Painterly dark fantasy bark texture, rich dark umber wood with visible vertical grain, muted moss settled in creases and around roots, subtle crimson rune scars embedded in the bark, restrained warm highlights, handcrafted stylized game-art finish, cohesive color palette, readable at mobile distance, avoid photorealistic noise and excessive surface clutter.
