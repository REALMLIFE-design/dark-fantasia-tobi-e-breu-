## Refinamento interno de materiais — 20/11/2026 (não é release)
- Projeção triplanar baseada na normal do mundo evita distorção de textura em paredes, penhascos, torres e rochas.
- Caminho otimizado usa a projeção dominante em faces alinhadas; mistura triplanar completa fica para superfícies inclinadas.
- Relevo/bump procedural derivado do albedo e do ruído, sem novas texturas vinculadas ao shader Godot.
- Aqueduct gerou e exportou um material PBR tileável de pedra 1024² com base color, height, normal OpenGL, roughness e AO; os PNGs ainda não foram copiados para `assets/` e não contam como integração final.
- 71 testes automatizados e validador estático aprovados. Sem compilação real no Godot ou teste Android nesta sessão.
- Versão pública mantida em 0.12.0.

## Trabalho interno — 2026-11-20 (sem nova versão pública)
- Leviatã do Lodo recebeu uma segunda fase de fúria persistente: a condição é recalculada com base na vida carregada do save.
- Na fase de fúria, o núcleo muda para vermelho emissivo, o aviso de ataque muda de cor e o chefe ganha velocidade, dano, alcance e raio de golpe ampliados.
- HUD do chefe agora recupera vida e indicação de fúria ao continuar uma luta salva.
- Adicionados testes de contrato para a restauração e o feedback da fase de fúria.
- 44 testes automatizados e validador estático aprovados. Execução real no Godot/Android continua pendente.

## 0.9.3 — Efeito visual do Pulso Sombrio
- Breu agora emite uma onda circular violeta expansiva ao ativar a habilidade.
- A onda cresce até o raio efetivo do ataque e desaparece suavemente em 0,72 s.
- Efeito usa malha procedural leve e material translúcido emissivo, sem adicionar texturas externas.
- Mantidos custo de vigor, dano, raio, recarga e compatibilidade do save v7.
- Validação estática e testes de contrato atualizados; execução no Godot/Android ainda pendente.

# Histórico de versões — Tobi e Breu: Dark World 3D

## 0.9.2 — Combate em cadeia e habilidade de Breu
- Combo de três golpes com janela de encadeamento e dano crescente (1,0x / 1,25x / 1,65x).
- Golpe final tem intervalo ligeiramente menor, recompensando o ritmo de ataque.
- Nova habilidade Pulso Sombrio de Breu: dano em área num raio de 4,2 m, custo de 35 de vigor e recarga de 8 s.
- Habilidade acessível pelo botão touch BREU e pela tecla K; HUD mostra combo e recarga.
- Mantida a compatibilidade do save v7: os novos recursos de combate não exigem migração.


## 0.9.1 — Checkpoint persistente
- Santuário ativa ponto de retorno para Tobi.
- Posição é persistida no save e usada no respawn após derrota.
- Coordenadas carregadas são limitadas ao espaço válido do mundo.
- Save atualizado para v7, mantendo compatibilidade de leitura com saves anteriores.


## 0.8 — Forja e progressão de equipamento
- Sistema de aprimoramento da espada com três níveis e custos crescentes em Fragmentos Rubros.
- A forja funciona perto de Mestre Azulan, com botão touch e atalho U.
- Dano da espada aumenta por nível; nível e fragmentos são persistidos no save.
- Save v5 mantém compatibilidade com versões anteriores.


## 0.7 — Refinamento de modelos e animações
- Tobi recebeu camadas de roupa, ombreiras, joelheiras, bolsos, fecho de capa e painel frontal.
- Animações refinadas para corrida, ataque, esquiva, reação ao dano, aterrissagem e derrota.
- Breu ganhou quatro patas articuladas, cauda segmentada e movimentos de acompanhamento.
- Inimigos receberam detalhes de equipamento, manto especial da Bruxa e animações de ataque/idle/dano mais expressivas.
- Mantidos controles, missões, progresso e saves.

## 0.5 — Pântano dos Ratos
- Nova região conectada com brejo, poças, árvores mortas e altar.
- Três totens interativos com estado individual persistido.
- Cadeia de missão até o encerramento do Capítulo I.
- Bruxa do Pântano como chefe desbloqueado pela missão.
- Save v4 com migração dos saves anteriores.
- Área navegável ampliada.

## 0.4 — Confiabilidade
- Atalhos de esquiva e poção.
- Correção da contagem de inimigos da primeira missão.
- Save versionado e testes de contratos.

## 0.3 — Progressão e cenário
- Shader pictórico, santuário, torre e ciclo dia/noite.
- Arquétipos de goblin, Guardião do Silêncio, esquiva, vigor, poções, XP e fragmentos.

