# Tobi e Breu — Dark World 3D

## Estado interno em 2026-11-20

### Parte concluída nesta rodada — encontro do Leviatã do Lodo
- Segunda fase de fúria agora é um estado explícito: ao chegar a 50% da vida, o chefe aumenta velocidade, dano, alcance e raio do golpe de área.
- O núcleo do Leviatã muda para vermelho emissivo e o aviso de ataque ganha cor mais quente, comunicando visualmente a mudança de perigo.
- A fase de fúria é reconstruída quando o save carrega com 340 HP ou menos; o HUD mostra a condição e a vida atual ao retomar a luta.
- O estado de fúria também é sincronizado ao ativar o chefe após conversar com o Guardião do Rio.
- Novos testes de contrato cobrem restauração da fase e feedback visual/combatente.
- Validação após a alteração: 44 testes automatizados passaram e o validador estático passou. Isso não substitui executar a cena no Godot.

- Base recuperada do arquivo público 0.12.0.
- Versão pública mantida em 0.12.0; estas alterações são desenvolvimento interno, não uma nova versão/release.
- Dois Espectros Afogados opcionais foram adicionados ao Rio Prateado, com desbloqueio no Capítulo II, silhueta espectral procedural, flutuação, perfil de combate e recompensa própria.
- O salvamento da vida do Leviatã foi otimizado para registrar marcos de 10% e a derrota, mantendo o salvamento integral ao pausar/fechar.
- 42 testes automatizados passaram; validador estático passou.
- Godot não está instalado neste ambiente: GDScript não foi compilado, cena não foi executada e desempenho/controles não foram testados em Android real.
- Modelos Thrixel da Árvore Anciã e do Espectro Afogado foram encontrados e inspecionados (14.132 e 9.000 triângulos, respectivamente). Nesta rodada, a exportação GLB do Espectro Afogado foi solicitada em 1024 px (2,1 MB), mas a transferência para o diretório do projeto foi bloqueada pelo ambiente; o modelo ainda não está incorporado e o inimigo continua procedural.
- O projeto permanece muito abaixo da meta de aproximadamente 30 MB; não foi criado novo número de versão nem release público.

## Trabalho interno — Rio Prateado (20/11/2026)
- Adicionado o marco visual **Portão Afogado**, com pilares, lintel quebrado e pedra-chave emissiva para orientar o jogador ao destino da região.
- Adicionados destroços de alvenaria nas margens e marcos de navegação ao longo da trilha.
- Mantida a versão pública em 0.12.0; esta é uma atualização de desenvolvimento, não um lançamento.
- Verificação automatizada: 45 testes Python passaram; validador estático passou.
- Limitação: Godot 4 e Android/ADB não estão instalados neste ambiente, portanto a cena ainda precisa de execução real no motor e teste em dispositivo.

## Trabalho interno — Ecos do Rio (20/11/2026)
- Adicionados três **Ecos do Rio** opcionais, em pontos diferentes do Rio Prateado, com pedestal, cristal emissivo, luz e identificação visual.
- Cada eco pode ser recuperado uma única vez por interação próxima; concede +25 XP e +1 Essência Sombria.
- A coleta é persistida individualmente no save. Saves antigos continuam compatíveis: a lista começa vazia quando a chave ainda não existe.
- Versão do formato de save elevada internamente para 10; a versão pública do jogo continua 0.12.0.
- Validação automatizada: 46 testes passaram; validador estático passou.
- Documentação Godot 4.5 consultada para confirmar o uso de ConfigFile e persistência explícita. Ainda não foi possível compilar/abrir a cena no motor, pois Godot não está instalado neste ambiente.


