# Dark World: A Lenda de Tobi e Breu

Aventura 3D em Godot 4.3. Uma fantasia contada como um grande conto de amizade, coragem e magia, acompanhando Tobi e Breu em uma jornada planejada em cinco capítulos.

> Era uma vez um mundo que começou a esquecer suas próprias histórias. Dois amigos decidiram lembrar por ele.

**Identidade narrativa:** conto cinematográfico com narrador acolhedor, humor, mistério, emoção e objetivos de missão sempre claros.

**Preservação:** esta mudança de nome e direção narrativa não substitui mapas, personagens, missões, controles, HUD, assets ou sistemas existentes. O prólogo e a estrutura dos cinco capítulos estão documentados; nem todos os capítulos e cutscenes estão implementados ainda.

## Revisão de conteúdo e Android — 21/11/2026

- O Bosque dos Sussurros recebeu uma estátua espiritual procedural do Cervo Ancião, com galhadas, olhos luminosos e movimento sutil.
- Acender as três lanternas e falar com o guardião libera uma bênção única: 90 XP, 3 Fragmentos Rubros, 2 Essências Sombrias e 1 Poção.
- A recompensa do guardião é persistida no save; a versão do salvamento passou para 13 e continua aceitando versões anteriores.
- Um modelo rigado de 14.064 triângulos foi gerado no Thrixel, mas permanece fora do jogo aguardando empacotamento e validação canônicos.
- O CLI local `game-dev`, exigido pela habilidade de vendoring, não está instalado. Nenhum download bruto foi copiado para o projeto nem ferramenta foi instalada para contornar essa regra.
- Menu principal: cópia mais curta e botão de fechar com alvo de toque 44×44.
- Teste Android separado em script Bash para evitar que blocos condicionais sejam quebrados pelo executor do emulador.

## Atualizações do protótipo 0.7 — revisão visual e animação

- Tobi recebeu novas camadas de roupa, ombreiras, joelheiras, bolsos, fecho da capa e painel frontal da túnica.
- Animações de locomoção refinadas, inclinação da capa, golpe com contramovimento do braço livre, reação ao dano, aterrissagem e pose de derrota.
- Breu agora tem quatro patas articuladas e cauda segmentada, com ciclos de corrida e movimentos de atenção.
- Inimigos receberam detalhes de equipamento e silhuetas mais distintas; Guardião ganhou peitoral/brasão e Bruxa ganhou manto, fragmentos orbitais/ornamentais e movimento do cajado.
- Ciclos de idle, caminhada, ataque, dano e morte refinados para inimigos.
- Nenhum save, controle, missão ou conteúdo do jogo 2D foi alterado.

## Atualizações do protótipo 0.5

- Segunda região conectada: Pântano dos Ratos, com terreno próprio, poças tóxicas, árvores mortas e altar.
- Três totens purificáveis com progresso salvo individualmente.
- Nova cadeia de missão após o Guardião do Silêncio: purificar os totens, despertar e derrotar a Bruxa do Pântano, retornar a Azulan e concluir o Capítulo I.
- Novo chefe Bruxa do Pântano, com atributos próprios e bloqueio até a purificação dos três totens.
- Recompensas de XP, fragmentos e poções ao concluir o capítulo.
- Save atualizado para versão 4, registrando cada totem individualmente e migrando saves da versão 3, mantendo leitura de saves anteriores.
- Área física ampliada para acomodar a nova região conectada.

## Atualizações do protótipo 0.4

- Corrigido o atalho de teclado para esquiva (Q).
- Corrigido o atalho de teclado para poção (H).
- A primeira missão agora conta somente goblins corrompidos, como o texto da missão promete; outros arquétipos ainda concedem recompensas, mas não avançam esse objetivo.
- Save local agora possui versão e validação básica do estágio, mantendo compatibilidade com saves antigos.
- Adicionados testes automatizados de contratos de gameplay e configuração Android.