## 0.2 — Combate e HUD
- Combate direcional, inimigos perseguem e atacam, HUD, câmera touch e respawn.

## 0.1 — Protótipo inicial
- Clareira, Tobi, Breu, Mestre Azulan e primeira missão.

## 0.6 — Personagens articulados e animações procedurais
- Tobi passou a usar pivôs separados para braços, pernas, cabeça, espada e capa.
- Animações procedurais de idle, caminhada/corrida, salto, esquiva e golpe de espada.
- Breu recebeu cabeça articulada, patas com movimento, cauda oscilante e pequenos movimentos de atenção.
- Inimigos agora têm braços/pernas articulados, ciclo de caminhada, pose de ataque, reação ao dano e dissolução/queda ao morrer.
- Guardião e Bruxa ganharam silhuetas próprias com chifres/ombros; a Bruxa recebeu cristal luminoso no cajado.
- Tobi ganhou detalhes de olhos iluminados sob o capuz.
- Mantidos controles, combate, progressão e formato de save existentes.
- Limitação: animações são procedurais por script, não esqueletos/AnimationPlayer com clips importados. Ainda precisam de validação dentro do Godot e no Android.


## Versão 0.9 — Inventário e saque
- Mochila acessível pelo botão de toque e pela tecla I.
- Painel mostra poções, Fragmentos Rubros, materiais de goblins, ervas, essência sombria, espada, dano, nível e XP.
- Inimigos comuns e chefes concedem materiais específicos; recompensas são salvas.
- Save atualizado para versão 6, mantendo migração dos saves anteriores.
- Testes estáticos ampliados para inventário, persistência e tabelas de loot.


## 0.9.4 — Combate legível e IA de inimigos
- Ataques inimigos agora possuem preparação antes do dano, em vez de causar dano instantâneo ao entrar no alcance.
- Indicador circular vermelho emissivo no chão sinaliza o ataque iminente.
- O golpe só acerta se Tobi ainda estiver dentro do alcance no momento do impacto, permitindo esquiva real.
- Chefes possuem preparação e intervalo maiores, dando mais leitura e espaço para reação.
- Aviso visual é encerrado quando o inimigo morre.
- Mantida a compatibilidade do save: nenhuma estrutura persistida foi alterada.


## 0.9.5 — Progressão de personagem funcional
- XP agora tem efeito real: a cada 100 XP, Tobi sobe um nível.
- Cada nível concede +12 de vida máxima, +3 de dano base e recupera 25 pontos de vida.
- Dano da espada combina nível do personagem e melhorias da forja.
- HUD recebeu barra de experiência com progresso dentro do nível atual, usando a paleta musgo/latão do conceito visual.
- Mochila agora mostra nível, XP necessário, vida máxima e dano calculado.
- Save v7 permanece compatível: nível e atributos são derivados do XP salvo, sem migração.


## 0.10.0 — Capítulo II: Rio Prateado
- Nova região jogável a leste: Rio Prateado, água prateada, margens rochosas, ponte larga, juncos e farol luminoso.
- Novo NPC Guardião do Rio, com diálogo e progressão própria de missão.
- Nova cadeia narrativa após o Capítulo I: encontrar o Guardião, derrotar três Cavaleiros Afogados e libertar o rio.
- Novo arquétipo de inimigo Cavaleiro Afogado, com armadura, escudo, atributos e janela de ataque próprios.
- Progresso e contagem dos cavaleiros persistidos em save v8, mantendo compatibilidade com saves antigos.


## 0.10.0 — Capítulo II: Rio Prateado
- Nova região a leste com rio, ponte, margens rochosas, juncos e farol de navegação.
- Novo Guardião do Rio e cadeia narrativa após a conclusão do Capítulo I.
- Novo inimigo Cavaleiro Afogado, com armadura/escudo e parâmetros de combate próprios.
- Objetivo de derrotar três cavaleiros, recompensa de XP/fragmentos/poções e retorno ao NPC para concluir o capítulo.
- Save v8 armazena estágio e contador do Capítulo II; saves anteriores continuam aceitos.
- Asset Árvore Anciã gerado no Thrixel: GLB 16 m, 14.132 triângulos, 1024 px; aguarda transferência para a pasta do projeto.


