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


## Integração de assets existentes dos plugins (21/11/2026)
- Inventário confirmado no Thrixel: projeto **Tobi e Breu — Dark World 3D**, com 15 assets; os modelos já existentes foram reutilizados, sem iniciar novas gerações.
- Thrixel: Guardião Cervo rigado, Caranguejo do Rio Prateado rigado, Espectro Afogado texturizado, Árvore Anciã texturizada, Obelisco Rúnico otimizado e Santuário de Pedra.
- Meshy: personagem Tobi em 3D com textura PBR concluída (task `01a20058-ae2b-72a1-b2e6-52a6120cc2cf`); ainda precisa ser transferido para o pacote local e conectado ao rig/controle do jogador.
- Aqueduct: grafo PBR **Tobi e Breu — Materiais PBR Dark Fantasy** localizado e lido; define base color, normal, roughness, AO e height. A exportação dos mapas ainda não foi empacotada no repositório.
- Criado catálogo de seis assets Thrixel com IDs de origem e URLs GLB a 1024 px; adicionado download sob demanda, cache em `user://plugin_assets/thrixel` e carregamento por `GLTFDocument`.
- Os seis modelos são instanciados em pontos do mundo 3D; o cache evita baixar novamente nas próximas sessões. O download inicial exige conexão com internet.
- O dock Asset Bridge do editor agora lista os seis assets Thrixel.
- Não foram consumidos novos créditos de geração; Thrixel está sem cubes no momento. Nenhum asset existente foi apagado.
- A compilação/execução Godot ainda precisa validar o carregamento GLB no Android. A permissão `permissions/internet=true` já está habilitada no preset Android.


## Integração dos modelos Meshy existentes — 21/11/2026

Foram identificados quatro assets próprios do projeto no Meshy e ligados aos pontos de importação do Godot:

- **Tobi (herói texturizado):** task `01a20058-ae2b-72a1-b2e6-52a6120cc2cf`, destino `res://assets/plugin_imports/meshy/tobi_hero.glb`. O player tenta instanciar esse GLB automaticamente e mantém o personagem procedural como fallback.
- **Portal gótico:** task `01a1ff12-3dd2-707a-8c0e-016625d9d9d5`, destino `res://assets/plugin_imports/meshy/gothic_gate.glb`.
- **Obelisco rúnico:** task `01a20014-fcbc-770c-b0e4-a7c027e9d5e6`, destino `res://assets/plugin_imports/meshy/rune_obelisk.glb`.
- **Santuário de pedra:** task `01a1ffc1-4452-7384-9c4c-4a81ece4fc4a`, destino `res://assets/plugin_imports/meshy/stone_way_shrine.glb`.

O carregador e o mundo agora chamam esses três props Meshy, e o player reconhece o GLB do Tobi quando ele existir. **Os arquivos GLB ainda não estão versionados no repositório:** a API Meshy bloqueou o download solicitando upgrade de plano. Nenhum modelo foi recriado e nenhum crédito de geração foi consumido nesta etapa. Até a importação dos arquivos, o jogo continua usando o herói procedural e os props existentes do cenário.


## Forge 3D local sem créditos — 21/11/2026

Como o download do Meshy exige upgrade e o usuário pediu para não gastar tokens, foi criado `scripts/procedural_asset_forge.gd`: um gerador local de malhas primitivas compostas, executado pelo próprio Godot. O carregador usa GLB importado quando existir e, na ausência dele, constrói versões locais do guardião cervo, caranguejo do rio, espectro afogado, árvore ancestral, obelisco rúnico, santuário e portão gótico. O mundo chama esses fallbacks sem requisições externas. O Tobi continua com o modelo procedural já presente como fallback. Nenhum crédito/token de geração foi consumido.

A conta Creations3D consultada tinha 8 créditos restantes, mas a geração para jogo custa 4; não foi usada por respeitar o pedido de não gastar tokens. O Spline conectado está no plano Free e tem limite diário de chamadas; ele permite modelagem procedural, mas o caminho mais direto para colocar assets no projeto Godot sem depender de exportação manual é o forge local.


## Expansão completa de arte e cenário — 22/11/2026