## Trabalho interno — Astrolábio da Corrente Prateada (20/11/2026)
- Adicionado um puzzle opcional no Rio Prateado com três anéis giratórios, sequência inscrita no pedestal, alavanca e gaveta de recompensa.
- A sequência é I • III • II; cada interação E gira o anel atual. O progresso parcial e a solução são salvos, e a recompensa só pode ser recebida uma vez.
- Recompensa ao concluir: +60 XP, +3 Essências Sombrias e +2 Fragmentos Rubros. Save atualizado para v11, preservando leitura de saves anteriores.
- Gerados no Thrixel um mecanismo 3D de 22.276 triângulos/15 partes com textura PBR original, além de variantes texturizadas da Árvore Anciã (14.132 tris) e do Espectro Afogado (9.000 tris). Os GLBs foram gerados e os downloads disponibilizados pelo Thrixel, mas a transferência binária para a pasta local do projeto ainda falhou; por isso o jogo Godot usa um protótipo procedural do puzzle, e os modelos externos permanecem documentados como pendentes de importação.
- Créditos Thrixel consultados antes/depois: 228 inicialmente, 147 restantes após as gerações confirmadas desta rodada. Nenhum crédito pago foi usado; saldo exibido como cubes do plano gratuito.
- Verificação: 49 testes automatizados passaram; validador estático passou. A cena ainda não foi compilada/executada no Godot, que não está instalado neste ambiente.
- Versão pública permanece 0.12.0; save interno é v11.

## Trabalho interno — Caranguejo de Prata e novos assets (20/11/2026)
- Criado o inimigo opcional **Caranguejo de Prata** no Rio Prateado, com seis pernas articuladas proceduralmente, duas pinças, carapaça mineral e núcleo turquesa emissivo.
- Dois encontros opcionais são desbloqueados no Capítulo II; cada derrota concede +22 XP, +1 Essência Sombria e +1 Fragmento Rubro. Não interfere no contador dos Cavaleiros Afogados.
- Gerada no Thrixel uma escultura original do Caranguejo de Prata (9.442 triângulos) e aplicada rig Mixamo; também foi rigado o Espectro Afogado.
- Gerado um Cofre do Rio Prateado com tampa articulada separada (11.180 triângulos / 6 partes), preparado para animação de abertura.
- O download do Thrixel fornece links, mas a rede do ambiente de arquivos não resolve `api.thrixel.com`; os GLBs ainda não foram copiados para `assets/` nem importados no projeto. O jogo mantém protótipos procedurais até a importação real.
- Saldo Thrixel verificado após as gerações: 46 cubes gratuitos; sem uso de créditos pagos.
- Outros saldos consultados: Runway Free mostra 500 créditos, mas efeitos sonoros e vídeo exigem workspace pago; fal está bloqueado por saldo esgotado; HeyGen Free não informa créditos utilizáveis. Nenhuma cobrança adicional foi feita nessas plataformas.
- Verificação: 50 testes Python passaram e validador estático passou. Godot não está instalado; sem compilação GDScript, execução de cena ou teste Android nesta rodada.
- Versão pública continua 0.12.0; save interno permanece v11.

## Ajuste de combate — Caranguejo de Prata (20/11/2026)
- O Caranguejo agora anuncia a investida com um círculo de perigo maior (2,75 m) e preparação mais longa (0,92 s), dando tempo para o jogador esquivar.
- Ao concluir o aviso, avança em uma investida curta com as pinças; as duas pinças têm pivôs e animação de golpe próprios, além do movimento das seis pernas.
- Mantidos HP, dano, recompensas e desbloqueio opcionais existentes; nenhum balanceamento de missão ou save foi alterado.
- Testes de contrato: 51 passaram; validador estático passou. Ainda não é validação de execução no Godot: o motor não está instalado neste ambiente.
- Versão pública continua 0.12.0; save interno continua v11.

### Continuação — baús do Rio Prateado (20/11/2026)
- Três baús opcionais adicionados em pontos de exploração das margens e do caminho da antiga passagem.
- Cada baú tem base, faixas metálicas, fecho, tampa com pivô articulado, cristal emissivo e luz local.
- Interação E/toque contextual abre o baú, remove o fecho e apaga o brilho; a recompensa é única por baú.
- Recompensas: 35/45/55 XP; 1/1/2 Essências Sombrias; o terceiro também entrega 1 Fragmento Rubro.
- IDs de baús abertos persistem no save; saves antigos recebem lista vazia sem alterar a versão pública 0.12.0 ou save version 11.
- Validação automatizada: 52 testes passaram e validador estático passou. Isso não substitui importação/compilação no Godot.
- Thrixel confirmou 46 cubes gratuitos disponíveis. Foram solicitados links GLB do cofre, rig do caranguejo e astrolábio; o conector retornou links de download (1,3 MB / 3,4 MB / 4,0 MB), mas o acesso externo ao endpoint ainda falhou na etapa de transferência para a pasta do projeto. Portanto, continuam não integrados.