## 0.11.0 — Leviatã do Lodo
- Novo chefe final do Rio Prateado, com silhueta própria, carapaça, presas e núcleo luminoso.
- 680 HP, 27 de dano inicial, alcance ampliado e janela de aviso de ataque mais longa. Na metade da vida, entra em fúria e acelera os ataques.
- HUD de chefe centralizada no topo, exibida apenas durante a batalha e atualizada com a vida real do Leviatã.
- Corrigido o desbloqueio: o Leviatã é ativado ao falar com o Guardião após os cavaleiros. HP do chefe persiste ao sair e voltar ao jogo.
- Chefe só desperta após a missão dos três Cavaleiros Afogados e o retorno ao Guardião do Rio.
- Vitória concede 160 XP, 5 Fragmentos Rubros, 5 Essências Sombrias e 2 Poções.
- O capítulo só termina após reportar a vitória ao Guardião; progressão persistida até o estágio 14.
- Save atualizado para v9, com leitura de versões anteriores preservada.


## 0.12.0 — Golpe de impacto do Leviatã
- Leviatã alterna ataque próximo e esmagamento em área.
- Telegráfico de chão expande para o raio do golpe (5,4 m; 6,0 m na fase enfurecida).
- Esmagamento tem aviso mais longo na fase enfurecida para manter leitura e possibilidade de esquiva.
- Testes de contrato para alternância, telegráfico e resolução de dano em área.
- Gerado no Thrixel o modelo do Espectro Afogado (9.000 triângulos, 2,6 m, 1024 px); importação Godot ainda pendente.


## Desenvolvimento interno — 2026-11-20 (sem alterar a versão pública)

- Adicionados dois Espectros Afogados opcionais nas margens do Rio Prateado, desbloqueados ao iniciar o Capítulo II.
- Novo perfil de combate para o espectro: 185 HP, movimento mais rápido, flutuação visual, manto translúcido e núcleo emissivo.
- Derrotar um espectro concede 18 XP e 1 Essência Sombria; eles não contam para a missão dos três Cavaleiros Afogados.
- A vida do Leviatã agora grava o progresso em faixas de 10% (e ao chegar a zero), reduzindo gravações repetidas a cada golpe; pausa/fechamento continuam salvando o estado atual.
- Testes automatizados ampliados para cobrir desbloqueio, recompensas e gravação por faixas.
- Modelos externos da Árvore Anciã e do Espectro Afogado foram localizados no Thrixel, mas a exportação binária ainda não foi integrada ao projeto Godot.

## Trabalho interno (não lançado) — Rio Prateado
- Portão Afogado com pedra-chave luminosa como marco de navegação.
- Destroços de ruínas e waystones nas margens do Rio Prateado.
- Sem alteração do número de versão pública (0.12.0).

### Desenvolvimento interno — 20/11/2026 (não é release)
- Rio Prateado: três Ecos do Rio opcionais com recompensa de XP e Essência Sombria.
- Coletas individuais persistem no save; migração compatível com saves anteriores.
- Formato de save interno: 10. Versão pública mantida em 0.12.0.
- Testes automatizados: 46 aprovados; validador estático aprovado.


## Desenvolvimento interno — 20/11/2026 (não é release)
- Astrolábio da Corrente Prateada: puzzle de três anéis com sequência I • III • II, alavanca e gaveta.
- Solução e progresso parcial persistem no save v11; recompensa única de 60 XP, 3 Essências Sombrias e 2 Fragmentos Rubros.
- Thrixel: mecanismo interativo 3D e variantes PBR painterly da Árvore Anciã e do Espectro Afogado gerados. Importação GLB no projeto Godot ainda pendente por falha de transferência.
- 49 testes automatizados e validador estático aprovados; sem teste de execução Godot/Android nesta sessão.
- Versão pública mantida em 0.12.0.

## Trabalho interno — 20/11/2026 (Rio Prateado)
- Adicionados três baús opcionais exploráveis no Rio Prateado, com tampa articulada, fecho, brilho e luz de recompensa.
- Interação contextual por proximidade; cada baú concede XP e Essência Sombria, e o terceiro também concede Fragmento Rubro.
- Estado de abertura salvo individualmente; baús já abertos reaparecem abertos e não entregam recompensa duplicada.
- Versão pública mantida em 0.12.0; sem migração de save necessária (campo novo com padrão vazio).

