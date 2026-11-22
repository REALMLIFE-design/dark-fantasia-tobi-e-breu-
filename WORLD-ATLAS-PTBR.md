# Atlas do Mundo — Tobi e Breu

As coordenadas abaixo são aproximadas e usam o centro do mapa como referência. O mapa atual tem terreno-base de 700 × 700 unidades.

## Regiões naturais

| Região | Centro aproximado | Conteúdo |
|---|---:|---|
| Clareira inicial | (0, 0) | Mestre Azulan, acampamento, ruínas e primeiros goblins |
| Pântano dos Ratos | (0, -91) | Poças tóxicas, três totens e Bruxa do Pântano |
| Rio Prateado | (55, -127) | Guardião do Rio, Cavaleiros Afogados, Leviatã, baús e astrolábio |
| Bosque dos Sussurros | (96, -145) | Três lanternas persistentes e caminho de pedras |
| Floresta Ancestral | (-158, -104) | Árvores antigas e marco de pedra |
| Montanha Gelada | (-166, -260) | Picos gelados e cristais |
| Desfiladeiro Rubro | (166, -260) | Falésias e fragmentos rubros |
| Ruínas Antigas | (164, -65) | Praça em ruínas e portão antigo |
| Planície Dourada | (0, 246) | Campos abertos e marcos de caminho |
| Cume das Nuvens | (0, -325) | Altar de pedra e rochedos |
| Templo do Coração | (165, -330) | Marco narrativo do Coração Rubro |

## Civilização e exploração adicionadas nesta atualização

| Local | Centro aproximado | Conteúdo atual |
|---|---:|---|
| Vila do Carvalho | (-112, 92) | Praça, poço, sete casas exteriores e iluminação |
| Cidade de Pedra | (174, 88) | Praça urbana, poço, onze casas exteriores e iluminação |
| Guilda dos Vigias | (-34, 66) | Salão e quadro de contrato interativo |
| Caverna do Eco | (-220, -255) | Boca rochosa, corredor, câmara e cristais |
| Masmorra das Cinzas | (226, 94) | Portão, três salões, pilares e altar |
| Castelo do Silêncio | (250, -300) | Fortaleza, quatro torreões, portão e ponte |

## Contrato opcional da Guilda

1. Vá ao salão da Guilda dos Vigias e interaja com o quadro.
2. Recupere o Selo da Caverna, o Selo das Cinzas e o Selo do Castelo.
3. Volte ao quadro e entregue os três selos.
4. Recompensa final: 240 XP, 8 Fragmentos Rubros, 5 Essências Sombrias e 3 Poções. Cada selo também concede 45 XP.

O contrato e os selos são persistentes no save v12.

## Limites desta versão

As vilas e a cidade têm arquitetura exterior procedural; as casas ainda não têm interiores exploráveis, lojas ou NPCs com rotinas. A caverna, a masmorra e o castelo têm composição visual e pontos de exploração, mas ainda precisam de encontros dedicados, portas/chaves, navegação interna e chefes próprios. Os locais são protótipos de conteúdo jogável em expansão, não uma alegação de mundo AAA concluído.


## Encontro opcional — Montanha Gelada
- Dois Corvos Glaciais patrulham a região dos cristais, aproximadamente em (-179, -267) e (-153, -279).
- São inimigos opcionais e não alteram os objetivos das missões principais.


## Novos marcos regionais
- Pântano dos Ratos: Caldeirão da Bruxa do Pântano, próximo à região central (9, -94).
- Rio Prateado: Marco do Sino Afogado, próximo ao curso do rio (61, -132).
- Ambos são elementos ambientais de exploração; não substituem nem alteram os objetivos das missões existentes.


## Modelos ambientais desta expansão
- Planície Dourada: moinho de pedra e madeira, aproximadamente (18, 238).
- Bosque dos Sussurros: pequeno bosque de cogumelos luminosos, aproximadamente (105, -151).
- Caverna do Eco: agrupamento de cristais azulados emissivos, aproximadamente (-228, -248).
- Os modelos são cenografia procedural otimizada para mobile; não alteram missões, recompensas ou colisões de combate.


## Companheiro — Gato de Tobi
- Um gato procedural detalhado cinza-escuro em pose sentada foi colocado perto da clareira inicial, aproximadamente em (4, 3.5).
- O modelo tem olhos âmbar, focinho claro, orelhas rosadas, cauda segmentada e coleira vinho com medalhão dourado.
- É um modelo procedural leve integrado ao carregamento do pacote de cenografia; nesta etapa é visual, sem IA, animação ou interação.


## Direção de qualidade dos modelos 3D
- A expansão visual mantém todos os conjuntos procedurais registrados no construtor central do mundo.
- A geometria esférica procedural foi refinada para 24 segmentos radiais e 16 anéis; cilindros e cones também receberam maior resolução.
- O gato de Tobi recebeu detalhes adicionais de pelagem, focinho, sobrancelhas, dedos, rebites e medalhão em camadas.
- Os modelos GLB externos já gerados continuam no catálogo de importação e são carregados pelo mundo quando os binários estão disponíveis; os fallbacks procedurais permanecem ativos quando a transferência falha.


## Novos pontos de interesse regionais — 22/11/2026
- **Santuário do Marco Antigo**: portal de pedra, pedestal e cristal de orientação próximo à Vila do Carvalho.
- **Acampamento dos Caçadores**: tenda, fogueira, baú de suprimentos e tochas na trilha da floresta.
- **Ponte de Pedra do Rio Prateado**: tabuleiro de lajes, balaústres e corrimãos para marcar a travessia do rio.
- **Torre de Vigia Caída**: torre de madeira e pedra com plataforma, parapeitos, telhado e estandarte junto à Cidade de Pedra.
- Os quatro modelos entram automaticamente no pacote de cenário; são marcos visuais, ainda sem interação, loot ou colisão dedicada.


## Oficinas de profissão — 22/11/2026
- **Forja do Ferreiro**, na Vila do Carvalho: lareira de pedra, bigorna, martelo, lâminas expostas, carvão e chaminé.
- **Oficina do Alquimista**, na Cidade de Pedra: bancada, frascos com líquidos coloridos, caldeirão, ingredientes, grimório e cristal de foco.
- São cenários visuais registrados no carregamento central. Não adicionam NPCs, lojas, receitas, inventário ou economia nesta etapa.


## Modelos 3D de inimigos — integração (22/11/2026)
- As famílias procedurais dos tipos 0 a 10 continuam disponíveis: goblins, Guardião do Silêncio, Bruxa do Pântano, Cavaleiros Afogados, Leviatã do Lodo, Espectros Afogados, Caranguejos de Prata, Vigia das Raízes e Corvos Glaciais.
- Os GLBs externos já gerados do Espectro Afogado, Caranguejo de Prata e Guardião Cervo têm pontos de encaixe nas instâncias reais dos inimigos (tipos 7, 8 e 9). Quando o GLB existe no projeto, substitui a malha visual procedural; se estiver ausente, o fallback permanece.
- Os GLBs ainda dependem de transferência/importação binária para `assets/plugin_imports/thrixel/`; o código de encaixe não significa que esses arquivos já estejam presentes.
