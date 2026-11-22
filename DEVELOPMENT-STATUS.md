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