## Trabalho interno — Três frentes simultâneas (20/11/2026)
- **Textura:** gerada no Thrixel uma nova variante PBR pintada à mão para a Árvore Anciã, preservando a geometria original (14.132 triângulos). Export GLB reduzido para 1024 px, estimado em 3,3 MB; o arquivo ainda não foi integrado ao projeto porque o endpoint de download não ficou acessível neste ambiente.
- **Mapa:** adicionada a área lateral opcional **Bosque dos Sussurros**, conectada ao Rio Prateado por pedras de passagem, com ilha musgosa, bétulas prateadas, arco antigo e três altares de lanterna.
- **Exploração:** cada lanterna acesa concede 22 XP e 1 Essência Sombria; a terceira também concede 1 Fragmento Rubro. A coleta individual é salva e os saves antigos continuam compatíveis.
- **HUD:** indicador contextual de progresso do bosque aparece somente quando Tobi está próximo da área, sem ocupar o centro da tela.
- Better Design consultado para alvos de toque Android e princípios de orientação espacial; Context7 consultado para referências de Godot 4.5. Figma foi tentado para o mockup mobile, mas a conta atingiu o limite de chamadas MCP do plano Starter; nenhum arquivo Figma novo foi criado.
- Verificação: 53 testes Python passaram e o validador estático passou. Godot não está instalado; não houve compilação GDScript nem teste no aparelho.
- Versão pública mantida em 0.12.0; save permanece v11.

## Internal world/build pass — 2026-11-20
- Expanded the traversable ground and collision footprint to 700 × 700 game units, with longer trail coverage, branch trails, four wilderness clearings, and a distant mountain ring. This is an expanded prototype region, not a GTA V-scale finished world.
- Updated the Android GitHub Actions workflow to detect the Godot project either at the repository root or inside `TobiEBreu-3D/`, preventing the previously documented folder-layout mismatch.
- Added automated contracts for the expanded exploration footprint and both supported repository layouts.

## Expansão de mundo — assentamentos e exploração (20/11/2026)
- Adicionadas Vila do Carvalho e Cidade de Pedra, com praças, poço, casas de pedra e madeira, telhados, portas, chaminés e iluminação de rua.
- Adicionada a Guilda dos Vigias com salão e quadro de contratos interativo.
- Adicionada a Caverna do Eco, com entrada rochosa, corredor, câmara escura e cristais luminosos.
- Adicionada a Masmorra das Cinzas, com portão, três salões conectados, pilares e altar.
- Adicionado o Castelo do Silêncio, com torreões, muralhas, portão e ponte de acesso.
- Novo contrato opcional da Guilda: recuperar três selos espalhados pela caverna, masmorra e castelo; recompensa de XP, fragmentos, essências e poções.
- Progresso dos selos e do contrato salvo com migração compatível para save v12.
- Geometria procedural econômica para preservar o orçamento de dispositivos Android.

## Desenvolvimento — pacote de materiais procedurais
- Shader painterly ampliado com padrões procedurais distintos para grama, terra, lama úmida, madeira, água, neve, telhas e pedra cortada.
- Materiais atribuídos automaticamente a objetos pelo nome, mantendo uma direção artística coerente e reduzindo a necessidade de texturas bitmap pesadas.
- Biomas externos agora recebem variações próprias de superfície: neve/frio, pedra antiga, terra do desfiladeiro e vegetação.
- Rio Prateado recebeu padrão de ondulação procedural mantendo transparência; superfícies e objetos continuam usando materiais leves para Android.


## Pacote de texturas — v0.15.1 (20/11/2026)
- Criados dois atlases bitmap originais e tileáveis: albedo (2048×1024 RGB) e roughness (2048×1024).
- O atlas contém oito superfícies: grama, terra, lama úmida, madeira, água, neve/gelo, telhas e pedra.
- Shader painterly agora combina os mapas bitmap com os padrões procedurais existentes, preservando as cores específicas de cada objeto e adicionando variação de rugosidade.
- Coordenadas de textura convertidas para espaço de mundo, evitando o efeito de textura que acompanha a câmera.
- Atlases compartilhados por todos os materiais para limitar o número de texturas vinculadas e reduzir o peso do pacote Android.
- Integração automatizada verificada por testes de contrato; compilação do shader e renderização real ainda dependem do Godot 4.

## Desenvolvimento interno — materiais PBR por bioma (v0.18, 20/11/2026)
- Intensidade do relevo procedural agora varia por superfície: madeira e pedra recebem mais definição; grama, neve e água usam relevo mais suave para evitar ruído visual.
- Mantidos os mesmos atlases compartilhados, paleta painterly, projeção triplanar e orçamento de texturas para Android.
- Cobertura automatizada para os valores de relevo por tipo de material.
- Aqueduct: grafo PBR de pedra criado e exportado com base color, height, normal OpenGL, roughness e AO em 1024²; os PNGs externos ainda não foram incorporados ao pacote Godot porque a transferência não foi concluída.
- Context7 consultado para conferir os recursos de shader espacial e derivadas do Godot; compilação/renderização real ainda requer o editor Godot 4.
