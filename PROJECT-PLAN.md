# Plano de produção — Tobi e Breu: Dark World

## Pilar de experiência
Aventura de fantasia sombria com exploração livre, combate legível e narrativa emocional. A direção visual usa formas estilizadas, silhuetas fortes, materiais foscos e paleta pictórica: verde musgo, pedra fria, couro gasto, luz âmbar e corrupção rubra.

## Conteúdo herdado do projeto 2D
Preservar como canon de referência: Tobi e Breu; Mestre Azulan; o Coração Rubro roubado; o Silêncio Cinzento; Raízes; Pântano dos Ratos; Rio Prateado; Lago da Névoa; Floresta Densa; Árvore Anciã; Ruínas Antigas; cavernas; Montanha Gelada; Desfiladeiro Rubro; Castelo; Templo do Coração; Cume das Nuvens; goblins, ratos, cavaleiros, espectros e chefes já definidos.

## Vertical slice atual
Clareira de entrada com portão em ruínas, árvores, trilha, acampamento, Mestre Azulan, quatro goblins com perseguição e ataque, Tobi e Breu. A primeira missão inicia falando com Azulan, pede derrotar três inimigos e retornar ao mestre. O protótipo também tem barra de vida, ataque direcional, câmera touch e respawn no acampamento.

## Metas de qualidade Android
- Alvo inicial: dispositivos Android de entrada/médios; 30 FPS estáveis como piso e modo 60 FPS em aparelhos compatíveis.
- Resolução interna escalável, LOD, occlusion culling, sombras seletivas, instancing e streaming por região.
- Pacote base pequeno; conteúdo opcional baixado sob demanda. Não assumir conexão constante.
- Telemetria de performance somente com consentimento e sem dados pessoais desnecessários.

## Gates de produção
Function: aprovar mapa, escala, câmera e orçamento. Form: validar modelos, materiais, colisões e iluminação. Runtime: validar FPS, memória, tamanho, controles e estabilidade em aparelhos reais. Nenhum gate está aprovado só porque o projeto foi gerado.


## Incremento 0.3
- Materiais do cenário com shader procedural de pinceladas, torre em ruínas, cicatriz rubra, santuário, arbustos e ciclo dia/noite.
- Três arquétipos de inimigo e chefe Guardião do Silêncio ligado à progressão.
- Esquiva, vigor, poções, XP, níveis, fragmentos e save local.
- Este incremento é uma expansão de protótipo, não uma validação visual/runtime: requer execução no Godot, revisão da cena e teste Android.


## Incremento 0.4 — confiabilidade de controles e progressão
- Atalhos desktop de esquiva e poção conectados às mesmas ações da interface touch.
- Contagem da missão inicial restrita ao arquétipo de goblin corrompido.
- Save local versionado com compatibilidade de leitura para saves v1 e bloqueio de versões futuras desconhecidas.
- Testes automatizados para esses contratos e para as configurações móveis.
- Gate ainda aberto: executar no Godot 4.3+, testar toque/câmera/combate e validar no Android físico.


## Incremento 0.5 — Pântano dos Ratos / Capítulo I
- Segunda região conectada com terreno de brejo, poças, árvores mortas e altar.
- Três totens interativos; progresso individual persistido no save.
- Nova cadeia de missão após o Guardião da Cicatriz: totens → Bruxa do Pântano → retorno a Azulan.
- Novo chefe com 440 HP, maior alcance e dano, bloqueado até a ativação da missão.
- Recompensas de conclusão e save versionado v3 com compatibilidade retroativa.
- O incremento continua sem aprovação de Runtime: requer Godot 4.3+, testes de colisão, controles e desempenho em Android físico.


## Incremento 0.5 — Pântano dos Ratos / Capítulo I
- Segunda região conectada com terreno de brejo, poças, árvores mortas e altar.
- Três totens interativos; cada totem é salvo individualmente para evitar inconsistência ao continuar uma partida.
- Nova cadeia de missão após o Guardião da Cicatriz: totens → Bruxa do Pântano → retorno a Azulan.
- Novo chefe com 440 HP, maior alcance e dano, bloqueado até a ativação da missão.
- Recompensas de conclusão e save versionado v4, com migração dos saves anteriores.
- O incremento continua sem aprovação de Runtime: requer Godot 4.3+, testes de colisão, controles e desempenho em Android físico.

## Incremento 0.8 — progressão de equipamento
- Forja de espada com três melhorias compradas usando Fragmentos Rubros (custos 3/6/10).
- Dano do ataque sobe 10 pontos por nível, com nível restaurado ao carregar o save.
- Forja acessível perto de Azulan pelo botão touch ou tecla U; sem shards suficientes, o jogo informa o saldo faltante.
- Save v5 armazena o nível da arma; saves v1-v4 continuam aceitos com nível inicial 0.
- Ainda requer teste de runtime no Godot e no Android físico.


## Incremento 0.9.5 — progressão que muda o gameplay
- XP foi conectado a atributos reais: vida máxima e dano base sobem a cada nível.
- Cada nível concede recuperação parcial de vida, reforçando a recompensa sem substituir poções.
- Barra de EXP mostra a distância até o próximo nível; mochila exibe estatísticas calculadas.
- O XP acumulado nos saves antigos define o nível automaticamente, sem alterar o formato v7.
- Ainda precisa de validação visual dentro do Godot e em Android físico para ajustar escala, legibilidade e equilíbrio.