- O mundo já existente foi preservado: terreno de 700 × 700, clareira inicial, Pântano dos Ratos, Rio Prateado, Bosque dos Sussurros, Floresta Ancestral, Montanha Gelada, Desfiladeiro Rubro, Ruínas Antigas, Planície Dourada, Cume das Nuvens, Templo do Coração, Vila do Carvalho, Cidade de Pedra, Guilda, Caverna do Eco, Masmorra das Cinzas e Castelo do Silêncio.
- Os dois atlases de textura existentes (surface_albedo_atlas.png e surface_roughness_atlas.png) continuam sendo usados pelo shader painterly triplanar. O shader agora também tem cinco variações procedurais adicionais: obsidiana, pedra musgosa, pedra manchada de sangue, metal gasto e cristal arcano.
- Criado scripts/dark_fantasy_prop_pack.gd, um pack local sem créditos com props 3D decorativos para vila, cidade, floresta, caverna, masmorra, castelo e ruínas: barracas, poço, barris, caixas, lampiões, placas, bancos, bigorna, troncos, cogumelos, lápides, cristais, braseiros, altar e estandartes.
- O pack é carregado durante a construção do mundo principal; não cria um mapa paralelo nem substitui missões, checkpoints, saves, inimigos ou HUD.
- Os modelos externos (GLB/FBX) ainda dependem de download e importação dos arquivos originais. O Ultimate Dungeon Pack tem 1,1 GiB; os demais links e licenças estão catalogados em assets/external_packs/README.md. Não afirmar que os binários externos estão dentro do APK.
- Nenhum crédito de geração foi gasto. A nova decoração usa geometria local do Godot e os atlases PBR já versionados.
- Testes de contrato foram adicionados. A execução Godot/Android ainda precisa terminar no GitHub Actions antes de declarar build validado.


## Importação de modelos externos e PBR CC0 — 22/11/2026

- Importados e versionados **20 modelos GLB** da 3DAssets.dev em `assets/external_packs/3dassets_dev/`, com catálogo de origem/licença. A biblioteca declara CC0 1.0 e os GLBs são autocontidos.
- Importados **9 mapas PBR** da Poly Haven (albedo, normal e roughness para pedra musgosa, terra com pedras e lama) em `assets/textures/polyhaven/`.
- Os modelos foram adicionados ao carregador do mundo com filtros por nome: apenas peças compatíveis com a natureza e as ruínas do Rio Prateado entram no cenário. Corais e outros elementos exclusivamente submersos ficam guardados no pack, mas não são espalhados em terra.
- Os mapas PBR são aplicados em seis pequenas manchas de transição no Pântano dos Ratos e nas margens do Rio Prateado. O terreno painterly original, trilhas, construções, missões e colisões não são substituídos.
- O carregador externo agora aceita OBJ, FBX, GLB e glTF. A integração Meshy prioriza os GLBs reais quando já existem e mantém o forge procedural como fallback; o Tobi Meshy continua opcional no player. Os assets Thrixel e demais plugins permanecem no catálogo e nas chamadas existentes.
- A API da LazyTextures já baixou modelos e materiais CC0; o commit automático para o repositório ainda está em andamento nesta atualização. Não contar esses arquivos como versionados até confirmar o push.
- A tentativa de baixar o pack Quaternius pelo Google Drive foi bloqueada pelo limite de downloads do próprio Drive. Nenhum arquivo parcial foi tratado como integrado; foi mantido o caminho alternativo de fontes com API/CDN pública.
- O workflow Android foi acionado para validar os contratos e importar o projeto, mas a compilação Godot/APK ainda não está confirmada. Não declarar APK pronto nem runtime validado até o workflow concluir com sucesso.


## Novos modelos 3D locais — 22/11/2026
- Adicionados quatro modelos compostos low-poly ao pack procedural: Carroça do Coletor de Ossos, Círculo de Runas Sussurrantes, Poço Amaldiçoado e Estátua do Guardião Caído.
- Os modelos são construídos com malhas nativas do Godot e reutilizam o shader painterly e os materiais/atlases existentes; não exigem Meshy, downloads ou créditos.
- Os quatro objetos são instanciados automaticamente em pontos das regiões já existentes por `scripts/dark_fantasy_prop_pack.gd`; nenhum mapa, missão, save, HUD ou sistema de combate foi substituído.
- Adicionado teste de contrato para os quatro construtores e seus nomes de cena.
- Ainda falta o workflow executar os testes e validar a cena no Godot/Android. Até essa execução, não declarar compilação ou desempenho mobile confirmados.


## Criatura original — Vigia das Raízes (22/11/2026)
- Adicionado o inimigo opcional Vigia das Raízes à Floresta Ancestral, usando o arquétipo enemy_kind 9 e o sistema de movimento/combate existente.
- Silhueta própria com placas de casca, espinhos de raiz, olhos e núcleo verde emissivo; indicador de ataque usa tom verde para comunicar o golpe.
- Parâmetros: 230 HP, velocidade 2,3, dano 18 e alcance 2,2. Recompensa opcional: +35 XP, +2 Essências Sombrias, +1 Erva do Pântano e chance de Fragmento Rubro.
- Não altera etapas, contadores ou recompensas das missões principais. O inimigo é recriado como encontro opcional ao iniciar uma nova sessão.
- Adicionado teste de contrato para spawn, identidade visual e recompensa.
- GDScript ainda precisa ser validado pelo Godot e testado no Android; testes de contrato não substituem execução no motor.


