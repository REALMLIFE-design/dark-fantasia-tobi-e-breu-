# História principal e plano cinematográfico — Tobi e Breu

## A promessa central

Tobi e Breu não estão explorando o mundo por acaso. O objetivo da campanha é recuperar o Coração Rubro, descobrir quem o roubou e impedir que o Silêncio Cinzento apague a vida, as memórias e os laços entre as pessoas.

O vínculo entre Tobi e Breu é o coração emocional da aventura: Breu consegue sentir a corrupção antes dos outros, mas cada contato com ela coloca sua própria essência em risco. Tobi precisa decidir repetidamente se seguirá o caminho mais rápido ou protegerá quem está ao seu lado.

## Prólogo — O Coração Roubado

Durante gerações, o Coração Rubro manteve o equilíbrio do mundo. Numa noite sem estrelas, foi arrancado do Templo do Coração. A névoa cinzenta avançou, apagando trilhas, corrompendo criaturas e fazendo pessoas esquecerem partes de suas próprias histórias.

Tobi encontrou Breu ainda pequeno na fronteira da floresta. Desde então, os dois viajam juntos. Quando Breu sente a corrupção se aproximar da clareira, Tobi procura Mestre Azulan, que reconhece as marcas deixadas pelo roubo.

## Objetivo principal

1. Encontrar Mestre Azulan e descobrir a origem da corrupção.
2. Derrotar o Guardião do Silêncio e obter a primeira pista.
3. Purificar os três totens do Pântano dos Ratos e enfrentar a Bruxa do Pântano.
4. Ajudar o Guardião do Rio, derrotar os Cavaleiros Afogados e deter o Leviatã do Lodo.
5. Reunir os selos e memórias espalhados pelas regiões, conquistar aliados e abrir o caminho ao Templo do Coração.
6. Descobrir quem roubou o Coração Rubro e enfrentar a origem do Silêncio Cinzento.
7. Recuperar o Coração Rubro e decidir o destino de Breu e do mundo.

## Perguntas dramáticas que movem a campanha

- Por que Breu consegue ouvir o Silêncio Cinzento?
- O roubo do Coração Rubro foi uma tentativa de destruir o mundo ou de impedir algo ainda pior?
- O que Mestre Azulan esconde sobre a origem da corrupção?
- O Coração Rubro pode ser restaurado sem sacrificar a essência de Breu?

As respostas devem ser reveladas aos poucos por diálogos, relíquias, chefes e cenas; não devem ser entregues todas no prólogo.

## Cutscenes e transições

### Implementado nesta rodada
- Prólogo cinematográfico de abertura em três quadros: O Coração Roubado, Tobi e Breu, O Chamado de Azulan.
- Tela escura com acento rubro, tipografia de fantasia e transição gradual entre quadros.
- Botão de avançar adaptado a toque e mouse.
- Pausa do mundo durante a cena e retorno ao jogo ao terminar.
- O prólogo é exibido uma vez por instalação e sua conclusão fica registrada em `user://tobi_breu_story.cfg`; não altera nem apaga o save de campanha.

### Próximas cenas da campanha
1. **A Marca do Guardião** — após a vitória no Guardião do Silêncio, a marca rubra reage à presença de Breu.
2. **O Último Totem** — ao purificar o terceiro totem, a névoa recua e revela a trilha da Bruxa.
3. **O Rio se Lembra** — após o Leviatã, o Guardião do Rio revela uma memória antiga de Azulan.
4. **A Porta do Templo** — os selos reunidos abrem a passagem para o Templo do Coração.
5. **O Coração e a Escolha** — confronto final, resolução do destino de Breu e encerramento com créditos.

As cenas 1–5 são roteiro planejado, não devem ser consideradas implementadas até serem conectadas aos eventos reais da campanha.

## Transições visuais

- Fade escuro entre quadros de história.
- Fade de entrada e saída do prólogo.
- Para transições de região futuras: escurecer, mostrar nome da região e objetivo, então revelar o cenário.
- Evitar vídeos pré-renderizados pesados; priorizar cenas leves em Godot para preservar desempenho Android.

## Regras de continuidade

- Não substituir os mapas, personagens, missões ou recompensas existentes.
- Não reiniciar nem migrar saves de campanha para registrar o prólogo.
- Preservar Tobi e Breu e a progressão já existente.
- Não declarar a campanha concluída enquanto o Templo do Coração, o confronto final, o encerramento e os créditos não estiverem implementados e testados.