## Atualizações do protótipo 0.3

- Direção pictórica aplicada aos materiais do cenário com shader procedural de pinceladas.
- Clareira expandida com torre em ruínas, cicatriz de cristais rubros, santuário opcional, arbustos e iluminação dinâmica de ciclo dia/noite.
- Três arquétipos de goblin: corrompido, bruto e batedor.
- Guardião do Silêncio como chefe desbloqueado pela progressão da missão.
- Esquiva com invulnerabilidade curta e consumo de vigor; vigor recupera gradualmente.
- Poções de cura, XP, níveis e fragmentos rubros.
- Santuário com recompensa opcional.
- Salvamento local de missão, progresso, inventário, vida e santuário; grava ao pausar/fechar.
- Tobi com mais camadas de roupa e Breu com cauda e patas.
- Orientação Android horizontal e escala por viewport.

## Estado real desta entrega

A revisão 0.12.0 aprimora o combate do Leviatã do Lodo com golpes de impacto em área alternados com ataques próximos, telegráficos maiores e janela de reação ampliada na fase enfurecida. Mantém progressão por XP, combate, inventário, chefes e checkpoints. Na validação automatizada do commit `e343353ff916450d60b74a4fcfd0b36ba09ae9e2`, a importação dos recursos e o teste headless de inicialização da cena principal passaram; o APK Android foi gerado, assinado e validado. O teste de abertura/interação em emulador ainda está em andamento, e não há validação em aparelho físico.

O protótipo em Godot 4 agora inclui a clareira inicial, o Pântano dos Ratos e o Rio Prateado, com Tobi, Breu, Mestre Azulan, Guardião do Rio, goblins, Guardião do Silêncio, Bruxa do Pântano e Cavaleiros Afogados. Há movimento, câmera touch, pulo, esquiva, combos, Pulso Sombrio, forja, inventário, progressão por XP, checkpoints e duas cadeias de capítulo. O mundo e os personagens usam meshes procedurais low-poly e materiais ásperos para estabelecer a direção de arte pintada à mão sem depender de modelos pagos.

## Executar

1. Instale Godot 4.3 ou superior.
2. Importe `project.godot` no Godot.
3. Execute a cena principal.

Controles desktop: WASD/setas, Espaço para pular, J para atacar, E para interagir, Q para esquivar e H para usar poção.
Controles touch: setas no canto inferior esquerdo; atacar, pular e interagir no canto inferior direito. Arraste o lado direito da tela para girar a câmera.

## Direção técnica

- Renderer Compatibility / OpenGL para maior alcance em Android.
- Geometria procedural simples e contagem baixa de materiais/objetos.
- Sombras dinâmicas contidas e fog atmosférica.
- Base preparada para streaming por regiões e pacotes opcionais de conteúdo.

## Limitações ainda abertas (não chamar de jogo completo)

1. Modelos finais externos com topologia otimizada, UVs, texturas PBR, rig esquelético e clips importados. A versão 0.8 melhora os meshes procedurais e os pivôs animados, mas ainda não substitui assets finais rigados.
2. Navegação e pathfinding para inimigos contornarem obstáculos, além de colisões de cenário completas.
3. Mais regiões jogáveis, interiores, NPCs, diálogos ramificados, loot e missões secundárias.
4. Áudio, VFX finais, menus completos, opções gráficas e acessibilidade.
5. Teste real no Godot e em Android físico; esta entrega ainda não foi executada no motor.

## Próximas etapas obrigatórias antes de chamar de jogo completo

1. Abrir e testar no Godot Editor e em Android físico; ajustar colisões, câmera e input touch (não validado nesta entrega porque o executável Godot não está disponível neste ambiente).
2. Substituir os meshes estilizados por modelos 3D finais com rig, skinning, blend shapes e clips de animação importados; depois validar no Godot e Android.
3. Criar terrenos modulares, navegação, cidades e interiores por região.
4. Implementar sistema completo de quests, inventário, saves, diálogo, combate e progressão usando a narrativa/dados da versão 2D como referência.
5. Produzir áudio original, mixagem, VFX e perfis de qualidade por dispositivo.
6. Configurar exportação Android e medir FPS, memória, bateria e tamanho real do pacote.