### Três frentes simultâneas — Bosque, textura e HUD (20/11/2026)
- Nova área lateral **Bosque dos Sussurros** conectada ao Rio Prateado por cinco pedras de passagem, com ilha musgosa, bétulas, três altares de lanterna e arco de pedra.
- Três lanternas opcionais interativas e persistentes: cada uma concede +22 XP e +1 Essência Sombria; a última também concede +1 Fragmento Rubro. Save antigo carrega a lista vazia por padrão, sem alteração da versão v11.
- HUD contextual mostra `BOSQUE DOS SUSSURROS • X/3 LANTERNAS` apenas dentro da área de exploração.
- Thrixel gerou uma segunda textura PBR pintada para a Árvore Anciã, preservando os 14.132 triângulos. Export GLB 1024 px estimado em 3,3 MB; a tentativa de transferência falhou porque o endpoint não ficou acessível, então a textura está gerada no projeto Thrixel mas ainda não está integrada ao diretório `assets/` do jogo.
- Better Design forneceu princípios de alvos de toque de 48 dp e navegação/wayfinding; Context7 forneceu referências da documentação oficial Godot 4.5. Tentativa de mockup no Figma interrompida pelo limite de chamadas MCP do plano Starter; nenhum mockup foi salvo.
- Validação: 53 testes automatizados passaram e o validador estático passou. Godot/ADB não estão instalados; GDScript e desempenho Android não foram executados.
- Versão pública continua 0.12.0; save continua v11.

## Preparação de compilação Android via GitHub (20/11/2026)
- Adicionado preset Android ARM64 com APK de depuração em `build/TobiEBreu.apk`, nome de pacote `com.tobiebreu.darkworld3d` e versão 0.12.0.
- Adicionado workflow manual e por push em `.github/workflows/android-apk.yml`, com Godot 4.3.3, Java 17, Android SDK e upload do APK como artefato.
- Adicionado `.gitignore` para cache Godot, builds, credenciais de exportação e arquivos temporários.
- Documentado o fluxo para executar e baixar o APK pelo GitHub Actions.
- Ação ainda não executada no GitHub: a conexão GitHub disponível nesta sessão não retornou repositórios acessíveis. Portanto, nenhum commit ou APK foi criado nesta etapa.

## Internal pass 2026-11-20 (world/build reliability)
- Added a larger 700 × 700 traversable terrain footprint, four wilderness clearings, branching dirt trails, and a distant mountain perimeter. Existing chapter regions remain the authored content hubs; the expanded outer wilderness still needs handcrafted quests, enemies, landmarks, and final art.
- GitHub Actions now detects `project.godot` at repository root or under `TobiEBreu-3D/` and exports/uploads from the detected folder.
- Automated Python contract tests cover both changes. Godot runtime compilation and Android APK export still require GitHub Actions / a Godot installation and have not been verified here.


## World map expansion — 2026-11-20
- The playable terrain remains a 700 × 700 unit base; the outer-world pass now adds seven named biomes around the existing starting region, swamp, Silver River and Whisper Grove.
- New regions: Ancient Forest, Frozen Mountain, Red Gorge, Forgotten Ruins, Golden Plains, Heart Temple Plateau and Cloud Summit.
- New connecting roads, low-cost landmarks, regional color patches and floating region names improve navigation and give the map a larger adventure-game structure.
- Automated Python checks: 59 tests pass after the expansion. Static project validator passes.
- Important: this is a substantially expanded handcrafted world layout, NOT a finished GTA V-scale world. Godot itself is unavailable here, so no scene runtime, Android device, performance or APK validation has been performed. Thrixel balance is 0 cubes; existing generated models have not been imported into this Godot project.