### Entrega 0.10.0 — Capítulo II
- [x] Criar bioma Rio Prateado conectado ao mapa existente.
- [x] Adicionar NPC Guardião do Rio e fluxo de diálogo.
- [x] Adicionar Cavaleiros Afogados com identidade visual e perfil de combate.
- [x] Criar objetivo de derrotar três inimigos específicos e recompensa de capítulo.
- [x] Persistir estágio e progresso no save v8 sem quebrar saves anteriores.
- [ ] Testar em execução real no Godot e em aparelho Android (ambiente de execução não disponível nesta sessão).


### Ativos 3D externos
- [x] Criar projeto dedicado Thrixel para centralizar assets de Tobi e Breu.
- [x] Gerar modelo estático da Árvore Anciã (16 m, 14.132 triângulos, 1024 px).
- [ ] Transferir GLB gerado para `assets/` e validar importação/escala no Godot.


### Entrega 0.11.0 — Leviatã do Lodo
- Chefe final do Rio Prateado desbloqueado após a missão dos Cavaleiros Afogados.
- Nova sequência: retorno ao Guardião, despertar do chefe, combate e confirmação de vitória.
- Progressão ampliada até o estágio 14; save v9 com compatibilidade retroativa.


### Entrega 0.12.0 — combate de chefe
- Leviatã alterna ataque de proximidade e esmagamento circular com telegráfico ampliado.
- Raio do esmagamento: 5,4 m na fase normal e 6,0 m na fase enfurecida.
- Janela de reação ajustada para o golpe especial; sem alteração do formato do save.
- Espectro Afogado gerado no Thrixel com 9.000 triângulos e textura 1024; arquivo ainda não foi incorporado ao projeto Godot.


## Continuação da campanha — 26/11/2026

### Capítulo III — O Rio das Memórias
- [x] Três memórias exclusivas, com persistência independente das relíquias opcionais do Rio.
- [x] Retorno a Mestre Azulan, Guardiã do Templo, Guardião do Templo como chefe e recompensa.
- [x] Cena “O Rio se Lembra”, “O Chamado do Rio” e “A Porta do Templo”.

### Capítulo IV — O Templo Esquecido
- [x] Três selos colecionáveis nas Ruínas Antigas, salvos individualmente.
- [x] Oráculo das Ruínas, Guardião das Ruínas, barra de vida, recompensa e cena narrativa.

### Capítulo V — O Último Amanhecer
- [x] Três fragmentos colecionáveis no Cume das Nuvens, salvos individualmente.
- [x] Guardião do Amanhecer, Silêncio Cinzento como chefe final, cena de escolha e créditos.
- [x] Save v16 mantém a leitura dos saves anteriores e amplia a progressão até o estágio 30.

### Serviços online
- [x] Login/cadastro por e-mail no Supabase Auth.
- [x] Busca de perfis e solicitações de amizade (enviar, aceitar e recusar).
- [x] Criar sala, entrar por código, até quatro membros e atualização periódica do lobby.
- [x] Quatro migrações SQL aplicadas foram copiadas para `supabase/migrations/` e documentadas em `supabase/README.md`.
- [ ] Google OAuth: requer credenciais do provedor e fluxo nativo Android; não está habilitado.
- [ ] Multiplayer dentro da partida: movimento, animações e combate sincronizados em tempo real ainda não existem.

### Gates de qualidade ainda abertos
- [ ] Confirmar a nova execução do workflow: testes, importação, boot headless, exportação APK e teste em emulador.
- [ ] Testar em aparelho Android físico e ajustar desempenho/controles.
- [ ] Integrar os modelos GLB já existentes no projeto Thrixel; o download externo não foi transferido para o repositório.
- [ ] Finalizar áudio, VFX, pathfinding avançado, acessibilidade e opções gráficas.
- [ ] Configurar Google OAuth quando as credenciais forem fornecidas.

**Importante:** “implementado no código” não equivale a gate de runtime aprovado. Não declarar o jogo pronto até os testes do motor e Android terminarem.


## Canon narrativo consolidado — cinco capítulos

1. **O Coração Roubado** — prólogo, descoberta do roubo do Coração Rubro, primeira missão com Azulan e Guardião do Silêncio; cena “A Marca do Guardião”.
2. **A Floresta Corrompida** — Pântano dos Ratos, três totens, Bruxa do Pântano e cena “O Último Totem”.
3. **O Rio das Memórias** — Rio Prateado, Cavaleiros Afogados, Leviatã do Lodo, três memórias exclusivas, Guardiã do Templo e Guardião do Templo; cenas “O Rio se Lembra” e “A Porta do Templo”.
4. **O Templo Esquecido** — três selos nas Ruínas Antigas, Oráculo das Ruínas e Guardião das Ruínas.
5. **O Último Amanhecer** — três fragmentos no Cume das Nuvens, Guardião do Amanhecer, Silêncio Cinzento, escolha final e créditos.

A numeração da campanha no HUD/cenas segue este canon. O Rio Prateado e o Leviatã fazem parte do Capítulo III, não constituem um capítulo extra.
