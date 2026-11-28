# Direção artística — Dark World: A Lenda de Tobi e Breu

## Identidade oficial

Mistura equilibrada de Bright Fantasy, Dark Fantasy e Adventure Fantasy com surrealismo leve, como um sonho mágico. O mundo deve ser bonito e acolhedor à primeira vista, mas guardar mistério, ruínas, perigo e regiões realmente sombrias.

A inspiração psicodélica é visual e suave: paisagens oníricas, bioluminescência, formas naturais incomuns e cores que parecem pertencer a um sonho. Não usar referências explícitas a consumo de drogas.

## Paleta de referência

- Verde esmeralda e musgo para florestas vivas.
- Azul-petróleo e turquesa para rios, sombras mágicas e áreas misteriosas.
- Lavanda e violeta para névoa, cristais e energia sobrenatural.
- Dourado quente e âmbar para luz do sol, santuários e pontos de esperança.
- Carvão azulado para ruínas e áreas corrompidas.

O contraste entre luz quente e sombra fria é essencial. Evitar saturação neon constante, bloom exagerado ou filtros que tornem tudo roxo.

## Regras por região

- Bosques e clareiras: luminosos, verdes ricos, flores claras, pequenos brilhos e luz quente filtrada.
- Pântano dos Ratos: verdes profundos, água escura, névoa fria e pequenos focos de luz natural.
- Rio Prateado: turquesa, prata e lavanda discreta, reflexos mágicos e sensação de tranquilidade misteriosa.
- Ruínas e masmorras: carvão azulado, pedra fria e acentos rubros/violetas para comunicar perigo.
- Aldeias: luz âmbar, materiais quentes e áreas seguras visualmente acolhedoras.

## Implementação técnica inicial

- O ambiente global usa céu azul profundo com horizonte rosado, iluminação ambiente lavanda suave, sol quente e neblina teal.
- Color grading filmic com pequeno aumento de contraste e saturação.
- Glow discreto, com limiar alto para que apenas fontes luminosas e materiais emissivos se destaquem.
- Shader painterly ganhou uma variação de pigmento quente/frio muito leve, sem novas texturas ou amostras extras.
- As alterações preservam meshes, mapas, colisões, missões, personagens, HUD, controles e dados de save.
- A implementação prioriza Compatibility Renderer e Android; não adiciona volumetric fog nem efeitos caros.

## Próximas melhorias visuais (não declarar concluídas)

1. Ajustar individualmente a iluminação de cada bioma, preservando a leitura e a identidade de cada mapa.
2. Adicionar partículas de vaga-lumes e pólen com limites de quantidade por dispositivo.
3. Criar materiais emissivos pontuais para flores, cristais e runas.
4. Adicionar variações de céu e clima por região, sem alterar progressão ou geometria.
5. Validar screenshots e FPS em Android de entrada antes de aumentar glow, transparências ou partículas.

## Critério de qualidade

O cenário deve parecer pintado à mão e mágico, mas manter boa leitura de caminhos, inimigos e objetivos. O jogador deve pensar: “Que lugar lindo… mas o que aconteceu aqui?”.