## Atualização de conteúdo — 20/11/2026

**Novo conteúdo de mundo implementado no código:** Vila do Carvalho, Cidade de Pedra, Guilda dos Vigias, Caverna do Eco, Masmorra das Cinzas e Castelo do Silêncio. A Guilda oferece um contrato opcional com três selos colecionáveis persistentes e recompensa final. O save foi atualizado para v12, mantendo leitura de saves antigos.

**Limitações ainda abertas:** estes setores são construídos proceduralmente com malhas simples do Godot; não são interiores artesanais completos com navegação, NPCs próprios, comerciantes, diálogos ramificados ou dungeons com combate dedicado. Os modelos Thrixel existentes foram identificados, mas o ambiente do conector só forneceu URLs temporárias de download e não disponibilizou os arquivos GLB no diretório do projeto nesta sessão. Não afirmar que esses modelos foram importados. A cena Godot e o APK ainda precisam de teste no editor/Android.

## Pacote visual de materiais — atualização
- [x] Padrão procedural painterly para grama, terra, lama, madeira, água, neve, telhas e pedra.
- [x] Seleção automática de material para caixas/props pelo nome do objeto.
- [x] Variações de superfície específicas para Floresta Ancestral, Montanha Gelada, Desfiladeiro Rubro, Ruínas Antigas, Planície Dourada, Templo do Coração, Cume das Nuvens e pátio do castelo.
- [ ] Ainda faltam texturas bitmap/atlases de alta resolução, mapas normais e assets externos autorais; esta etapa usa texturização procedural no shader para manter o pacote leve.
- [ ] Shader ainda precisa ser validado dentro do Godot 4 e em aparelho Android real; os testes automatizados não compilam shaders.


## Texturização bitmap + procedural — 20/11/2026
- [x] Atlas tileável de albedo 2048×1024 com oito superfícies pintadas proceduralmente.
- [x] Atlas tileável de roughness 2048×1024 com resposta diferente por material.
- [x] Shader `painter_material.gdshader` seleciona o tile conforme `pattern_mode`, mistura a textura com o tint do objeto e ancora o padrão em coordenadas de mundo para evitar que a textura deslize com a câmera.
- [x] Materiais compartilham dois atlases para limitar bindings e manter o custo de memória previsível.
- [x] Testes de contrato verificam arquivos, uniforms e integração no `_painter_mat`.
- [x] Shader agora usa projeção triplanar em superfícies inclinadas/verticais, evitando esticar o atlas em paredões, torres e rochas.
- [x] Relevo normal procedural derivado do próprio atlas e do ruído, sem novo binding de textura; faces alinhadas usam caminho reduzido de amostras para poupar GPU mobile.
- [ ] Mapas normais PBR bitmap dedicados e textura externa da Árvore Anciã ainda não estão integrados.
- [ ] Compilação do shader, importação no editor Godot e inspeção visual em Android continuam pendentes; o validador Python não substitui essas etapas.


## Refinamento de materiais — 20/11/2026
- Shader `painter_material.gdshader` atualizado com projeção triplanar ancorada no mundo para paredes, rochas, penhascos, torres e props arredondados.
- Amostras de albedo e roughness agora usam projeções X/Y/Z ponderadas pela normal; faces alinhadas usam apenas a projeção dominante para reduzir leituras de textura em Android.
- Adicionado bump mapping por derivadas de tela a partir do albedo/ruído já carregado, sem adicionar mapas ou bindings extras ao material Godot.
- Aqueduct usado para criar e exportar um material PBR tileável de pedra com cinco saídas (base color, height, normal OpenGL, roughness e AO) em 1024². O grafo e a exportação foram concluídos; a cópia dos PNGs exportados para `assets/` ainda não foi confirmada, portanto eles não são tratados como integrados ao jogo.
- 71 testes automatizados e validador estático aprovados. Godot não está instalado nesta sessão: shader/GDScript ainda não foram compilados no motor e não houve teste em Android real.