O limite de 3 GB é um teto de produto desejado, não uma medição deste protótipo. Conteúdo em nuvem exige backend/CDN, versionamento, autenticação e download incremental — ainda não implementados.


## Versão 0.8 — Forja
Perto de Mestre Azulan, use o botão FORJAR (ou tecla U) para aprimorar a espada. São três níveis, custando 3, 6 e 10 Fragmentos Rubros. Cada nível aumenta o dano em 10 pontos. O progresso é salvo automaticamente.


### Inventário e loot (versão 0.9)
Abra a mochila pelo botão MOCHILA na tela ou pela tecla I no teclado. Ela lista poções, fragmentos, materiais de goblins, ervas do pântano, essência sombria e o nível/dano da espada. Goblins, inimigos do pântano e chefes concedem materiais diferentes; o progresso é persistido no save.


## Versão 0.9.1 — Ponto de retorno persistente
- O Santuário Esquecido agora ativa um checkpoint real.
- A posição do checkpoint é salva e restaurada ao continuar a partida.
- Ao ser derrotado, Tobi retorna ao último santuário ativado, em vez de sempre voltar ao acampamento.
- Coordenadas de save são validadas para impedir pontos fora do mapa.
- Saves anteriores continuam válidos; o formato foi atualizado para v7.


**Versão atual do pacote:** 0.12.0.

## Progressão real de personagem (0.9.5)
- A experiência agora aumenta atributos reais, não apenas o número exibido na mochila.
- A cada 100 XP, Tobi sobe um nível, ganha +12 de vida máxima, +3 de dano base e recupera 25 pontos de vida.
- A barra de EXP mostra o progresso dentro do nível atual.
- A progressão usa o XP já salvo; o formato de save v8 mantém compatibilidade com saves anteriores.


## Combate atualizado (0.9.2–0.9.4)
- Encadeie até três ataques dentro da janela de combo para aumentar o dano.
- Use Pulso Sombrio de Breu pelo botão BREU no celular ou tecla K no teclado. A habilidade custa 35 de vigor e recarrega em 8 segundos.
- Na versão 0.9.3, a habilidade cria uma onda circular violeta expansiva que indica visualmente o alcance do efeito.


### Combate 0.9.4
Os inimigos agora anunciam seus golpes com um círculo vermelho emissivo no chão e uma animação de preparação. O dano só é aplicado ao fim da preparação e apenas se Tobi continuar no alcance. Esquivar durante o aviso passa a ser uma resposta válida; chefes têm janelas de reação maiores.


## Capítulo II — Rio Prateado (0.11.0)
Após concluir o Pântano dos Ratos e falar novamente com Mestre Azulan, siga para leste até o Rio Prateado. Converse com o Guardião do Rio, derrote três Cavaleiros Afogados e retorne para libertar a passagem. A nova cadeia salva o progresso e a contagem dos inimigos no formato de save v8, mantendo saves anteriores compatíveis.


## Asset 3D externo — Árvore Anciã
Foi gerado no projeto Thrixel vinculado ao jogo um modelo GLB da Árvore Anciã (16 m de altura, 14.132 triângulos, 1 malha, textura 1024 px). Identificador da geração: `51f95b5b-9fc4-419f-96ca-c45b68dc4697`. O modelo permanece no projeto Thrixel; ainda não está empacotado nesta pasta Godot porque o link de exportação não pôde ser transferido para o ambiente de arquivos desta sessão.