## Criatura da Montanha Gelada — Corvo Glacial (22/11/2026)
- Adicionados dois Corvos Glaciais como encontros opcionais perto dos cristais da Montanha Gelada.
- Modelo procedural com corpo e cabeça aviários, bico, olhos emissivos, cauda, garras e asas articuladas com penas facetadas.
- As asas batem e o corpo paira visualmente; o inimigo mantém o sistema de perseguição, telegráfico e ataque já existente.
- Parâmetros: 125 HP, velocidade 2,75, dano 12 e alcance 1,75. Recompensa opcional: +25 XP, 1 Fragmento Rubro e 1 Essência Sombria.
- Adicionado teste de contrato para spawn, modelo e animação das asas.
- Ainda depende da validação Godot/Android no workflow.


## Ferramentas externas de criação — Corvo Glacial (22/11/2026)
- Spline: criada a cena editável "Tobi e Breu - Corvo Glacial" com o grupo 3D "Corvo Glacial", 19 objetos geométricos, piso shadow-catcher e duas luzes de preenchimento.
- A cena do Spline é uma referência visual independente. Nenhum GLB foi exportado dela e ela ainda não é carregada pelo Godot.
- A primeira verificação visual do Spline apontou exposição muito escura. Foram adicionadas luzes de preenchimento, mas o limite de capturas desta sessão foi atingido antes de uma nova verificação; a exposição final permanece não confirmada.
- Krea: catálogo de geração 3D consultado e modelo Hunyuan3D 3.1 Rapid validado por schema. Nenhuma geração submetida nesta etapa.
- Meshy: saldos e histórico consultados. O modelo da Árvore Ancestral continua sem formatos de download disponíveis nesta conexão; nenhuma geração adicional foi cobrada.
- Luma: saldo de créditos da equipe conectada está zerado; nenhuma geração submetida.
- A validação Godot identificou referências às pernas do Corvo Glacial antes da declaração local. A ordem foi corrigida no commit seguinte; aguardar novo workflow para confirmar o parser.


## Marcos ambientais adicionais — Montanha Gelada e Desfiladeiro Rubro (22/11/2026)
- Adicionado o Altar da Memória Glacial, com base de pedra fria, anel emissivo, cristal central e seis fragmentos de gelo.
- Adicionado o Portal da Fenda Rubra, com pilares, lintel, pedra-chave emissiva e cinco runas.
- Os dois modelos são malhas low-poly procedurais e entram no construtor central do pacote de props; não dependem de downloads nem créditos externos.
- Testes de contrato adicionados. Aguardando validação pelo workflow Android/Godot.


## Marcos ambientais — Pântano dos Ratos e Rio Prateado (22/11/2026)
- Adicionado o Caldeirão da Bruxa do Pântano, com estrutura metálica, pernas, mistura tóxica e bolhas emissivas.
- Adicionado o Marco do Sino Afogado no Rio Prateado, com base de pedra, pilares, viga, sino suspenso e runa.
- Ambos são modelos procedurais leves integrados ao pacote de construção do mundo.
- Testes de contrato adicionados; validação Godot/Android pendente no workflow mais recente.


## Modelos ambientais adicionais — Planície, Bosque e Caverna (22/11/2026)
- Integrado o Moinho da Planície Dourada com torre, porta, eixo e quatro pás.
- Integrado o Bosque de Cogumelos Sussurrantes com cinco cogumelos e partículas luminosas estáticas leves.
- Integrado o Agrupamento de Cristais da Caverna do Eco com sete cristais e núcleo emissivo.
- Atualizado teste antigo de contrato do workflow Android para refletir a busca atual por project.godot na raiz ou subpastas. O teste anterior exigia um trecho de shell que já havia sido substituído por uma busca mais abrangente; a falha era do teste desatualizado, não da etapa de localização do projeto.
- Testes de contrato adicionados para os três novos conjuntos; aguardando execução no CI.


## Modelo 3D — Gato companheiro de Tobi (22/11/2026)
- Criado um gato low-poly procedural com corpo, cabeça, orelhas, olhos âmbar, bigodes, patas, cauda segmentada, coleira vinho e medalhão dourado.
- Integrado ao `DarkFantasyPropPack.build_all()` perto da clareira inicial, sem substituir personagens ou alterar missões.
- Incluído teste de contrato para confirmar a presença e integração das partes principais.
- Ainda precisa de validação no Godot 4.3 e em Android; o modelo é visual nesta etapa, sem comportamento de companheiro.