## Ajuste fino PBR por superfície — 20/11/2026
- [x] `_painter_mat()` define intensidade de bump conforme o tipo: grama 0,10; terra 0,14; lama 0,20; madeira 0,24; água 0,035; neve/gelo 0,075; telhas 0,18; pedra 0,22.
- [x] O ajuste preserva os dois atlases compartilhados e evita exagero de relevo em superfícies lisas ou orgânicas.
- [x] Teste de contrato dedicado para os valores por bioma.
- [ ] Ainda depende de abrir no Godot 4 para validar compilação do shader e aparência final em renderização real.


## Correção de sintaxe GDScript — 21/11/2026
- Corrigida a indentação do `else` no puzzle do Astrolábio da Corrente Prateada (`scripts/world.gd`, linha aproximada 1520), que impedia o Godot de carregar o script.
- Suíte automatizada: 72 testes aprovados.
- Validação estrutural do projeto: aprovada.
- Ainda falta executar/importar no Godot e testar a cena e os controles no Android; portanto, esta correção não certifica por si só que o jogo inteiro já está jogável.


## Continuação da campanha e integração online — 26/11/2026

- Branch de trabalho: `feature/google-login-loading-friends-lobby`; PR #7 permanece aberto. A branch `main` não foi alterada.
- História: cenas “A Marca do Guardião”, “O Último Totem”, “O Rio se Lembra”, “A Porta do Templo” e “O Coração e a Escolha”; capítulos III, IV e V ampliados com colecionáveis persistentes, NPCs, chefes, recompensas, barra de vida e créditos.
- Save: versão 16; arrays próprios para memórias do Capítulo III, selos do Capítulo IV e fragmentos do Capítulo V; migração de saves anteriores preservada.
- Online: Supabase Auth por e-mail, busca de perfis, solicitações de amizade, salas autenticadas, entrada por código e leitura de membros; Realtime está publicado para `friend_requests`, `game_rooms` e `room_members`, mas o cliente Godot ainda usa atualização periódica, sem sincronização de movimento/combate.
- Segurança: RLS verificado nas tabelas públicas; funções RPC de criação/entrada executáveis por `authenticated` e não por `anon`; advisors de segurança/performance sem lints reportados na última consulta.
- OAuth Google segue pendente por falta de credenciais do provedor e fluxo nativo Android. Não há login Google funcional ainda.
- Thrixel: projeto existente com 18 assets; o modelo rigado do Cervo Ancião tem 14.064 triângulos. Saldo consultado: 0 créditos; não gerar novos modelos até os assets existentes serem aproveitados. O download GLB forneceu URL externa, mas a transferência para o repositório não foi concluída.
- Testes: os contratos automatizados estão sendo alinhados com save v16 e capítulos IV/V. A última execução observada falhou apenas por uma asserção de teste que procurava `quest_stage == 30` em vez da atribuição `quest_stage = 30`; a asserção foi corrigida e uma nova execução foi disparada.
- Ainda não declarar APK aprovado: a importação Godot, boot headless, exportação e teste em emulador precisam concluir com sucesso; nenhum teste em aparelho físico foi realizado nesta sessão.


## Correção adicional de RLS — 26/11/2026
- Uma consulta de teste sob o papel `authenticated` encontrou recursão infinita na policy de leitura de `room_members` (PostgreSQL 42P17). Isso poderia impedir o lobby de listar os membros.
- Criada a migração `20261126233451_fix_room_members_rls_recursion.sql`: helper `private.is_room_member(uuid)` com `SECURITY DEFINER`, `search_path` vazio e execução restrita a `authenticated`; policy de leitura atualizada para usar o helper.
- Repetidos `EXPLAIN` sob `SET ROLE authenticated` para `room_members` e `game_rooms`: ambos agora planejam sem erro de recursão. Isso valida a policy em nível SQL, mas ainda não substitui um teste de login e lobby com duas contas reais.
- O histórico agora tem sete migrações versionadas em `supabase/migrations/`; a sexta adiciona índice para `game_rooms.owner_id` e a sétima adiciona saída segura de salas/fechamento pelo anfitrião. Os testes de contrato verificam os arquivos e helpers.
- Advisor de segurança: sem lints. Advisor de performance: o alerta de chave estrangeira sem índice foi resolvido; restam apenas avisos informativos de índices ainda não usados porque as tabelas estão praticamente vazias.