## Capítulo II — Chefe final (0.11.0)
- Após libertar três Cavaleiros Afogados, Tobi deve retornar ao Guardião do Rio para despertar o Leviatã do Lodo.
- Novo chefe de grande porte com 680 HP, dano inicial de 27 e preparação de ataque ampliada. Abaixo de 50% de vida, entra em fúria.
- Barra de vida do chefe aparece no topo durante a luta e acompanha o HP em tempo real. O HP do Leviatã é salvo durante o combate.
- Derrotar o Leviatã libera uma etapa final de retorno ao Guardião; o capítulo só é concluído após reportar a vitória.
- Save v9 persiste os novos estágios (12–14) e continua aceitando saves anteriores.


## Combate do Leviatã — 0.12.0

O Leviatã alterna golpes próximos e esmagamentos circulares. O esmagamento anuncia uma área maior no chão antes de causar dano; na fase enfurecida, a área aumenta e a janela de reação fica mais longa. O jogador deve sair do círculo ou esquivar antes do impacto.

O modelo 3D do Espectro Afogado foi gerado no Thrixel (9.000 triângulos, 2,6 m, textura 1024), mas ainda não foi importado para a cena Godot porque o arquivo GLB não foi transferido para o pacote local nesta sessão.

### Conteúdo adicional em desenvolvimento — Espectros Afogados

Ao iniciar o Capítulo II, dois Espectros Afogados opcionais passam a rondar as margens do Rio Prateado. Eles têm 185 pontos de vida, movimento mais rápido e flutuação visual, e concedem 18 XP e uma Essência Sombria ao serem derrotados. Não substituem nem contam para a missão dos três Cavaleiros Afogados. O visual atual é procedural; o modelo GLB externo gerado no Thrixel ainda não foi transferido para esta pasta.

## Gerar APK pelo GitHub Actions

O repositório inclui o preset `Android` em `export_presets.cfg` e o workflow `.github/workflows/android-apk.yml`.

1. Extraia o ZIP e envie **todo o conteúdo de dentro de `TobiEBreu-3D`** para a raiz do repositório GitHub. A pasta `.github/workflows` precisa ficar diretamente na raiz do repositório, ao lado de `project.godot`.
2. No GitHub, abra **Actions** e selecione **Build Tobi e Breu Android APK**.
3. Toque em **Run workflow** e aguarde o job terminar.
4. Abra a execução concluída e baixe o artefato **TobiEBreu-Android-APK**.

O workflow gera um APK de depuração para instalação e teste, direcionado a dispositivos Android ARM64. Ele não é um APK assinado para publicação na Play Store. Para publicar, será necessário configurar uma chave de assinatura privada em GitHub Secrets e um preset de release. Nunca envie keystore ou senhas ao repositório.

O workflow usa Godot 4.3.3 para manter compatibilidade com a configuração atual do projeto (`config/features` 4.3). A compilação real só fica confirmada depois que o GitHub Actions executar o workflow no repositório.

Veja também o [Atlas do Mundo](WORLD-ATLAS-PTBR.md) para localizar regiões, vilas, guilda, caverna, masmorra e castelo.

### Materiais e superfícies
O projeto usa um shader procedural painterly para diferenciar visualmente grama, terra, lama, madeira, água, neve, telhas e pedra. A escolha do padrão é feita automaticamente em vários objetos pelo nome, e os biomas externos têm variações próprias. Isso é uma melhoria de materiais em tempo real, não um pacote de imagens bitmap/UV de alta resolução; mapas normais e texturas externas dedicadas continuam como uma etapa futura.


### Texturas do mundo
O projeto inclui atlases compartilhados de albedo e rugosidade em `assets/textures/`, com oito superfícies tileáveis (grama, terra, lama, madeira, água, neve, telhas e pedra). O shader painterly combina esses mapas com variações procedurais, projeção triplanar em superfícies verticais/inclinadas e relevo normal derivado do próprio atlas, preservando a identidade cromática de cada região sem adicionar novos bindings de textura. Mapas normais bitmap dedicados continuam como melhoria futura.
