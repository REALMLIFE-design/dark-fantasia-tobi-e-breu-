# Dark World: A Lenda de Tobi e Breu
## Bíblia narrativa e plano dos cinco capítulos

## Identidade da aventura

A campanha deve ser apresentada como um grande conto de fantasia, com o calor de uma história contada antes de dormir e a emoção de um filme de animação infantil. Um narrador acolhedor conduz o jogador entre capítulos; a aventura também tem humor, perigos reais, mistérios e momentos emocionantes. Não tratar o jogador como bebê: a linguagem é simples, poética e respeita a inteligência de quem joga.

A amizade entre Tobi e Breu é o coração da história. Cada capítulo precisa deixar claro o que os amigos procuram, por que aquilo importa e qual será o próximo passo.

## A promessa central

Tobi e Breu precisam recuperar o Coração Rubro, descobrir quem o roubou e impedir que o Silêncio Cinzento apague a vida, as memórias e os laços entre as pessoas.

Breu consegue sentir a corrupção antes dos outros, mas cada contato com ela coloca sua própria essência em risco. Tobi precisa decidir repetidamente se seguirá o caminho mais rápido ou protegerá quem está ao seu lado.

## Prólogo — Era uma vez…

Era uma vez um mundo costurado por rios brilhantes, florestas antigas e pequenas luzes que dançavam no céu. No coração desse lugar pulsava o Coração Rubro, uma joia mágica que mantinha o equilíbrio entre todas as coisas.

Numa noite sem estrelas, uma sombra levou o Coração Rubro do templo. Uma névoa cinzenta despertou e começou a cobrir caminhos, rios e lembranças. Muito antes disso, Tobi havia encontrado Breu ainda pequeno, perdido perto da floresta. Desde então, os dois dividiram trilhas, sustos, risadas e promessas.

Quando Breu sente a névoa se aproximar, Tobi procura o Mestre Azulan. O sábio reconhece uma marca rubra e aponta para terras esquecidas. Assim começa a jornada.

## Os cinco capítulos

### Capítulo I — O Chamado de Azulan
**Objetivo:** descobrir de onde vem a primeira onda de corrupção e conquistar a primeira pista sobre o Coração Rubro.

Tobi e Breu procuram Mestre Azulan, exploram a região inicial, ajudam moradores assustados e seguem as marcas até o Guardião do Silêncio. A vitória revela que a névoa está sendo guiada por algo — não é uma tempestade natural.

**Momentos de conto:** apresentação calorosa do mundo, encontro com personagens curiosos, humor entre os amigos e a primeira grande cena de coragem.

### Capítulo II — A Floresta que Esqueceu
**Objetivo:** purificar os três totens do Pântano dos Ratos e deter a Bruxa do Pântano.

A floresta começa a esquecer seus próprios caminhos. Animais perdem o rumo e pequenas criaturas já não lembram onde construíram suas casas. Tobi e Breu precisam restaurar os totens, ajudar os habitantes e enfrentar a Bruxa do Pântano.

**Revelação:** Breu consegue ouvir vozes antigas dentro da névoa. A habilidade pode ajudar a dupla, mas também chama a atenção da corrupção.

### Capítulo III — O Rio das Memórias
**Objetivo:** ajudar o Guardião do Rio, reunir memórias perdidas e enfrentar os Cavaleiros Afogados e o Leviatã do Lodo.

O rio que antes refletia as estrelas agora mostra lembranças que ninguém reconhece. A dupla ajuda o Guardião do Rio e descobre fragmentos da história de Azulan e do Coração Rubro.

**Revelação:** o roubo talvez tenha sido cometido para esconder algo ainda mais perigoso. Nem toda sombra nasceu má.

### Capítulo IV — O Templo Esquecido
**Objetivo:** reunir os selos, abrir a passagem do templo e descobrir quem levou o Coração Rubro.

Com os aliados que conquistaram pelo caminho, Tobi e Breu atravessam as terras esquecidas. As pistas revelam a ligação entre o passado de Azulan, a origem de Breu e o desaparecimento do Coração.

**Momento emocional:** os amigos descobrem que a verdade pode colocar sua promessa à prova.

### Capítulo V — O Último Amanhecer
**Objetivo:** enfrentar a origem do Silêncio Cinzento e decidir o destino do Coração Rubro e de Breu.

No coração do mundo, a dupla encara a força por trás da névoa. A vitória não depende apenas de força: as escolhas, os aliados e as memórias recuperadas ao longo da jornada devem dar significado ao desfecho.

**Final:** encerrar a aventura com uma cena calorosa, mostrar o que mudou no mundo e deixar a sensação de que aquela história será lembrada por muito tempo.

## Regras para a narração e as cenas

- O narrador deve soar como alguém contando uma lenda querida: acolhedor, expressivo e poético, sem excesso de texto.
- Cada capítulo abre com uma pequena introdução cinematográfica e termina com uma conclusão que aponta para o próximo objetivo.
- Usar diálogos curtos entre Tobi e Breu para humor, carinho e personalidade.
- Mostrar os objetivos em linguagem clara no HUD ou diário de missões; a poesia nunca pode esconder o que o jogador precisa fazer.
- Cada chefe deve ter motivo narrativo e consequência visível no mundo.
- Revelar os mistérios aos poucos por diálogos, relíquias, personagens e cutscenes.
- Usar transições leves em Godot, com fades, título do capítulo e nome da região; evitar vídeos pesados para preservar o desempenho Android.
- Preservar todos os mapas, personagens, missões, recompensas, sistemas e saves existentes.

## Cutscenes e estado de implementação

### Implementado no projeto
- Prólogo em quatro quadros narrados: Era uma vez…, Quando a luz se calou, Tobi e Breu, O conselho de Azulan.
- Overlay nativo de Godot, fades de entrada, troca de quadro e saída.
- Botão de avanço para toque e mouse.
- Pausa do mundo durante a apresentação.
- Registro separado em `user://tobi_breu_story.cfg`, sem alterar o save da campanha.

### Planejado, ainda não implementado
1. Capítulo I: A Marca do Guardião.
2. Capítulo II: O Último Totem.
3. Capítulo III: O Rio se Lembra.
4. Capítulo IV: A Porta do Templo.
5. Capítulo V: O Coração e a Escolha, seguido dos créditos.

Essas cenas só devem ser marcadas como implementadas depois de conectadas aos eventos reais de cada missão e testadas no jogo.

## Continuidade

- O novo nome oficial é **Dark World: A Lenda de Tobi e Breu**.
- O nome do projeto e a identidade narrativa mudam; o mundo e seus sistemas existentes permanecem.
- Não reiniciar nem migrar saves de campanha para registrar o prólogo.
- Não substituir mapas, personagens, missões, controles, HUD, recompensas ou assets existentes.
- Não declarar os cinco capítulos completos até cada objetivo, evento, cutscene e desfecho estar implementado e testado.