- Lobby: adicionado botão para sair da sala; se o usuário for anfitrião, a RPC fecha a sala e remove os membros. O código de sala fechado deixa de aceitar novas entradas.

- Reprodutibilidade: adicionado `supabase/config.toml` com PostgreSQL 17 (versão consultada no projeto) e instruções `supabase link` / `supabase db push`; nenhuma chave secreta foi adicionada ao repositório.


## Continuação narrativa — 26/11/2026 (sem testes nesta rodada)
- Adicionada uma cutscene de abertura do Capítulo II quando Azulan libera a missão dos três totens: “A floresta pede ajuda”, com contexto para a corrupção do Pântano dos Ratos.
- Adicionada uma cutscene de encerramento do Capítulo II ao retornar a Azulan após derrotar a Bruxa: “A floresta volta a respirar”, conectando a purificação da floresta ao fragmento que aponta para o Rio Prateado.
- As cenas usam o sistema cinematográfico já existente, preservam o estágio da missão e não alteram o formato do save.
- Esta alteração foi gravada na branch de trabalho. Conforme solicitado, não foram executados testes; a compilação GDScript e a reprodução das cutscenes permanecem sem validação nesta rodada.

- O final da campanha agora apresenta uma escolha real ao jogador: guardar as memórias no Coração Rubro ou libertar sua luz pelo mundo. Cada decisão tem um epílogo narrativo próprio; a escolha é salva e, se o jogo for fechado antes dela, a tela de decisão reaparece ao carregar o save.
- A escolha usa a chave `story.final_choice` no save existente; não exige reset nem alteração destrutiva dos saves antigos. A versão do save permanece v16.
- Não foram executados testes nem compilação nesta rodada, conforme pedido.


## Continuação de conteúdo — diálogos e histórias paralelas (26/11/2026)
- Expandido o texto narrativo dos NPCs principais: Mestre Azulan, Guardião do Rio, Oráculo das Ruínas e Guardião do Amanhecer. As falas agora contextualizam a corrupção, explicam os perigos e reforçam o vínculo de Tobi e Breu.
- A Guilda dos Vigias recebeu falas de contrato mais completas, contexto dos três selos perdidos e orientação de retorno para resgate da recompensa.
- O Guardião Cervo e as três lanternas do Bosque dos Sussurros receberam falas que explicam o despertar e o sentido da bênção.
- Roteiro paralelo documentado em STORY-CAMPAIGN-PTBR.md. O conteúdo continua opcional e não bloqueia os cinco capítulos.
- Não foram executados testes, compilação ou validação visual nesta rodada, conforme solicitado.

- Ajustado o balão de diálogo/toast do HUD para acomodar falas maiores: largura responsiva à tela, altura ampliada, quebra automática e alinhamento vertical. A alteração busca evitar que os novos diálogos longos fiquem cortados em celulares; a aparência final permanece sem validação visual até a rodada de testes.

- Ampliadas as transições cinematográficas do Capítulo III: chegada ao Rio Prateado, libertação dos Cavaleiros Afogados, despertar do Leviatã do Lodo e libertação do rio. O início do confronto final no Cume das Nuvens também ganhou cena própria.
- As cenas são chamadas nos pontos de progressão já existentes e não alteram os estágios de missão ou o formato do save. Não foram executados testes, compilação ou validação visual.


## Ajuste de interface — login em telas estreitas (26/11/2026)
- O painel de autenticação agora calcula sua largura a partir da largura disponível da tela, respeitando margens laterais e o limite de 430 px em dispositivos maiores.
- Campos de nome, e-mail e senha receberam altura mínima de toque de 46 px; botões de entrar e criar conta passaram para 52 px.
- A mudança é de layout e não altera autenticação, saves ou fluxo de visitante.
- Não foi executado teste visual ou runtime, conforme pedido; a aparência ainda precisa ser conferida no Godot em diferentes resoluções.

- O painel de login também foi colocado em um contêiner com rolagem vertical e sem rolagem horizontal, para que os campos e botões continuem acessíveis em aparelhos com pouca altura disponível.

- A tela de login ganhou controle para mostrar/ocultar a senha digitada, sem enviar o valor a nenhum serviço até o jogador tocar em entrar ou criar conta.

- O salão de amigos agora empilha os painéis de amigos e grupo em telas abaixo de 820 px e mantém a área de conteúdo em rolagem vertical; em telas maiores, preserva as duas colunas lado a lado.

- O menu principal agora usa largura calculada pela tela, rolagem vertical em aparelhos baixos, botões expansíveis e quebra automática no subtítulo/rodapé. Em telas estreitas, os itens deixam de depender de uma largura fixa de 520 px.

- IA básica dos inimigos: quando o jogador se afasta além do raio de perseguição de 15 m, o inimigo agora retorna gradualmente à posição inicial de patrulha em vez de ficar parado no ponto distante. O comportamento mantém a perseguição e o combate existentes; navegação para contornar obstáculos continua pendente.


## Correções online com Supabase — 27/11/2026
- Corrigido o trigger `public.handle_new_user()`: agora executa como `SECURITY DEFINER`, mantém `search_path` vazio e revoga execução direta por `PUBLIC`, `anon` e `authenticated`. Isso permite que o trigger crie o perfil durante o cadastro sem conceder INSERT público na tabela de perfis.
- Migração aplicada ao projeto Supabase e versionada no repositório: `20261127092518_fix_auth_profile_trigger_security.sql`.
- Corrigida a reentrada de jogadores: quem já pertence a uma sala pode voltar usando o mesmo código mesmo depois de a partida mudar para `playing`; novos jogadores continuam bloqueados após o início e salas fechadas continuam inacessíveis.
- Migração aplicada e versionada: `20261127092550_allow_existing_members_to_rejoin_started_rooms.sql`.
- Verificação SQL do trigger confirmou `SECURITY DEFINER`, proprietário `postgres`, `search_path` vazio e ausência de EXECUTE para `anon` e `authenticated`. Advisor de segurança retornou zero lints.
- O advisor de performance ainda lista quatro índices sem uso; são avisos informativos esperados enquanto as tabelas estão vazias, não falhas de segurança.
- Não foram executados testes Godot, builds, APK ou testes de cadastro/reentrada com contas reais. O login Google segue pendente e o lobby ainda não sincroniza movimento/combate.

- Tela de login: incluído pedido de recuperação de senha por e-mail usando o endpoint oficial `/auth/v1/recover`; a resposta não revela se o e-mail existe, evitando enumeração de contas. A conclusão da troca de senha dentro do app ainda depende do fluxo de deep link Android e da tela para definir a nova senha.

- Tela de login: adicionados pedidos de recuperação de senha e reenvio da confirmação de cadastro por e-mail, usando os endpoints oficiais do Supabase Auth. As respostas são genéricas para não revelar se um endereço possui conta.
- Limitação mantida explícita: o app ainda não processa o link de recuperação/confirmacão por deep link Android; a solicitação por e-mail está conectada, mas a conclusão desses fluxos dentro do jogo ainda precisa da integração nativa.

- Cadastro: nome de aventureiro validado no cliente para respeitar o limite de 1 a 24 caracteres definido pela tabela `profiles`, evitando que o trigger rejeite um cadastro por nome longo demais.

- Lobby: protegidas as atualizações periódicas para impedir chamadas simultâneas de listagem de membros e de amigos; uma resposta atrasada de uma sala anterior não sobrescreve a sala atual. Mensagens de falha na lista de amigos agora orientam o jogador a tentar atualizar novamente.
- Cliente Supabase: falhas de transporte HTTP agora retornam uma mensagem de conexão em vez de serem confundidas com erro de autenticação. Erros de limite de e-mail e de destinatário não autorizado recebem orientação específica, pois o SMTP integrado do projeto hospedado tem restrições de teste.
- Não foram executados testes, builds, APK ou chamadas de cadastro reais.
